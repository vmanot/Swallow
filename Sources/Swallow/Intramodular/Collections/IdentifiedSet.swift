//
// Copyright (c) Vatsal Manot
//

import Swift

/// WIP type.
public struct _IdentifiedSet<Element: Hashable, ID: Hashable> {
    private var storage: IdentifierIndexedArray<Element, ID>
    
    var _id: (Element) -> ID {
        storage.id
    }
    
    fileprivate init(storage: IdentifierIndexedArray<Element, ID>) {
        self.storage = storage
    }
    
    public init(
        _ elements: some Sequence<Element>,
        id: @escaping (Element) -> ID
    ) {
        self.init(storage: .init(elements, id: id))
    }
    
    public init() where Element: Identifiable, ID == Element.ID {
        self.init(storage: .init(id: \.id))
    }
}

// MARK: - Conformances

extension _IdentifiedSet: Sendable where Element: Sendable, ID: Sendable {
    
}

extension _IdentifiedSet: Sequence {
    public var count: Int {
        storage.count
    }

    public func makeIterator() -> AnyIterator<Element> {
        AnyIterator(storage.makeIterator())
    }
    
    public mutating func removeAll(
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
        try storage.removeAll(where: { try shouldBeRemoved($0) })
    }
}
