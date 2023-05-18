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
    public var name: String? {
        infoDictionary?[kCFBundleNameKey as String] as? String
    }
}
