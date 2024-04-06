//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol URLConvertible {
    var url: URL { get }
}

public protocol URLRepresentable: URLConvertible {
    init?(url: URL)
}

public protocol _ThrowingInitiableFromURL {
    init(url: URL) throws
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
