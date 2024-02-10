//
// Copyright (c) Vatsal Manot
//

#if canImport(Cocoa)
import AppKit
import Cocoa
#endif
import Foundation
import Swallow

@_spi(Internal)
public enum _DirectoryAccessManager {
    @MainActor
    public static func requestAccess(
        to directory: _UserHomeDirectory
    ) throws -> URL {
        try self.requestAccess(to: directory.url)
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
extension _DirectoryAccessManager {
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        fatalError(.unimplemented)
    }
}
#endif

#if os(macOS)
extension _DirectoryAccessManager {
    @MainActor
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        guard FileManager.default.isDirectory(at: url) else {
            let url = try _requestAccess(to: url)
            
            _ = url.startAccessingSecurityScopedResource()
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            return try _SecurityScopedBookmarks.save(for: url)
        }
        
        if let resolvedURL = try _SecurityScopedBookmarks.resolvedURL(for: url) {
            do {
                try _testWritingFile(inDirectory: resolvedURL)
                
                return resolvedURL
            } catch {
                let url = try _requestAccess(to: url)
                
                do {
                    try _testWritingFile(inDirectory: url)
                } catch {
                    assertionFailure()
                }
                
                return url
            }
        } else {
            if let ancestorURL = FileManager.default.nearestSecurityScopedAccessibleAncestor(for: url) {
                if !FileManager.default.fileExists(at: url) {
                    guard ancestorURL.startAccessingSecurityScopedResource() else {
                        assertionFailure()
                        
                        throw _DirectoryOrFileAccessError.invalidDirectory
                    }
                    
                    try FileManager.default.createDirectoryIfNecessary(
                        at: url,
                        withIntermediateDirectories: true
                    )
                    
                    ancestorURL.stopAccessingSecurityScopedResource()
                }
                
                _ = ancestorURL.startAccessingSecurityScopedResource()
                
                defer {
                    ancestorURL.stopAccessingSecurityScopedResource()
                }
                
                return try _SecurityScopedBookmarks.save(for: url)
            }
            
            let url = try _requestAccess(to: url)
            
            do {
                try _testWritingFile(inDirectory: url)
            } catch {
                assertionFailure()
            }
            
            return url
        }
    }
    
    private static func _testWritingFile(
        inDirectory url: URL
    ) throws {
        guard _isDebugAssertConfiguration else {
            return
        }
        
        _ = url.startAccessingSecurityScopedResource()
        
        let testFilePath = url.appendingPathComponent(".temp_test_file")
        try "test".write(to: testFilePath, atomically: true, encoding: .utf8)
        try FileManager.default.removeItem(at: testFilePath)
        
        url.stopAccessingSecurityScopedResource()
    }
    
    @MainActor
    public static func _requestAccess(
        to url: URL
    ) throws -> URL {
        let isDirectory = try url.checkIfDirectory()
        let openPanel = NSOpenPanel()
        let openPanelDelegate = _NSOpenSavePanelDelegate(url: url)
        
        openPanel.delegate = openPanelDelegate
        openPanel.directoryURL = isDirectory ? url : url.deletingLastPathComponent()

        if isDirectory {
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
        } else {
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
        }
        
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
                
        if isDirectory {
            let directoryName = _UserHomeDirectory(from: url)?.rawValue ?? "selected"
            let isKnownDirectory = _UserHomeDirectory(from: url) != nil

            openPanel.message = isKnownDirectory ? "Your app needs to access the \(directoryName) folder to continue. Please select the \(directoryName) folder to grant access."  : "Your app needs to access a folder to continue. Please select the folder to grant access."
        } else {
            if let fileName = url._fileNameWithExtension {
                openPanel.message = "Your app needs to access \(fileName) to continue. Please select \(fileName) to grant access."
            }
        }
        
        openPanel.prompt = "Grant Access"
        
        let response: NSApplication.ModalResponse = openPanel.runModal()
        
        switch response {
            case .OK, .continue:
                if let _url = openPanel.url {
                    let result = try _SecurityScopedBookmarks.save(for: _url)
                    
                    return result
                } else {
                    throw _DirectoryOrFileAccessError.accessDenied
                }
            case .abort:
                throw _DirectoryOrFileAccessError.accessCancelled
            default:
                throw _DirectoryOrFileAccessError.accessDenied
        }
    }
    
