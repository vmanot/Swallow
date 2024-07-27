//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct _CurrentXcodeProject {
    @usableFromInline
    static let fileManager = FileManager.default
    
    public static func buildLogsPath() -> URL? {
        let environment = ProcessInfo.processInfo.environment
        
        if let derivedDataPath = environment["__XCODE_BUILT_PRODUCTS_DIR_PATHS"] {
            let logsDirectory = URL(fileURLWithPath: derivedDataPath)
                .appendingPathComponent("../../../Logs/Build")
                .resolvingSymlinksInPath()
            
            return logsDirectory
        }
        
        if _isDebugAssertConfiguration() {
            runtimeIssue("Failed to get build logs path.")
        }
        
        return nil
    }
    
    public struct RelevantFileList {
        public let xcodeproj: URL?
        public let infoPlist: URL?
    }
    
    @MainActor
    public static func relevantFileList(
        from initialPath: URL
    ) -> RelevantFileList {
        let xcodeprojURL: URL? = try? find(itemOfType: XcodeProject(), around: initialPath)
        let infoPlistURL: URL? = try? find(itemOfType: InfoPlist(), around: initialPath, selector: { plists in
            return plists.first
        })
        
        return RelevantFileList(
            xcodeproj: xcodeprojURL,
            infoPlist: infoPlistURL
        )
    }
    
    @MainActor
    public static func find<T: SearchableItem>(
        itemOfType type: T,
        around initialURL: URL,
        selector: (([URL]) -> URL?)? = nil
    ) throws -> URL? {
        guard !initialURL.path.hasPrefix(CanonicalFileDirectory.xcodeDerivedData.path) else {
            return nil
        }
                
        let result: URL? = try FileManager.default.withUserGrantedAccess(to: initialURL) { (url: URL) -> URL? in
            var currentURL: URL = url
            
            var result: Set<URL> = []
            
            while currentURL.path != "/" && !url.path.isEmpty {
                do {
                    let contents: [URL]? = try FileManager.default.withUserGrantedAccess(to: currentURL) { url -> [URL]? in
                        guard FileManager.default.isDirectory(at: url) else {
                            return nil
                        }
                        
                        return try fileManager.contentsOfDirectory(at: url)
                    }
                    
                    if let contents: [URL] = contents {
                        let matches: [URL] = contents.filter({ type.match(url: $0) })
                        
                        if !matches.isEmpty {
                            result.insert(contentsOf: matches)
                            
                            break
                        }
                    }
                } catch {
                    runtimeIssue(error)
                }
                
                let currentURLBeforeDeleting = currentURL
                
                currentURL.deleteLastPathComponent()
                
                guard currentURL != currentURLBeforeDeleting && !currentURL._hasUserHomeDirectoryPrefix else {
                    break
                }
            }
            
            if !result.isEmpty {
                return selector?(Array(result)) ?? result.first
            } else {
                return nil
            }
        }
        
        guard var result: URL else {
            return nil
        }
        
        result = try FileManager.default.withUserGrantedAccess(to: result) {
            try URL._SavedBookmarks.bookmark($0)
        }
        
        return result
    }
}

extension _CurrentXcodeProject {
    /// Update the UTI declarations in the Info.plist file for the given Xcode project using a list of UTI objects.
    @MainActor
    public static func updateUTTypes(
        _ utis: [_AppInfoPlist.UTI],
        file: String = #file
    ) throws {
        assert(!file.hasPrefix("//"))
        
        let file = try URL(string: file).unwrap()
        
        guard let plistURL: URL = relevantFileList(from: file).infoPlist else {
            fatalError("Error: Info.plist file not found.")
        }
        
        do {
            var plistData = try Data(contentsOf: plistURL)
            var plistFormat = PropertyListSerialization.PropertyListFormat.xml // Default format
            var plistDict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: &plistFormat) as? [String: Any]
            
            let documentTypesEncoder = PropertyListEncoder()
            documentTypesEncoder.outputFormat = .xml
            let documentTypesData = try documentTypesEncoder.encode(utis.generateDocumentTypes())
            let documentTypesArray = try PropertyListSerialization.propertyList(from: documentTypesData, options: [], format: &plistFormat) as? [[String: Any]]
            
            let utiEncoder = PropertyListEncoder()
            utiEncoder.outputFormat = .xml
            let utiData = try utiEncoder.encode(utis)
            let utiArray = try PropertyListSerialization.propertyList(from: utiData, options: [], format: &plistFormat) as? [[String: Any]]
            
            plistDict?["CFBundleDocumentTypes"] = documentTypesArray
            plistDict?["UTImportedTypeDeclarations"] = utiArray ?? []
            plistDict?["UTExportedTypeDeclarations"] = utiArray ?? []
            
            plistData = try PropertyListSerialization.data(fromPropertyList: plistDict!, format: plistFormat, options: 0)
            try plistData.write(to: plistURL)
            
            print("UTI declarations updated successfully.")
        } catch {
            print("Error updating UTI declarations: \(error)")
        }
    }
}

extension _CurrentXcodeProject {
    public protocol SearchableItem {
        var fileExtension: String { get }
        var fileName: String? { get }
        func match(url: URL) -> Bool
    }
    
    struct XcodeProject: SearchableItem {
        @usableFromInline
        let fileExtension = "xcodeproj"
        @usableFromInline
        let fileName: String? = nil
    }
    
    struct InfoPlist: SearchableItem {
        @usableFromInline
        let fileExtension = "plist"
        @usableFromInline
        let fileName: String? = "Info"
    }
}

extension _CurrentXcodeProject.SearchableItem {
    internal func match(
        url: URL
    ) -> Bool {
        return url.pathExtension == fileExtension && (fileName == nil || url.deletingPathExtension().lastPathComponent == fileName)
    }
}
