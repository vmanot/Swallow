//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension URL {
    public init?(bundle: Bundle, fileName: String, extension: String?) {
        guard let url = bundle.url(forResource: fileName, withExtension: `extension`) else {
            return nil
        }
        
        self = url
    }
    
    public init?(bundle: Bundle, fileName: String, withOrWithoutExtension `extension`: String) {
        guard let url = URL(bundle: bundle, fileName: fileName, extension: `extension`) ?? URL(bundle: bundle, fileName: fileName, extension: nil) else {
            return nil
        }
        
        self = url
    }
}

extension URL {
    public var fileName: String? {
        lastPathComponent
    }
}

extension URL {
    /// The portion of a URL relative to a given base URL.
    public func relativeString(relativeTo baseURL: URL) -> String {
        TODO.whole(.addressEdgeCase, .refactor)

        if absoluteString.hasPrefix(baseURL.absoluteString) {
            return absoluteString
                .dropPrefixIfPresent(baseURL.absoluteString)
                .dropPrefixIfPresent("/")
        } else if let host = baseURL.url.host, absoluteString.hasPrefix(host) {
            return absoluteString
                .dropPrefixIfPresent(host)
                .dropPrefixIfPresent("/")
        } else {
            return relativeString
        }
    }
}

extension URL {
    public func appendingDirectoryPathComponent(_ pathComponent: String) -> URL {
        appendingPathComponent(pathComponent, isDirectory: true)
    }
}

extension URL {
    public subscript(keys: Set<URLResourceKey>) -> Result<URLResourceValues, Error> {
        .init(try resourceValues(forKeys: keys))
    }
    
    public subscript(key: URLResourceKey) -> Result<URLResourceValues, Error> {
        self[[key]]
    }

    public mutating func setResourceValues(_ body: (inout URLResourceValues) throws -> Void) throws {
        var values = URLResourceValues()
        
        try body(&values)
        
        try setResourceValues(values)
    }
}

extension URL {
    public static var userDocuments: URL! {
        try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask)
    }

    public static func securityAppGroupContainer(for identifier: String) throws -> URL {
        try FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier).unwrap()
    }
}

extension URL {
    /// A file path component suitable for a base URL to append.
    public struct PathComponent: Hashable, Sendable {
        public let rawValue: String
        public let isDirectory: Bool?

        public init(rawValue: String, isDirectory: Bool? = nil) {
            self.rawValue = rawValue
            self.isDirectory = isDirectory
        }
    }

    public mutating func append(_ component: PathComponent) {
        appendPathComponent(component.rawValue)
    }

    public func appending(_ component: PathComponent) -> URL {
        appendingPathComponent(component.rawValue)
    }
    
    public static func + (lhs: Self, rhs: PathComponent) -> Self {
        lhs.appending(rhs)
    }
}

extension URL {
    public var _queryParameters: [String: String]? {
        get {
            guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
                return nil
            }
            
            return queryItems.reduce(into: [String: String]()) { (result, item) in
                result[item.name] = item.value
            }
        } set {
            if newValue.isNilOrEmpty && URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems == nil {
                return
            }
            
            var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
            
            components.queryItems = newValue?.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            
            self = components.url!
        }
    }
}

extension URL {
    public var _removingPercentEncoding: URL {
        get throws {
            guard let decodedString = self.absoluteString.removingPercentEncoding else {
                throw _PlaceholderError()
            }
            
            return  try URL(string: decodedString).unwrap()
        }
    }
    
    public var _removingQueryParameterValueDelimeters: URL {
        var result = self
        
        result._queryParameters = _queryParameters?.compactMapValues {
            $0.replacingOccurrences(of: "\"", with: "")
        }
        
        return result
    }
}

extension URL.PathComponent {
    public static func directory(_ string: String) -> Self{
        Self(rawValue: string, isDirectory: true)
    }
}
