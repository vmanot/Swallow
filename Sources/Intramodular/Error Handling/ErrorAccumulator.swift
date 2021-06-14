//
// Copyright (c) Vatsal Manot
//

import Swift

public struct ErrorAccumulator {
    private var data: [(SourceCodeLocation?, Error)]

    public init() {
        self.data = []
    }

    public mutating func add(_ error: Error, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) {
        if let error = error as? AccumulatedErrors {
            data += error.data
        } else {
            data.append((SourceCodeLocation(file: file, function: function, line: line, column: column), error))
        }
    }
        
    public func finalize(file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) -> AccumulatedErrors {
        return .init(data: data, file: file, function: function, line: line, column: column)
    }
}

/// Represents a log of errors accumulated over time.
public struct AccumulatedErrors: CustomStringConvertible, Error {
    fileprivate var data: [(location: SourceCodeLocation?, error: Error)]
    fileprivate var location: SourceCodeLocation?

    public init(data: [(location: SourceCodeLocation?, error: Error)], file: StaticString = #file, function: StaticString = #function, line: UInt = #line, column: UInt = #column) {
        self.data = data
        self.location = SourceCodeLocation(file: file, function: function, line: line, column: column)
    }

    public var description: String {
        var description: String = ""
        var indent: String = ""

        for (location, error) in data.reversed()  {
            if let location = location {
                description += indent + "From \(location.description):\n"
            }
            description += indent + error.localizedDescription
            indent += "\t"
        }

        return description
    }
}

// MARK: - Helpers -

extension Optional {
    public init(
        try expr: @autoclosure () throws -> Wrapped,
        errorAccumulator: inout ErrorAccumulator,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        do {
            self = .some(try expr())
        } catch {
            errorAccumulator.add(error, file: file, function: function, line: line, column: column)
            self = .none
        }
    }
}
