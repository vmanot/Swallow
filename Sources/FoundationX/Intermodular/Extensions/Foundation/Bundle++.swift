//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

extension Bundle {
    public struct ID: Codable, CustomStringConvertible, ExpressibleByStringLiteral, Hashable, Sendable {
        public let rawValue: String
        
        public var description: String {
            rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(from decoder: Decoder) throws {
            try self.init(rawValue: String(from: decoder))
        }
        
        public func encode(to encoder: Encoder) throws {
            try rawValue.encode(to: encoder)
        }
        
        public init(stringLiteral: String) {
            self.init(rawValue: stringLiteral)
        }
    }
    
    public var id: Bundle.ID? {
        bundleIdentifier.map(Bundle.ID.init(rawValue:))
    }
}

extension Bundle {
    private static let cache = NSCache<NSNumber, Bundle>()
    
    public class var current: Bundle? {
        let caller = Thread.callStackReturnAddresses[1]
        
        if let bundle = cache.object(forKey: caller) {
            return bundle
        }
        
        var info = Dl_info(
            dli_fname: nil,
            dli_fbase: nil,
            dli_sname: nil,
            dli_saddr: nil
        )
        
        dladdr(caller.pointerValue, &info)
        
        let imagePath = String(cString: info.dli_fname)
        
        for bundle in Bundle.allBundles + Bundle.allFrameworks {
            if let executablePath = bundle.executableURL?.resolvingSymlinksInPath().path,
               imagePath == executablePath {
                cache.setObject(bundle, forKey: caller)
                return bundle
            }
        }
        
        return nil
    }
}

extension Bundle {
    public var bundleName: String? {
        infoDictionary?[kCFBundleNameKey as String] as? String
    }
}

extension Bundle {
    public func _enumerateResourceURLs(
        for fileExtension: String? = nil
    ) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: bundleURL,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        
        var resourceURLs: [URL] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            if let fileExtension = fileExtension, fileURL.pathExtension != fileExtension {
                continue
            }
            
            if fileURL.hasDirectoryPath {
                resourceURLs.append(contentsOf: _enumerateResourceURLs(in: fileURL, fileExtension: fileExtension))
            } else {
                resourceURLs.append(fileURL)
            }
        }
        
        return resourceURLs
    }
    
    private func _enumerateResourceURLs(
        in directoryURL: URL,
        fileExtension: String? = nil
    ) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directoryURL, includingPropertiesForKeys: nil) else {
            return []
        }
        
        var resourceURLs: [URL] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            if let fileExtension = fileExtension, fileURL.pathExtension != fileExtension {
                continue
            }
            
            if fileURL.hasDirectoryPath {
                resourceURLs.append(contentsOf: _enumerateResourceURLs(in: fileURL, fileExtension: fileExtension))
            } else {
                resourceURLs.append(fileURL)
            }
        }
        
        return resourceURLs
    }

    public func _enumerateNonAppleBinaries() -> [URL] {
        let enumerator = FileManager.default.enumerator(at: self.bundleURL, includingPropertiesForKeys: nil)
        var nonAppleBinaries: [URL] = []
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let resourceValues = try? fileURL.resourceValues(forKeys: [.isExecutableKey])
            let isExecutable = resourceValues?.isExecutable ?? false
            
            if isExecutable {
                let isAppleBinary = fileURL.absoluteString.contains("/System/Library/") ||
                fileURL.absoluteString.contains("/usr/lib/")
                
                if !isAppleBinary {
                    nonAppleBinaries.append(fileURL)
                }
            }
        }
        
        return nonAppleBinaries
    }
}

// MARK: - Supplementary

extension Bundle.ID {
    public static var finder: Self = "com.apple.finder"
    public static var xcode: Self = "com.apple.dt.Xcode"
}
