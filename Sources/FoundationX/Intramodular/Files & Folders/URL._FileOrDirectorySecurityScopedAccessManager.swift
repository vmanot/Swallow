//
// Copyright (c) Vatsal Manot
//

#if canImport(Cocoa)
import AppKit
import Cocoa
#endif
import Foundation
import Swallow

extension URL {
    public enum _FileOrDirectorySecurityScopedAccessManager {
        @frozen
        public enum PreferredScope: Hashable {
            case automatic
            case directory
        }
    }
}

extension URL._FileOrDirectorySecurityScopedAccessManager {
    @MainActor
    public static func requestAccess(
        to directory: _UserHomeDirectoryName
    ) throws -> URL {
        try self.requestAccess(to: directory.url)
    }
}

#if os(macOS)
extension URL._FileOrDirectorySecurityScopedAccessManager {
    @MainActor
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        let fileManager = FileManager.default
        let isDirectory = FileManager.default.isDirectory(at: url)
        
        if fileManager.fileExists(at: url) {
            guard isDirectory else {
                let url = try promptForAccess(to: url, isDirectory: isDirectory)
                
                let bookmarkedURL = try url._accessingSecurityScopedResource {
                    try URL._SavedBookmarks.bookmark(url)
                }
                
                return bookmarkedURL
            }
        }
        
        if let cachedURL = try? URL._SavedBookmarks.bookmarkedURL(for: url) {
            do {
                if isDirectory {
                    try _testWritingFile(inDirectory: cachedURL)
                }
                
                return cachedURL
            } catch {
                let url = try promptForAccess(to: url, isDirectory: isDirectory)
                
                do {
                    if isDirectory {
                        try _testWritingFile(inDirectory: url)
                    }
                } catch {
                    assertionFailure(error)
                }
                
                return url
            }
        } else {
            if let ancestorURL = fileManager.nearestAccessibleSecurityScopedAncestor(for: url) {
                do {
                    let bookmarkedURL = try ancestorURL._accessingSecurityScopedResource {
                        if !fileManager.fileExists(at: url) {
                            try fileManager.createDirectoryIfNecessary(
                                at: url,
                                withIntermediateDirectories: true
                            )
                        }
                        
                        return try URL._SavedBookmarks.bookmark(url)
                    }
                    
                    return bookmarkedURL
                } catch {
                    if !fileManager.fileExists(at: url), let (directory, path) = fileManager.nearestAncestor(for: url, where: { fileManager.directoryExists(at: $0) }) {
                        
                        let accessibleDirectory = try promptForAccess(to: directory, isDirectory: true)
                        
                        return try accessibleDirectory._accessingSecurityScopedResource {
                            let reconstructedURL = accessibleDirectory.appending(path)
                            
                            try FileManager.default.createDirectory(
                                at: reconstructedURL,
                                withIntermediateDirectories: true
                            )
                            
                            let result = try URL._SavedBookmarks.bookmark(reconstructedURL)
                            
                            return result
                        }
                    }
                }
            }
            
            let accessibleURL = try promptForAccess(to: url, isDirectory: isDirectory)
            
            let result = try URL._SavedBookmarks.bookmark(accessibleURL)

            do {
                try _testWritingFile(inDirectory: url)
            } catch {
                assertionFailure()
            }
            
            return result
        }
    }
    
    private static func _testWritingFile(
        inDirectory url: URL
    ) throws {
        guard _isDebugAssertConfiguration else {
            return
        }
                
        guard FileManager.default.isReadableAndWritable(at: url) else {
            runtimeIssue("Failed to write test file within \(url)")
            
            return
        }

        let testFileURL: URL = url.appendingPathComponent(".temp_test_file")._fromURLToFileURL()
        
        _ = url.startAccessingSecurityScopedResource()
        
        do {
            try "test".write(to: testFileURL, atomically: true, encoding: .utf8)
         
            try FileManager.default.removeItem(at: testFileURL)
            
            url.stopAccessingSecurityScopedResource()
        } catch {
            url.stopAccessingSecurityScopedResource()
            
            throw error
        }
    }
    
    @MainActor
    private static func promptForAccess(
        to url: URL,
        isDirectory: Bool
    ) throws -> URL {
        let openPanelDelegate = _NSOpenSavePanelDelegate(url: url)
        let openPanel: NSOpenPanel = configureOpenPanel(for: url, isDirectory: isDirectory)
        
        openPanel.delegate = openPanelDelegate
        
        if ProcessInfo.processInfo._isRunningWithinXCTest {
            openPanel.becomeKey()
            openPanel.orderFront(nil)
            
            DispatchQueue.main.async {
                openPanel.becomeKey()
                openPanel.orderFront(nil)
            }
        }
        
        let response = openPanel.runModal()
        
        switch response {
            case .OK, .continue:
                guard let selectedURL = openPanel.url else {
                    throw _Error.accessDenied
                }
                
                do {
                    return try URL._SavedBookmarks.bookmark(selectedURL)
                } catch {
                    runtimeIssue(error)
                    
                    return selectedURL
                }
            case .abort:
                throw _Error.accessCancelled
            default:
                throw _Error.accessDenied
        }
    }
    
    private static func configureOpenPanel(
        for url: URL,
        isDirectory: Bool
    ) -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        
        openPanel.directoryURL = url.deletingLastPathComponent()
        openPanel.canChooseFiles = true
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
            let directoryName = _UserHomeDirectoryName(from: url)?.rawValue ?? "selected"
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
            assert(!url.path.hasPrefix("//"))
          
            self.currentURL = url._isRelativeFilePath ? url.resolvingSymlinksInPath() : url
            self.isDirectory = url._isKnownOrIndicatedToBeFileDirectory
            
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
            let url = url._filePath
            let currentURL = self.currentURL._filePath
            
            if isDirectory == true {
                guard url == currentURL else {
                    throw NSError.genericApplicationError(
                        description: "Incorrect directory.",
                        recoverySuggestion: "Select the directory “\(currentURL)”."
                    )
                }
            } else {
                guard url == currentURL else {
                    throw NSError.genericApplicationError(
                        description: "Incorrect file.",
                        recoverySuggestion: "Select the file “\(currentURL)”."
                    )
                }
            }
        }
    }
}
#else
extension URL._FileOrDirectorySecurityScopedAccessManager {
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        return url // FIXME: !!!
    }
}
#endif

// MARK: - Error Handling

extension URL._FileOrDirectorySecurityScopedAccessManager {
    @_spi(Internal)
    public enum _Error: Hashable, Error {
        case accessDenied
        case accessCancelled
        case invalidDirectory
        case other(AnyError)
        
        @_disfavoredOverload
        public static func other(_ error: Error) -> AnyError {
            AnyError(erasing: error)
        }
    }
}
