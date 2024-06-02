//
// Copyright (c) Vatsal Manot
//

import Swift

/// A namespace for preprocessor-magic related structures.
public enum Preprocessor {
    /// A textual point in the source code of the program.
    public struct Point: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case file
            case fileID
            case function
            case line
            case column
        }

        public var file: String
        public var fileID: String?
        public var function: String?
        public var line: UInt?
        public var column: UInt?
        
        public init(
            file: StaticString,
            fileID: StaticString?,
            function: StaticString?,
            line: UInt?,
            column: UInt?
        ) {
            self.file = file.description
            self.fileID = fileID?.description
            self.function = function?.description
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
        
        public var _fileOrFileID: String {
            fileID?.description ?? file.description
        }
    }
}

extension Preprocessor.Point {
    public func drop(_ field: CodingKeys) -> Self {
        withMutableScope(self) {
            switch field {
                case .file:
                    fatalError("cannot drop file")
                case .fileID:
                    $0.fileID = nil
                case .function:
                    $0.function = nil
                case .line:
                    $0.line = nil
                case .column:
                    $0.column = nil
            }
        }
    }
}

// MARK: - Conformances

extension Preprocessor.Point: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        var result = "file: \(_fileOrFileID)"
        
        if let function {
            result += ", function: \(function)"
        }
        
        if let line {
            result += ", line: \(line)"
        }
        
        if line != nil, let column {
            result += ", column: \(column)"
        }
        
        return result
    }
    
    public var description: String {
        if let line {
            "\(_fileOrFileID):\(line)"
        } else {
            "\(_fileOrFileID)"
        }
    }
}
