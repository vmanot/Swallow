//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol CustomSourceDeclarationReflectable {
    static var customSourceDeclarationMirror: _StaticSwift.SourceDeclarationMirror { get }
}

extension CustomSourceDeclarationReflectable {
    public static var customSourceDeclarationMirror: _StaticSwift.SourceDeclarationMirror {
        nil
    }
}

extension _StaticSwift {
    public struct SourceDeclarationMirror: ExpressibleByNilLiteral {
        public let sourceLocation: SourceCodeLocation?
                
        public init(
            fileID: StaticString = #fileID,
            function: StaticString = #function,
            line: UInt = #line,
            column: UInt? = nil
        ) {
            self.sourceLocation = SourceCodeLocation(
                fileID: fileID,
                function: function,
                line: line,
                column: column
            )
        }
        
        public init(nilLiteral: ()) {
            self.sourceLocation = nil
        }
    }
}
