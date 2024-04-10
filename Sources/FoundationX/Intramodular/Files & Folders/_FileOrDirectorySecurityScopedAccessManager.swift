//
// Copyright (c) Vatsal Manot
//

#if canImport(Cocoa)
import AppKit
import Cocoa
#endif
import Foundation
import Swallow

#if os(macOS)
extension _FileOrDirectorySecurityScopedAccessManager {
    @MainActor
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        let isDirectory = FileManager.default.isDirectory(at: url)
        
        guard isDirectory else {
            let url = try promptForAccess(to: url, isDirectory: isDirectory)
            
            let bookmarkedURL = try url._accessingSecurityScopedResource {
                try URL._BookmarksCache.bookmark(url)
            }
            
            return bookmarkedURL
        }
        
        if let cachedURL = try? URL._BookmarksCache.cachedURL(for: url) {
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
            if let ancestorURL = FileManager.default.nearestAccessibleSecurityScopedAncestor(for: url) {
                let bookmarkedURL = try? ancestorURL._accessingSecurityScopedResource {
                    if !FileManager.default.fileExists(at: url) {
                        try FileManager.default.createDirectoryIfNecessary(
                            at: url,
                            withIntermediateDirectories: true
                        )
                    }
                    
                    return try URL._BookmarksCache.bookmark(url)
                }
                
                if let bookmarkedURL {
                    return bookmarkedURL
                }
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
    
    @MainActor
    private static func promptForAccess(
        to url: URL,
        isDirectory: Bool
    ) throws -> URL {
        let openPanelDelegate = _NSOpenSavePanelDelegate(url: url)
        let openPanel = configureOpenPanel(for: url, isDirectory: isDirectory)
        
        openPanel.delegate = openPanelDelegate
        
        if ProcessInfo.processInfo._isRunningWithinXCTest {
            openPanel.becomeKey()
            openPanel.orderFront(nil)
        }
        
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
#else
extension _FileOrDirectorySecurityScopedAccessManager {
    public static func requestAccess(
        to url: URL
    ) throws -> URL {
        return url // FIXME: !!!
    }
}
#endif

// MARK: - Supplementary

extension FileManager {
    @frozen
    public enum _FileOrDirectoryAccessScopePreference: Hashable {
        case automatic
        case directory
    }
    
    @MainActor
    public func withUserGrantedAccess<T>(
        to urlRepresentable: some URLRepresentable,
        scope: _FileOrDirectoryAccessScopePreference = .automatic,
        perform operation: (URL) throws -> T
    ) throws -> T {
        let url = urlRepresentable.url
        
        switch scope {
            case .automatic:
                return try _withUserGrantedAccess(to: url, perform: operation)
            case .directory:
                if !url._isKnownOrIndicatedToBeFileDirectory {
                    let directoryURL = url._immediateFileDirectory
                    let lastPathComponent = url.lastPathComponent
                    
                    return try _withUserGrantedAccess(to: directoryURL) { directoryURL in
                        let accessibleURL = directoryURL.appendingPathComponent(lastPathComponent, isDirectory: false)
                        
                        return try operation(accessibleURL)
                    }
                } else {
                    return try _withUserGrantedAccess(to: url, perform: operation)
                }
        }
    }
    
    @MainActor
    public func withUserGrantedAccess<T>(
        to urlRepresentable: some URLRepresentable,
        scope: _FileOrDirectoryAccessScopePreference = .automatic,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
        let url = urlRepresentable.url
        
        switch scope {
            case .automatic:
                return try await _withUserGrantedAccess(to: url, perform: operation)
            case .directory:
                if !url._isKnownOrIndicatedToBeFileDirectory {
                    let directoryURL = url._immediateFileDirectory
                    let lastPathComponent = url.lastPathComponent
                    
                    return try await _withUserGrantedAccess(to: directoryURL) { directoryURL in
                        let accessibleURL = directoryURL.appendingPathComponent(lastPathComponent, isDirectory: false)
                        
                        return try await operation(accessibleURL)
                    }
                } else {
                    return try await _withUserGrantedAccess(to: url, perform: operation)
                }
        }
    }
    
    @MainActor
    private func _withUserGrantedAccess<T>(
        to url: URLRepresentable,
        perform operation: (URL) throws -> T
    ) throws -> T {
        var url: URL = url.url
        
        do {
            if FileManager.default.isReadable(at: url), url.isKnownSecurityScopedAccessExempt {
                return try url._accessingSecurityScopedResource {
                    return try operation(url)
                }
            }
        } catch {
            runtimeIssue(error)
        }
        
        url = try _FileOrDirectorySecurityScopedAccessManager.requestAccess(to: url)
        
        return try url._accessingSecurityScopedResource {
            try operation(url)
        }
    }
    
    @MainActor
    private func _withUserGrantedAccess<T>(
        to url: URLRepresentable,
        perform operation: (URL) async throws -> T
    ) async throws -> T {
        var url: URL = url.url
        
        do {
            if FileManager.default.isReadable(at: url), url.isKnownSecurityScopedAccessExempt {
                return try await url._accessingSecurityScopedResource {
                    return try await operation(url)
                }
            }
        } catch {
            runtimeIssue(error)
        }
        
        url = try _FileOrDirectorySecurityScopedAccessManager.requestAccess(to: url)
        
        return try await url._accessingSecurityScopedResource {
            try await operation(url)
        }
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
