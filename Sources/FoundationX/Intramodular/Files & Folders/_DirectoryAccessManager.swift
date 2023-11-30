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
        try self.requestAccess(toDirectory: directory.url)
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
extension _DirectoryAccessManager {
    public static func requestAccess(
        toDirectory directory: URL
    ) throws -> URL {
        fatalError(.unimplemented)
    }
}
#endif

#if os(macOS)
extension _DirectoryAccessManager {
    @MainActor
    public static func requestAccess(
        toDirectory url: URL
    ) throws -> URL {
        if let resolvedURL = try _SecurityScopedBookmarks.resolvedURL(for: url) {
            do {
                try _testWritingFile(inDirectory: resolvedURL)
                
                return resolvedURL
            } catch {
                let url = try _requestAccess(toDirectory: url)
                
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
                        
                        throw _DirectoryAccessError.invalidDirectory
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

            let url = try _requestAccess(toDirectory: url)
            
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
        toDirectory url: URL
    ) throws -> URL {
        let openPanel = NSOpenPanel()
        let openPanelDelegate = _NSOpenSavePanelDelegate(url: url)
        
        openPanel.delegate = openPanelDelegate
        
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = url
        
        let directoryName = _UserHomeDirectory(from: url)?.rawValue ?? "selected"
        let isKnownDirectory = _UserHomeDirectory(from: url) != nil
        
        openPanel.message = isKnownDirectory
            ? "Your app needs to access the \(directoryName) folder to continue. Please select the \(directoryName) folder to grant access."
            : "Your app needs to access a folder to continue. Please select the folder to grant access."
        
        openPanel.prompt = "Grant Access"
        
        let response: NSApplication.ModalResponse = openPanel.runModal()
        
        switch response {
            case .OK, .continue:
                if let _url = openPanel.url {
                    let result = try _SecurityScopedBookmarks.save(for: _url)
                    
                    return result
                } else {
                    throw _DirectoryAccessError.accessDenied
                }
            case .abort:
                throw _DirectoryAccessError.accessCancelled
            default:
                throw _DirectoryAccessError.accessDenied
        }
    }
    
    fileprivate final class _NSOpenSavePanelDelegate: NSObject, NSOpenSavePanelDelegate {
        let currentURL: URL
        
        init(url: URL) {
            self.currentURL = url.resolvingSymlinksInPath()
            
            super.init()
        }
        
        func panel(
            _ sender: Any,
            shouldEnable url: URL
        ) -> Bool {
            url._standardizedDirectoryPath == currentURL._standardizedDirectoryPath
        }
        
        func panel(
            _ sender: Any,
            validate url: URL
        ) throws {
            guard url._standardizedDirectoryPath == currentURL._standardizedDirectoryPath else {
                throw NSError.appError(
                    "Incorrect directory.",
                    recoverySuggestion: "Select the directory “\(currentURL)”."
                )
            }
        }
    }
}
#endif

extension NSError {
    /**
     Use this for generic app errors.
     
     - Note: Prefer using a specific enum-type error whenever possible.
     
     - Parameter description: The description of the error. This is shown as the first line in error dialogs.
     - Parameter recoverySuggestion: Explain how the user how they can recover from the error. For example, "Try choosing a different directory". This is usually shown as the second line in error dialogs.
     - Parameter userInfo: Metadata to add to the error. Can be a custom key or any of the `NSLocalizedDescriptionKey` keys except `NSLocalizedDescriptionKey` and `NSLocalizedRecoverySuggestionErrorKey`.
     - Parameter domainPostfix: String to append to the `domain` to make it easier to identify the error. The domain is the app's bundle identifier.
     */
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

public enum _SecurityScopedResourceAccessError: Error {
    case invalidAccess
}

extension FileManager {
    @MainActor
    public func withUserGrantedAccess<T>(
        toDirectory url: URLRepresentable,
        perform operation: (URL) throws -> T
    ) throws -> T {
        let url = url.url //try _DirectoryAccessManager.requestAccess(toDirectory: url.url)
        
        /*guard url.startAccessingSecurityScopedResource() else {
            assertionFailure()
            
            throw _SecurityScopedResourceAccessError.invalidAccess
        }*/
        
        let result = try operation(url)
        
      //  url.stopAccessingSecurityScopedResource()
        
        return result
    }
}

// MARK: - Auxiliary

extension URL {
    /// Adds the missing fucking "/" at the end.
    fileprivate var _standardizedDirectoryPath: String {
        path.addingSuffixIfMissing("/")
    }
}

// MARK: - Error Handling

extension _DirectoryAccessManager {
    @_spi(Internal)
    public enum _DirectoryAccessError: Error {
        case accessDenied
        case accessCancelled
        case invalidDirectory
        case other(Error)
    }
}

