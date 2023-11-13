//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct LazyTree<Base: HomogenousTree>: HomogenousTree {
    public typealias TreeValue = Base.TreeValue
    public typealias Children = LazyMapSequence<Base.Children, LazyTree<Base>>
    
    public let base: Base
    
    public var value: TreeValue {
        base.value
    }
    
    public var children: Children {
        base.children.lazy.map({ LazyTree(base: $0) })
    }
    
    public init(base: Base) {
        self.base = base
    }
}

extension HomogenousTree {
    public var lazy: LazyTree<Self> {
        .init(base: self)
    }
}

public struct LazyMapTree<Base: HomogenousTree, T>: HomogenousTree {
    public typealias TreeValue = T
    public typealias Children = LazyMapSequence<Base.Children, LazyMapTree<Base, T>>
    
    public let base: Base
    public let transform: (Base) -> T
    
    public var value: TreeValue {
        transform(base)
    }
    
    public var children: Children {
        base.children.lazy.map({ .init(base: $0, transform: transform) })
    }
    
    public init(
        base: Base,
        transform: @escaping (Base) -> T
    ) {
        self.base = base
        self.transform = transform
    }
}

public struct LazyCompactMapTree<Base: HomogenousTree, TreeValue>: HomogenousTree {
    public typealias Children = LazyMapSequence<LazyFilterSequence<LazyMapSequence<LazySequence<Base.Children>.Elements, Self?>>, Self>
    
    public let base: Base
    public let transform: (Base) -> TreeValue?
    public let value: TreeValue

    public var children: Children {
        base.children.lazy.compactMap({ Self(base: $0, transform: transform) })
    }
    
    public init?(
        base: Base,
        transform: @escaping (Base) -> TreeValue?
    ) {
        guard let value = transform(base) else {
            return nil
        }
        
        self.base = base
        self.transform = transform
        self.value = value
    }
}

extension LazyTree {
    public func map<T>(
        _ transform: @escaping (Base) -> T
    ) -> LazyMapTree<Base, T> {
        LazyMapTree(base: base, transform: transform)
    }
    
    public func compactMap<T>(
        _ transform: @escaping (Base) -> T?
    ) -> LazyCompactMapTree<Base, T>? {
        LazyCompactMapTree(base: base, transform: transform)
    }

    public func mapValues<T>(
        _ transform: @escaping (Base.TreeValue) -> T
    ) -> LazyMapTree<Base, T> {
        LazyMapTree(base: base, transform: { transform($0.value) })
    }
    
    public func compactMapValues<T>(
        _ transform: @escaping (Base.TreeValue) -> T
    ) -> LazyCompactMapTree<Base, T>? {
        LazyCompactMapTree(base: base, transform: { transform($0.value) })
    }
}

public struct IndexPathEnumeratedTree<Base: HomogenousTree>: HomogenousTree where Base.Children: Collection {
    public typealias TreeValue = Base.TreeValue
    
    public let indexPath: TreeIndexPath<Base>
    
    public let base: Base
    
    public var value: TreeValue {
        base.value
    }
    
    public var children: [Self] {
        base.children._enumerated().map {
            Self(indexPath: indexPath.appending($0.0), base: $0.1)
        }
    }
    
    private init(
        indexPath: TreeIndexPath<Base>,
        base: Base
    ) {
        self.indexPath = indexPath
        self.base = base
    }
    
    public init(base: Base) {
        self.init(indexPath: .init(), base: base)
    }
}

extension HomogenousTree where Children: Collection {
    public func _enumerated() -> IndexPathEnumeratedTree<Self> {
        .init(base: self)
    }
}
