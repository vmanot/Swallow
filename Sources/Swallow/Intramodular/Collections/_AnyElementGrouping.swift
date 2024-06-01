//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _ElementGrouping<Element> {
    associatedtype Element
    
    func _eraseTo_AnyElementGrouping() -> _AnyElementGrouping<Element>
}

public enum _AnyElementGrouping<Element> {
    case single(Element)
    case set(any SetProtocol<Element>)
    case sequence(any Sequence<Element>)
    case ranked(_AnyRankedHierarchyGrouping<Element>)
}

// MARK: - Initializers

extension _AnyElementGrouping {
    public static func ranked(
        primary: Element
    ) -> Self {
        self.ranked(_AnyRankedHierarchyGrouping(primary: primary))
    }
    
    public static func ranked(
        primary: Element,
        secondary: Element
    ) -> Self {
        self.ranked(_AnyRankedHierarchyGrouping(primary: primary, secondary: secondary))
    }
    
    public static func ranked(
        primary: Element,
        secondary: Element,
        tertiary: Element
    ) -> Self {
        self.ranked(_AnyRankedHierarchyGrouping(primary: primary, secondary: secondary, tertiary: tertiary))
    }
}

// MARK: - Conformances

extension _AnyElementGrouping: Sequence  {
    public func makeIterator() -> AnyIterator<Element> {
        switch self {
            case .single(let element):
                return [element].makeIterator().eraseToAnyIterator()
            case .set(let set):
                return set.makeIterator()._opaque_eraseToAnyIterator() as! AnyIterator<Element>
            case .sequence(let sequence):
                return sequence._opaque_makeAndEraseIterator() as! AnyIterator<Element>
            case .ranked(let elements):
                return elements.makeIterator()
        }
    }
}

// MARK: - Implemented Conformances

extension Array: _ElementGrouping {
    public func _eraseTo_AnyElementGrouping() -> _AnyElementGrouping<Element> {
        .sequence(self)
    }
}

extension Set: _ElementGrouping {
    public func _eraseTo_AnyElementGrouping() -> _AnyElementGrouping<Element> {
        .set(self)
    }
}

// MARK: - Auxiliary

public struct _AnyRankedHierarchyGrouping<Element>: Sequence {
    public let primary: Element
    public let secondary: Element?
    public let tertiary: Element?
    
    public init(primary: Element) {
        self.primary = primary
        self.secondary = nil
        self.tertiary = nil
    }
    
    public init(primary: Element, secondary: Element?) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = nil
    }
    
    public init(primary: Element, secondary: Element?, tertiary: Element?) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        [primary, secondary, tertiary].lazy.compactMap({ $0 }).makeIterator().eraseToAnyIterator()
    }
}
