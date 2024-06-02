//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type capable of representing the location of a line of code.
public enum SourceCodeLocation: Codable, Hashable, SourceCodeLocationInitiable, Sendable {
    case regular(file: String, line: UInt)
    case exact(Preprocessor.Point)
    case unavailable
}

extension SourceCodeLocation {
    public var file: String? {
        switch self {
            case .regular(let file, _):
                return file
            case .exact(let point):
                return point.file
            case .unavailable:
                return nil
        }
    }
    
    public var function: String? {
        switch self {
            case .regular(_, _):
                return nil
            case .exact(let point):
                return point.function
            case .unavailable:
                return nil
        }
    }

    public var line: UInt? {
        switch self {
            case .regular(_, let line):
                return line
            case .exact(let point):
                return point.line
            case .unavailable:
                return nil
        }
    }
    
    public var column: UInt? {
        switch self {
            case .regular(_, _):
                return nil
            case .exact(let point):
                return point.column
            case .unavailable:
                return nil
        }
    }
}

extension SourceCodeLocation {
    public func drop(_ field: Preprocessor.Point.CodingKeys) -> Self {
        switch self {
            case .regular:
                fatalError()
            case .exact(let point):
                return .exact(point.drop(field))
            case .unavailable:
                return self
        }
    }
}

extension SourceCodeLocation {
    public init(_ point: Preprocessor.Point) {
        self = .exact(point)
    }
    
    public init(_ location: SourceCodeLocation) {
        self = location
    }
    
    public init(
        file: StaticString,
        fileID: StaticString? = nil,
        function: StaticString,
        line: UInt,
        column: UInt?
    ) {
        self.init(
            Preprocessor.Point(
                file: file,
                fileID: fileID,
                function: function,
                line: line,
                column: column
            )
        )
    }
        
    public init(
        fileID: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt? = nil
    ) {
        self.init(
            file: fileID,
            fileID: fileID,
            function: function,
            line: line,
            column: column
        )
    }
    
    public init(
        file: String,
        fileID: String? = nil,
        function: String,
        line: UInt,
        column: UInt?
    ) {
        self.init(
            Preprocessor.Point(
                file: file,
                fileID: fileID,
                function: function,
                line: line,
                column: column
            )
        )
    }
}

// MARK: - Conformances

extension SourceCodeLocation: CustomStringConvertible {
    public var description: String {
        switch self {
            case let .regular(file, line):
                return "file: \(file), line: \(line)"
            case let .exact(point):
                return point.description
            case .unavailable:
                return "<unavailable>"
        }
    }
}

// MARK: - Auxiliary

public protocol SourceCodeLocationInitiable {
    init(_ location: SourceCodeLocation)
}

extension SourceCodeLocationInitiable {
    public init(
        file: StaticString,
        fileID: StaticString? = nil,
        function: StaticString,
        line: UInt,
        column: UInt?
    ) {
        self.init(
            SourceCodeLocation(
                file: file,
                fileID: fileID,
                function: function,
                line: line,
                column: column
            )
        )
    }
    
    public init(
        file: String,
        fileID: String? = nil,
        function: String,
        line: UInt,
        column: UInt?
    ) {
        self.init(
            SourceCodeLocation(
                file: file,
                fileID: fileID,
                function: function,
                line: line,
                column: column
            )
        )
    }
}