    fileprivate final class _NSOpenSavePanelDelegate: NSObject, NSOpenSavePanelDelegate {
        let currentURL: URL
        let isDirectory: Bool?
        
        init(url: URL) {
            self.currentURL = url.resolvingSymlinksInPath()
            self.isDirectory = try? url.checkIfDirectory()
            
            super.init()
        }
        
        func panel(
            _ sender: Any,
            shouldEnable url: URL
        ) -> Bool {
            url == currentURL || url._standardizedDirectoryPath == currentURL._standardizedDirectoryPath
        }
        
        func panel(
            _ sender: Any,
            validate url: URL
        ) throws {
            if isDirectory == true {
                guard url._standardizedDirectoryPath == currentURL._standardizedDirectoryPath else {
                    throw NSError.appError(
                        "Incorrect directory.",
                        recoverySuggestion: "Select the directory “\(currentURL)”."
                    )
                }
            } else {
                guard url == currentURL else {
                    throw NSError.appError(
                        "Incorrect file.",
                        recoverySuggestion: "Select the file “\(currentURL)”."
                    )
                }
            }
        }
    }
}
#endif

extension NSError {
    static func appError(
        _ description: String,
        recoverySuggestion: String? = nil,
        userInfo: [String: Any] = [:],
        domainPostfix: String? = nil
    ) -> Self {
        var userInfo = userInfo
        userInfo[NSLocalizedDescriptionKey] = description
        
        if let recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }
        
        return .init(
            domain: domainPostfix.map { "\(Bundle.main.bundleIdentifier!) - \($0)" } ?? Bundle.main.bundleIdentifier!,
            code: 1,
            userInfo: userInfo
        )
    }
}

// MARK: - Supplementary

extension FileManager {
    @MainActor
    public func withUserGrantedAccess<T>(
        to url: URLRepresentable,
        perform operation: (URL) throws -> T
    ) throws -> T {
        var url: URL = url.url
        
        do {
            if isURLInApplicationContainer(url) && FileManager.default.isReadable(at: url) {
                return try operation(url)
            }
        } catch {
            runtimeIssue(error)
        }
        
        url = try _DirectoryAccessManager.requestAccess(to: url)
        
        guard url.startAccessingSecurityScopedResource() else {
            assertionFailure()
            
            throw _SecurityScopedResourceAccessError.invalidAccess
        }
        
        let result = try operation(url)
        
        url.stopAccessingSecurityScopedResource()
        
        return result
    }
    
    private func isURLInApplicationContainer(
        _ url: URL
    ) -> Bool {
#if os(macOS)
        return url.path.hasPrefix(NSHomeDirectory())
#else
        return true
#endif
    }
    
    fileprivate enum _SecurityScopedResourceAccessError: Error {
        case invalidAccess
    }
}

// MARK: - Error Handling

extension _DirectoryAccessManager {
    @_spi(Internal)
    public enum _DirectoryOrFileAccessError: Error {
        case accessDenied
        case accessCancelled
        case invalidDirectory
        case other(Error)
    }
}


extension URL {
    enum DirectoryCheckError: Error {
        case unableToRetrieveResourceValues
        case notADirectory
        case doesNotExist
        case other(Error)
    }
    
    func checkIfDirectory() throws -> Bool {
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir)
        
        if !exists {
            return false
        } else if isDir.boolValue {
            return true
        } else {
            do {
                let resourceValues = try self.resourceValues(forKeys: [.isDirectoryKey])
                if let isDirectory = resourceValues.isDirectory {
                    return isDirectory
                } else {
                    throw DirectoryCheckError.unableToRetrieveResourceValues
                }
            } catch {
                throw error
            }
        }
    }
}
