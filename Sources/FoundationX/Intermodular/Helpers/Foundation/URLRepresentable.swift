//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol URLResolvable {
    func withResolvedURL<R>(
        perform operation: (URL) throws -> R
    ) throws -> R
}

public protocol URLConvertible: URLResolvable {
    var url: URL { get }
}

public protocol URLInitiable {
    init?(url: URL) throws
}

public protocol URLRepresentable: URLConvertible, URLInitiable {
    var url: URL { get }
    
    init?(url: URL)
}

extension URLInitiable {
    public init?(filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        
        do {
            try self.init(url: url)
        } catch {
            runtimeIssue(error)
            
            return nil
        }
    }
}

extension URLConvertible {
    public func withResolvedURL<R>(
        perform operation: (URL) throws -> R
    ) throws -> R {
        try operation(url)
    }
}

// MARK: - API

extension String {
    public init(
        contentsOf urlRepresentable: URLRepresentable,
        encoding: Encoding
    ) throws {
        try self.init(contentsOf: urlRepresentable.url, encoding: encoding)
    }
}

extension OutputStream {
    public convenience init?(
        url urlRepresentable: URLRepresentable,
        append shouldAppend: Bool
    ) {
        self.init(url: urlRepresentable.url, append: shouldAppend)
    }
}

// MARK: - Conformances

extension URL: URLRepresentable {
    public var url: URL {
        return self
    }
    
    public init(url: URL) {
        self = url
    }
}
