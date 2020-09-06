//
// Copyright (c) Vatsal Manot
//

import Swift

// MARK: -

extension ImplementationForwarder where Self: Collection, ImplementationProvider: Collection, Self.Index == ImplementationProvider.Index {
    public var startIndex: Self.Index {
        return implementationProvider.startIndex
    }
    
    public var endIndex: Self.Index {
        return implementationProvider.endIndex
    }
    
    public func index(after index: Index) -> Index {
        return implementationProvider.index(after: index)
    }
    
    public func formIndex(after index: inout Index) {
        implementationProvider.formIndex(after: &index)
    }
}

extension ImplementationForwarder where Self: RandomAccessCollection, ImplementationProvider: RandomAccessCollection, Self.Index == ImplementationProvider.Index, Self.Indices == CountableRange<Self.Index>, Self.Index.Stride == Int {
    public var startIndex: Self.Index {
        return implementationProvider.startIndex
    }
    
    public var endIndex: Self.Index {
        return implementationProvider.endIndex
    }
    
    public func index(after index: Index) -> Index {
        return implementationProvider.index(after: index)
    }
    
    public func formIndex(after index: inout Index) {
        implementationProvider.formIndex(after: &index)
    }
}

extension ImplementationForwarder where Self: Collection, ImplementationProvider: Collection, Self.Index: Strideable, Self.Index == ImplementationProvider.Index {
    public var startIndex: Self.Index {
        return implementationProvider.startIndex
    }
    
    public var endIndex: Self.Index {
        return implementationProvider.endIndex
    }
    
    public func index(after index: Index) -> Index {
        return implementationProvider.index(after: index)
    }
    
    public func formIndex(after index: inout Index) {
        implementationProvider.formIndex(after: &index)
    }
}

extension ImplementationForwarder where Self: Collection, ImplementationProvider: Collection, Self.Element == ImplementationProvider.Element, Self.Index == ImplementationProvider.Index {
    public subscript(index: Index) -> Element {
        return implementationProvider[index]
    }
}

extension ImplementationForwarder where Self: Collection, ImplementationProvider: Collection, Self.Element == ImplementationProvider.Element, Self.Index == ImplementationProvider.Index, Self.SubSequence == ImplementationProvider.SubSequence {
    public subscript(bounds: Range<Index>) -> ImplementationProvider.SubSequence {
        return implementationProvider[bounds]
    }
}

// MARK: -

extension ImplementationForwarder where Self: Comparable, ImplementationProvider: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.implementationProvider < rhs.implementationProvider
    }
}

// MARK: -

extension ImplementationForwarder where Self: CustomDebugStringConvertible, ImplementationProvider: CustomDebugStringConvertible {
    public var debugDescription: String {
        return implementationProvider.debugDescription
    }
}

// MARK: -

extension ImplementationForwarder where Self: CustomStringConvertible, ImplementationProvider: CustomStringConvertible {
    public var description: String {
        return implementationProvider.description
    }
}

extension ImplementationForwarder where Self: CustomStringConvertible & Named, ImplementationProvider: CustomStringConvertible {
    public var description: String {
        return implementationProvider.description
    }
}

// MARK: -

extension ImplementationForwarder where Self: EitherRepresentable, ImplementationProvider: EitherRepresentable, Self.LeftValue == ImplementationProvider.LeftValue, Self.RightValue == ImplementationProvider.RightValue {
    public var eitherValue: Either<LeftValue, RightValue> {
        return implementationProvider.eitherValue
    }
    
    public init(_ value: Either<LeftValue, RightValue>) {
        self.init(implementationProvider: .init(value))
    }
}

// MARK: -

extension ImplementationForwarder where Self: Error, ImplementationProvider: Error {
    public var _domain: String {
        return implementationProvider._domain
    }
    
    public var _code: Int {
        return implementationProvider._code
    }
}

extension ImplementationForwarder where Self: Error & RawRepresentable, Self.RawValue: Error & SignedInteger, ImplementationProvider: Error & SignedInteger {
    public var _domain: String {
        return implementationProvider._domain
    }
    
    public var _code: Int {
        return implementationProvider._code
    }
}

