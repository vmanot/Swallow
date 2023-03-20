//
// Copyright (c) Vatsal Manot
//

import Swift

/// A namespace for preprocessor-magic related structures.
public enum Preprocessor {
    /// A textual point in the source code of the program.
    public struct Point: CustomStringConvertible, Hashable, Sendable {
        public var file: String
        public var fileID: String?
        public var function: String
        public var line: UInt
        public var column: UInt?
        
        public init(
            file: StaticString,
            fileID: StaticString?,
            function: StaticString,
            line: UInt,
            column: UInt?
        ) {
            self.file = file.description
            self.fileID = fileID?.description
            self.function = function.description
            self.line = line
            self.column = column
        }
        
        public init(
            file: String = #file,
            fileID: String?,
            function: String = #function,
            line: UInt = #line,
            column: UInt? = #column
        ) {
            self.file = file
            self.fileID = fileID
            self.function = function
            self.line = line
            self.column = column
        }
        
        public var debugDescription: String {
            if let column = column {
                return "file: \(file.description), function: \(function), line: \(line), column: \(column)"
            } else {
                return "file: \(file.description), function: \(function), line: \(line)"
            }
        }
        
        public var description: String {
            "\(fileID ?? file):\(line)"
        }
    }
}
