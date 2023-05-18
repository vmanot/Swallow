//
// Copyright (c) Vatsal Manot
//

import Swallow

public enum MergeSplitSequence<Element>: Initiable {
    indirect case merge(head: [MergeSplitSequence], tail: MergeSplitSequence)
    indirect case node(head: Element, tail: MergeSplitSequence)
    indirect case split(head: [MergeSplitSequence], tail: MergeSplitSequence)
    
    case none
    
    public init() {
        self = .none
    }
    
    public static func merge(_ head: [MergeSplitSequence]) -> MergeSplitSequence {
        return .merge(head: head, tail: .none)
    }
}

// MARK: - Extensions

extension MergeSplitSequence {
    public var pointsOfOrigin: [Element] {
        switch self {
            case .merge(let head, let tail):
                return head.flatMap({ $0.pointsOfOrigin }) + tail.pointsOfOrigin
            case .node(let head, let tail): do {
                let pointsOfOrigin = tail.pointsOfOrigin
                
                if pointsOfOrigin.isEmpty {
                    return [head]
                } else {
                    return pointsOfOrigin
                }
            }
            case .none:
                return []
            case .split(_, let tail):
                return tail.pointsOfOrigin
        }
    }
    
    public var isNone: Bool {
        if case .none = self {
            return true
        } else {
            return false
        }
    }
    
    public var nodeValue: (head: Element, tail: MergeSplitSequence)? {
        if case let .node(head, tail) = self {
            return (head, tail)
        } else {
            return nil
        }
    }
    
    public func toLinkedListIfPossible() -> LinkedList<Element>? {
        if isNone {
            return LinkedList<Element>.none
        }
        
        guard let nodeValue = nodeValue else {
            return nil
        }
        
        if let tail = nodeValue.tail.toLinkedListIfPossible() {
            return .node(head: nodeValue.head, tail: tail)
        } else {
            return nil
        }
    }
}

extension MergeSplitSequence {
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        self.init()
        
        for element in elements {
            append(element)
        }
    }
    
    public mutating func append(_ element: Element) {
        switch self {
            case .merge:
                self = .node(head: element, tail: self)
            case .node:
                self = .node(head: element, tail: self)
            case .split(let head, let tail):
                self = .split(head: head.map({ $0.appending(element) }), tail: tail)
            case .none:
                self = .node(head: element, tail: .none)
        }
    }
    
    public func appending(_ element: Element) -> MergeSplitSequence {
        return build(self, with: { $0.append($1) }, element)
    }
}

extension MergeSplitSequence {
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> MergeSplitSequence<T> {
        switch self {
            case .merge(let head, let tail):
                return .merge(head: try head.map({ try $0.map(transform) }), tail: try tail.map(transform))
            case .node(let head, let tail):
                return .node(head: try transform(head), tail: try tail.map(transform))
            case .split(let head, let tail):
                return .split(head: try head.map({ try $0.map(transform) }), tail: try tail.map(transform))
            case .none:
                return .none
        }
    }
}

// MARK: - Conformances

extension MergeSplitSequence: CustomStringConvertible {
    public var description: String {
        if let linkedList = toLinkedListIfPossible() {
            return linkedList.description
        } else {
            return "MergeSplitSequence"
        }
    }
}

extension MergeSplitSequence: Equatable where Element: Equatable {
    
}

extension MergeSplitSequence: Hashable where Element: Hashable {
    
}
