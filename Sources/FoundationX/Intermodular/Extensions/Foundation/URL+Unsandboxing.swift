//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

extension URL {
    var _unsandboxedURL: URL {
        estimatedUnsandboxedURL ?? self
    }
    
    fileprivate var _estimatedUnsandboxedPath: String? {
        guard let bundleIdentifier: String = Bundle.main.bundleIdentifier else {
            return nil
        }
        
        let sandboxPrefix: String = "/Users/\(NSUserName())/Library/Containers/\(bundleIdentifier)/Data"
        let nonSandboxPrefix: String = "/Users/\(NSUserName())/"
        
        guard self.path.hasPrefix(sandboxPrefix) else {
            return nil
        }
        
        var result: String = String(
            self.path
                .dropPrefixIfPresent(sandboxPrefix)
                .dropPrefixIfPresent("/")
                .dropSuffixIfPresent("/")
        )

        assert(nonSandboxPrefix.hasSuffix("/"))
        
        result = nonSandboxPrefix + result
        
        let url = URL(fileURLWithPath: result)
        
        if url.path.contains("//") {
            runtimeIssue("Malformed URL: \(self)")
        }
        
        return result
    }
    
    fileprivate var estimatedUnsandboxedURL: URL? {
        _estimatedUnsandboxedPath.map({ URL(fileURLWithPath: $0) })
    }
}

extension URL {
    enum _CanonicalFileDirectoryPathNameOptions: String, CaseIterable, URLConvertible {
        case home = "~"
        case desktop = "~/Desktop"
        case documents = "~/Documents"
        case downloads = "~/Downloads"
        case applications = "/Applications"
        case library = "~/Library"
        
        var url: URL {
            URL(fileURLWithPath: rawValue)
        }
    }
    
    static var _allUnsandboxedCanonicalFileDirectoryPaths: Set<String> {
        Set(_CanonicalFileDirectoryPathNameOptions.allCases.map(\.url).map(\._unsandboxedURL).map(\.path))
    }
    
    static func _sandboxedCanonicalDirectory(
        _ directoryPath: _CanonicalFileDirectoryPathNameOptions
    ) -> URL! {
        switch directoryPath {
            case .home:
                return URL(fileURLWithPath: NSHomeDirectory())
            case .desktop:
                return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
            case .documents:
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            case .downloads:
                return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            case .applications:
                return FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first
            case .library:
                return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        }
    }
    
    public var _isCanonicalDirectoryURL: Bool {
        if path == URL(fileURLWithPath: NSHomeDirectory())._unsandboxedURL.path {
            return true
        }
        
        return URL._allUnsandboxedCanonicalFileDirectoryPaths.contains(self.path)
    }
}

extension URL {
    public static var _developerXcodeDerivedData: URL {
        URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Developer/Xcode/DerivedData")
    }
}
