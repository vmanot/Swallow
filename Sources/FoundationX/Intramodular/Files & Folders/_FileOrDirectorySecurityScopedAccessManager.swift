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
public enum _FileOrDirectorySecurityScopedAccessManager {
    @MainActor
    public static func requestAccess(
        to directory: _UserHomeDirectory
    ) throws -> URL {
        try self.requestAccess(to: directory.url)
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
extension _FileOrDirectorySecurityScopedAccessManager {
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        fatalError(.unimplemented)
    }
}
#endif

#if os(macOS)
extension _FileOrDirectorySecurityScopedAccessManager {
    @MainActor
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        let isDirectory = FileManager.default.isDirectory(at: url)
        
        guard isDirectory else {
            let url = try promptForAccess(to: url, isDirectory: isDirectory)
            
            _ = url.startAccessingSecurityScopedResource()
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            return try URL._BookmarksCache.save(for: url)
        }
        
        if let resolvedURL = try URL._BookmarksCache.resolvedURL(for: url) {
            do {
                try _testWritingFile(inDirectory: resolvedURL)
                
                return resolvedURL
            } catch {
                let url = try promptForAccess(to: url, isDirectory: isDirectory)
                
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
                
                return try URL._BookmarksCache.save(for: url)
            }
            
            let url = try promptForAccess(to: url, isDirectory: isDirectory)
            
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
    
    private static func promptForAccess(
        to url: URL,
        isDirectory: Bool
    ) throws -> URL {
        let openPanel = configureOpenPanel(for: url, isDirectory: isDirectory)
        let response = openPanel.runModal()
        switch response {
            case .OK, .continue:
                guard let selectedURL = openPanel.url else {
                    throw _DirectoryOrFileAccessError.accessDenied
                }
                return selectedURL
            case .abort:
                throw _DirectoryOrFileAccessError.accessCancelled
            default:
                throw _DirectoryOrFileAccessError.accessDenied
        }
    }
    
    private static func configureOpenPanel(
        for url: URL,
        isDirectory: Bool
    ) -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        
        openPanel.directoryURL = isDirectory ? url : url.deletingLastPathComponent()
        openPanel.canChooseFiles = !isDirectory
        openPanel.canChooseDirectories = isDirectory
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.message = generateOpenPanelMessage(for: url, isDirectory: isDirectory)
        openPanel.prompt = "Grant Access"
        
        return openPanel
    }
    
    private static func generateOpenPanelMessage(
        for url: URL,
        isDirectory: Bool
    ) -> String {
        if isDirectory {
            let directoryName = _UserHomeDirectory(from: url)?.rawValue ?? "selected"
            return "Your app needs access to the \(directoryName) folder. Please select to grant access."
        } else {
            let fileName = url.lastPathComponent
            return "Your app needs access to \(fileName). Please select to grant access."
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
                        description: "Incorrect directory.",
                        recoverySuggestion: "Select the directory “\(currentURL)”."
                    )
                }
            } else {
                guard url == currentURL else {
                    throw NSError.appError(
                        description: "Incorrect file.",
                        recoverySuggestion: "Select the file “\(currentURL)”."
                    )
                }
            }
        }
    }
}
#endif

// MARK: - Supplementary

extension FileManager {
    public static func withTemporaryCopy<Result>(
        of url: URL,
        perform body: (URL) throws -> Result
    ) throws -> Result {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        try FileManager.default.copyItem(at: url, to: tempFileURL)
        
        let result = try body(tempFileURL)
        
        try FileManager.default.removeItem(at: tempFileURL)
        
        return result
    }
    
    @MainActor
    public func withUserGrantedAccess<T>(
        to url: URLRepresentable,
        perform operation: (URL) throws -> T
    ) throws -> T {
        var url: URL = url.url
        
        do {
            if FileManager.default.isReadable(at: url), url.isKnownSecurityScopedAccessExempt {
                return try operation(url)
            }
        } catch {
            runtimeIssue(error)
        }
        
        url = try _FileOrDirectorySecurityScopedAccessManager.requestAccess(to: url)
        
        guard url.startAccessingSecurityScopedResource() else {
            assertionFailure()
            
            throw _SecurityScopedResourceAccessError.invalidAccess
        }
        
        let result = try operation(url)
        
        url.stopAccessingSecurityScopedResource()
        
        return result
    }
    
    fileprivate enum _SecurityScopedResourceAccessError: Error {
        case invalidAccess
    }
}

// MARK: - Error Handling

extension NSError {
    static func appError(
        description: String,
        recoverySuggestion: String? = nil,
        domainPostfix: String? = nil
    ) -> Self {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? ""
        ]
        return .init(
            domain: domainPostfix.map { "\(Bundle.main.bundleIdentifier!) - \($0)" } ?? Bundle.main.bundleIdentifier!,
            code: 1,
            userInfo: userInfo
        )
    }
}

extension _FileOrDirectorySecurityScopedAccessManager {
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