extension ImplementationForwarder where Self: Error & RawRepresentable, Self.RawValue: Error & UnsignedInteger, ImplementationProvider: Error & UnsignedInteger {
    public var _domain: String {
        return implementationProvider._domain
    }
    
    public var _code: Int {
        return implementationProvider._code
    }
}

// MARK: -

extension ImplementationForwarder where Self: ExpressibleByArrayLiteral, ImplementationProvider: ExpressibleByArrayLiteral, Self.ArrayLiteralElement == ImplementationProvider.ArrayLiteralElement {
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(implementationProvider: (-*>ImplementationProvider.init as ((Array) -> ImplementationProvider))(elements))
    }
}

// MARK: -

extension ImplementationForwarder where Self: ExpressibleByDictionaryLiteral, ImplementationProvider: ExpressibleByDictionaryLiteral, Self.Key == ImplementationProvider.Key, Self.Value == ImplementationProvider.Value {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(implementationProvider: (-*>ImplementationProvider.init as ((Array) -> ImplementationProvider))(elements))
    }
}

// MARK: -

extension ImplementationForwarder where Self: ExpressibleByStringLiteral, ImplementationProvider: ExpressibleByStringLiteral, Self.StringLiteralType == ImplementationProvider.StringLiteralType {
    public init(stringLiteral value: StringLiteralType) {
        self.init(implementationProvider: .init(stringLiteral: value))
    }
}

// MARK: -

extension ImplementationForwarder where Self: Hashable, ImplementationProvider: Hashable {
    public func hash(into hasher: inout Hasher) {
        implementationProvider.hash(into: &hasher)
    }
}

extension ImplementationForwarder where Self: Hashable, ImplementationProvider: RawRepresentable, ImplementationProvider.RawValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        implementationProvider.rawValue.hash(into: &hasher)
    }
}

extension ImplementationForwarder where Self: Hashable, ImplementationProvider: Hashable & RawRepresentable, ImplementationProvider.RawValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        implementationProvider.hash(into: &hasher)
    }
}

// MARK: -

extension ImplementationForwarder where Self: Initiable, ImplementationProvider: Initiable {
    public init() {
        self.init(implementationProvider: ImplementationProvider.init())
    }
}

extension ImplementationForwarder where Self: Initiable & RangeReplaceableCollection, ImplementationProvider: Initiable & RangeReplaceableCollection {
    public init() {
        self.init(implementationProvider: ImplementationProvider.init())
    }
}

// MARK: -

extension ImplementationForwarder where Self: Numeric, ImplementationProvider: Numeric, Self.Magnitude == ImplementationProvider.Magnitude {
    public init?<T: BinaryInteger>(exactly source: T) {
        guard let provider = ImplementationProvider(exactly: source) else {
            return nil
        }
        
        self.init(implementationProvider: provider)
    }
    
    public var magnitude: Self.Magnitude {
        return implementationProvider.magnitude
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        return .init(implementationProvider: lhs.implementationProvider + rhs.implementationProvider)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        return .init(implementationProvider: lhs.implementationProvider - rhs.implementationProvider)
    }
    
    public static func * (lhs: Self, rhs: Self) -> Self {
        return .init(implementationProvider: lhs.implementationProvider * rhs.implementationProvider)
    }
}

// MARK: -

extension ImplementationForwarder where Self: RangeReplaceableCollection, ImplementationProvider: RangeReplaceableCollection {
    public init() {
        self.init(implementationProvider: ImplementationProvider.init())
    }
}

// MARK: -

extension ImplementationForwarder where Self: Sequence, ImplementationProvider: Sequence, Self.Iterator == ImplementationProvider.Iterator {
    public func makeIterator() -> Iterator {
        return implementationProvider.makeIterator()
    }
}

// MARK: -

extension ImplementationForwarder where Self: Strideable, ImplementationProvider: Strideable, Self.Stride == ImplementationProvider.Stride {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.implementationProvider < rhs.implementationProvider
    }

    public func distance(to other: Self) -> Stride {
        return implementationProvider.distance(to: other.implementationProvider)
    }
    
    public func advanced(by stride: Stride) -> Self {
        return .init(implementationProvider: implementationProvider.advanced(by: stride))
    }
}
