//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

extension URL {
    public var _isSandboxedURL: Bool? {
        get {
            guard let bundleIdentifier: String = Bundle.main.bundleIdentifier else {
                return nil
            }

            let sandboxPrefix: String = "/Users/\(NSUserName())/Library/Containers/\(bundleIdentifier)/Data"
            
            guard self.path.hasPrefix(sandboxPrefix) else {
                return false
            }
            
            return true
        }
    }
    
    var _unsandboxedURL: URL {
        _estimatedUnsandboxedPath.map({ URL(fileURLWithPath: $0) }) ?? self
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
}
