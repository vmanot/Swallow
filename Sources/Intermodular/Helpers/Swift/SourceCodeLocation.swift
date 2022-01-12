//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type capable of representing the location of a line of code.
public enum SourceCodeLocation: CustomStringConvertible, Hashable, Static {
    case regular(file: String, line: UInt)
    case exact(Preprocessor.Point)
    case unavailable
    
    public init(_ point: Preprocessor.Point) {
        self = .exact(point)
    }
    
    public init(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt? = #column
    ) {
        self.init(Preprocessor.Point(file: file, function: function, line: line, column: column))
    }
    
    public init(
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt? = #column
    ) {
        self.init(Preprocessor.Point(file: file, function: function, line: line, column: column))
    }
    
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
