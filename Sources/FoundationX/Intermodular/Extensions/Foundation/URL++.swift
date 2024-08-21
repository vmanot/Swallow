//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow
import System
import UniformTypeIdentifiers

extension URL {
    @_disfavoredOverload
    public init(_ url: URL, _: Void = ()) {
        self = url
    }
}

extension URL {
    /// The portion of a URL relative to a given base URL.
    public func relativeString(
        relativeTo baseURL: URL
    ) -> String {
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
    public var isWebURL: Bool {
        return scheme == "http" || scheme == "https"
    }

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

extension URL {
    public func isAncestor(of url: URL) -> Bool {
        if let scheme {
            guard scheme == url.scheme && host == url.host else {
                runtimeIssue("Invalid comparison.")
                
                return false
            }
        }
        
        // Get the path components of both URLs
        let selfComponents = pathComponents
        let urlComponents = url.pathComponents
        
        // Check if the current URL's path is a prefix of the given URL's path
        if selfComponents.count > urlComponents.count {
            return false
        }
        
        // Compare each path component
        for (index, component) in selfComponents.enumerated() {
            if component != urlComponents[index] {
                return false
            }
        }
        
        return true
    }
    
    public static func nearestCommonAncestor(_ items: some Collection<URL>) -> URL? {
        items._nearestCommonAncestor()
    }
}

// MARK: - Auxiliary

extension Collection where Element == URL {
    func _nearestCommonAncestor() -> URL? {
        guard !isEmpty else {
            return nil
        }
        
        guard count > 1 else {
            return first
        }
        
        let allComponents: [[String]] = map({ $0.pathComponents })
        let minLength = allComponents.map({ $0.count }).min() ?? 0
        
        var commonComponents: [String] = []
        
        for i in 0..<minLength {
            let componentsAtIndex = Set(allComponents.map { $0[i] })
            
            if componentsAtIndex.count == 1, let component = componentsAtIndex.first {
                commonComponents.append(component)
            } else {
                break
            }
        }
        
        guard !commonComponents.isEmpty else {
            return nil
        }
        
        let scheme = first?.scheme ?? "https"
        let host = (first?.host ?? "").trimmingCharacters(in: CharacterSet("/"))
        let path = commonComponents.joined(separator: "/").trimmingCharacters(in: CharacterSet("/"))
        
        return URL(string: "\(scheme)://\(host)/\(path)")
    }
}
