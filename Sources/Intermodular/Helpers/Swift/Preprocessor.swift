//
// Copyright (c) Vatsal Manot
//

import Swift

/// A namespace for preprocessor-magic related structures.
public enum Preprocessor {
    /// A textual point in the source code of the program.
    public struct Point: CustomStringConvertible, Hashable {
        public var file: String
        public var function: String
        public var line: UInt
        public var column: UInt
        
        public init(
            file: StaticString = #file,
            function: StaticString = #function,
            line: UInt = #line,
            column: UInt = #column
        ) {
            self.file = file.description
            self.function = function.description
            self.line = line
            self.column = column
        }
        
        public var description: String {
            return "file: \(file.description), function: \(function), line: \(line), column: \(column)"
        }
    }
}
