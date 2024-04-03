//
// Copyright (c) Vatsal Manot
//

import Swift

private typealias _AutoIncrementingIdentifierKey = Hashable2ple<AnyHashable, Metatype<Any.Type>>
private var counters: _LockedState<[_AutoIncrementingIdentifierKey: _LockedState<UInt>]> = .init(initialState: [:])

public struct _AutoIncrementingIdentifier<T>: Hashable, Codable, Sendable {
    private let file: String
    
    public let rawValue: UInt
    
    public var id: UInt {
        rawValue
    }
    
    private var key: _AutoIncrementingIdentifierKey {
        Hashable2ple((file, Metatype(T.self)))
    }
    
    public init(
        file: StaticString = #file
    ) {
        // Use the file ID and the type as a unique identifier.
        //
        // TODO: This probably should use the line number as well.
        let key: _AutoIncrementingIdentifierKey = Hashable2ple((AnyHashable(file.description), Metatype(T.self)))
        
        self.file = file.description
        self.rawValue = Self.nextID(key: key).withLock { value in
            defer {
                (value, _) = value.addingReportingOverflow(1)
            }
            
            return value
        }
    }
    
    @_transparent
    fileprivate static func nextID(
        key: _AutoIncrementingIdentifierKey
    ) -> _LockedState<UInt> {
        counters.withLock {
            $0[key, defaultInPlace: .init(initialState: 0)]
        }
    }
}

// MARK: - Conformances

extension _AutoIncrementingIdentifier: CustomStringConvertible {
    public var description: String {
        rawValue.description
    }
}

extension _AutoIncrementingIdentifier: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}
