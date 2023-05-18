//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A sequence whose elements are laid out in a row & column layout.
///
/// e.g. `Matrix` is a `RectangularCollection`.
public protocol RectangularCollection: Collection {
    associatedtype Rows: Collection where Rows.Element: Collection, Rows.Element.Element == RectangularElement
    associatedtype Columns: Collection where Columns.Element: Collection, Columns.Element.Element == RectangularElement
    
    associatedtype RectangularElement = Element where Self.RectangularElement == RectangularIterator.Element
    associatedtype RectangularIndex: Comparable = Int
    associatedtype RectangularIterator: IteratorProtocol
    
    var rows: Rows { get }
    var columns: Columns { get }
    
    subscript(row _: Rows.Index, column _: Columns.Index) -> RectangularElement { get }
    
    func makeRectangularIterator() -> RectangularIterator
    
    subscript(rectangular position: RectangularIndex) -> RectangularElement { get }
    
    func index(forRow _: Rows.Index, column _: Columns.Index) -> RectangularIndex
}

/// A rectangular collection that supports subscript assignment.
public protocol MutableRectangularCollection: MutableCollection, RectangularCollection {
    var rows: Rows { get }
    var columns: Columns { get }
    
    subscript(row _: Rows.Index, column _: Columns.Index) -> RectangularElement { get set }
}

// MARK: - Implementation

extension RectangularCollection where Self: RowMajorRectangularCollection, Rows.Element.Index == Columns.Index {
    public subscript(row rowIndex: Rows.Index, column columnIndex: Columns.Index) -> RectangularElement {
        rows[rowIndex][columnIndex]
    }
    
    public subscript(column columnIndex: Columns.Index, row rowIndex: Rows.Index) -> RectangularElement {
        rows[rowIndex][columnIndex]
    }
}

extension MutableRectangularCollection where Self: RowMajorRectangularCollection, Rows.Element.Index == Columns.Index {
    public subscript(column columnIndex: Columns.Index, row rowIndex: Rows.Index) -> RectangularElement {
        get {
            self[row: rowIndex, column: columnIndex]
        } set {
            self[row: rowIndex, column: columnIndex] = newValue
        }
    }
}

extension RectangularCollection where Self: RowMajorRectangularCollection, Rows.Index == Int, Columns.Index == Int, RectangularIndex == Int {
    public func rowIndex(from index: RectangularIndex) -> Rows.Index {
        index / columns.count
    }
    
    public func columnIndex(from index: RectangularIndex) -> Columns.Index {
        index % columns.count
    }
}
