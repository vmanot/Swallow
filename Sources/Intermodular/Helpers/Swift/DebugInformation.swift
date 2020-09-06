//
// Copyright (c) Vatsal Manot
//

import Swift

public struct DebugInformation: Hashable {
    public let message: String?
    public let origin: SourceCodeLocation?

    public init(message: String? = nil, origin: SourceCodeLocation?) {
        self.message = message
        self.origin = origin
    }

    public init(message: String? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) {
        self.message = message
        self.origin = .init(file: file, function: function, line: line, column: column)
    }
}
