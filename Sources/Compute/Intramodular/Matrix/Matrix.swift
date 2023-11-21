//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct Matrix<Element>: Initiable {
    public var rowCount: Int
    public var columnCount: Int
    public var storage: [Element]
    
    public init() {
        self.rowCount = 0
        self.columnCount = 0
        self.storage = []
    }
    
    public init(rowCount: Int, columnCount: Int, repeatedValue: Element) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.storage = .init(repeating: repeatedValue, count: rowCount * columnCount)
    }
}

// MARK: - Conformances

extension Matrix: MutableCollection {
    public typealias Index = Array<Element>.Index
    public typealias SubSequence = Array<Element>.SubSequence
    
    public var count: Int {
        storage.count
    }
    
    public var startIndex: Index {
        storage.startIndex
    }
    
    public var endIndex: Index {
        storage.endIndex
    }
    
    public subscript(_ index: Int) -> Element {
        get {
            storage[index]
        } set {
            storage[index] = newValue
        }
    }
    
    public subscript(bounds: Range<Array<Element>.Index>) -> Array<Element>.SubSequence {
        get {
            storage[bounds]
        } set {
            storage[bounds] = newValue
        }
    }
}

extension Matrix: MutableRowMajorRectangularCollection {
    public typealias Rows = LazyMapSequence<LazySequence<(Range<Int>)>.Elements, ArraySlice<Element>>
    public typealias Columns = LazyMapSequence<LazySequence<(Range<Int>)>.Elements, LazyMapSequence<(Range<Int>), Element>>
    
    public var width: Int {
        columnCount
    }
    
    public var rows: Rows {
        (0..<rowCount).lazy.map({ self[row: $0] })
    }
    
    public var columns: Columns {
        return (0..<rowCount).lazy.map { (rowIndex: Int) -> LazyMapSequence<LazySequence<(Range<Int>)>.Elements, Element> in
            (0..<columnCount).lazy.map { columnIndex in
                storage[(columnCount * rowIndex) + columnIndex]
            }
        }
    }
    
    public func index(forRow rowIndex: Rows.Index, column columnIndex: Columns.Index) -> Int {
        return (rowIndex * columnCount) + (columnIndex - columns.startIndex)
    }
    
    @inlinable
    public func range(forRow rowIndex: Rows.Index) -> Range<Index> {
        let startIndex = index(forRow: rowIndex, column: columns.startIndex)
        let endIndex = startIndex + columnCount
        
        return startIndex..<endIndex
    }
    
    @inlinable
    public subscript(rectangular position: Int) -> Element {
        get {
            storage[position]
        } set {
            storage[position] = newValue
        }
    }
    
    public subscript(row rowIndex: Int) -> ArraySlice<Element> {
        storage[range(forRow: rowIndex)]
    }
    
    public subscript(column columnIndex: Int) -> LazyMapSequence<(Range<Int>), Element> {
        columns[columnIndex]
    }
    
    public subscript(row rowIndex: Int, column columnIndex: Int) -> Element {
        get {
            self[rectangular: rowIndex * columnIndex]
        } set {
            self[rectangular: rowIndex * columnIndex] = newValue
        }
    }
    
    @inlinable
    public func makeRectangularIterator() -> AnyIterator<Element> {
        .init(rows.lazy.flatMap({ $0 }).makeIterator())
    }
}

extension Matrix: Sequence {
    public typealias Iterator = Array<Element>.Iterator
    
    public func makeIterator() -> Iterator {
        storage.makeIterator()
    }
}

// MARK: - Conditional Conformances

extension Matrix: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        rowCount = try container.decode(Int.self)
        columnCount = try container.decode(Int.self)
        storage = Array(capacity: rowCount * columnCount)
        
        for _ in 0..<count {
            storage.append(try container.decode(Element.self))
        }
    }
}

extension Matrix: Encodable where Element: Encodable {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(rowCount)
        try container.encode(columnCount)
        
        for element in storage {
            try container.encode(element)
        }
    }
}

extension Matrix: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return true
            && lhs.rowCount == rhs.rowCount
            && lhs.columnCount == rhs.columnCount
            && lhs.storage == rhs.storage
    }
}

extension Matrix: Hashable where Element: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rowCount)
        hasher.combine(columnCount)
        hasher.combine(storage)
    }
}

extension Matrix: Identifiable where Element: Identifiable {
    public var id: some Hashable {
        lazy.map({ $0.id })
    }
}
