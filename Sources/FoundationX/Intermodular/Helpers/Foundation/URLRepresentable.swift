//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol _URLConvertible {
    var url: URL { get }
}

public protocol URLConvertible: _URLConvertible {
    var url: URL { get }
}

public protocol _FailableInitiableFromURL {
    init?(url: URL)
}

public protocol _ThrowingInitiableFromURL {
    init(url: URL) throws
}

public protocol URLRepresentable: _FailableInitiableFromURL, URLConvertible {
    var url: URL { get }

    init?(url: URL)
}

extension _FailableInitiableFromURL {
    public init?(filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        
        self.init(url: url)
    }
}

extension _ThrowingInitiableFromURL {
    public init(filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        
        try self.init(url: url)
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
