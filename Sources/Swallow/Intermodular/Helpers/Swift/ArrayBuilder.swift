//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@resultBuilder
public struct _NaiveArrayBuilder<Element> {
    public static func buildBlock() -> [Element] {
        []
    }
    
    public static func buildBlock(_ element: Element) -> [Element] {
        [element]
    }
    
    public static func buildBlock(_ elements: Element...) -> [Element] {
        elements
    }
        
    public static func buildIf(_ content: Element?) -> [Element] {
        if let content = content {
            return [content]
        } else {
            return []
        }
    }
    
    public static func buildEither(first: Element) -> [Element] {
        [first]
    }
    
    public static func buildEither(second: Element) -> [Element] {
        [second]
    }
    
    public static func buildPartialBlock(
        first: Element
    ) -> [Element] {
        [first]
    }
        
    public static func buildPartialBlock(
        accumulated: [Element],
        next: Element
    ) -> [Element] {
        accumulated + [next]
    }
}

@resultBuilder
public struct ArrayBuilder {
    @_optimize(speed)
    @_transparent
    public static func buildBlock<Element>() -> [Element] {
        []
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildBlock<Element>(_ element: Element) -> [Element] {
        [element]
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildBlock<Element>(_ elements: Element...) -> [Element] {
        elements
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildBlock<Element>(_ elements: [Element]) -> [Element] {
        elements
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildIf<Element>(_ content: Element?) -> [Element] {
        if let content = content {
            return [content]
        } else {
            return []
        }
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildEither<Element>(first: Element) -> [Element] {
        [first]
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildEither<Element>(second: Element) -> [Element] {
        [second]
    }
}

@resultBuilder
public struct _SpecializedArrayBuilder<Element> {
    @_optimize(speed)
    @_transparent
    public static func buildBlock() -> [Element] {
        []
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildBlock(_ element: Element) -> [Element] {
        [element]
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildBlock(_ elements: Element...) -> [Element] {
        elements
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildBlock(_ elements: [Element]) -> [Element] {
        elements
    }

    @_optimize(speed)
    @_transparent
    public static func buildIf(_ content: Element?) -> [Element] {
        if let content = content {
            return [content]
        } else {
            return []
        }
    }
    
    @_disfavoredOverload
    public static func buildIf(_ content: [Element]?) -> [Element] {
        if let content = content {
            return content
        } else {
            return []
        }
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildEither(first: Element) -> [Element] {
        [first]
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildEither(first: [Element]) -> [Element] {
        first
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildEither(second: Element) -> [Element] {
        [second]
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildEither(second: [Element]) -> [Element] {
        second
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildPartialBlock(
        first: Element
    ) -> [Element] {
        [first]
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildPartialBlock(
        first: [Element]
    ) -> [Element] {
        first
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildPartialBlock(
        accumulated: [Element],
        next: Element
    ) -> [Element] {
        accumulated + [next]
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildPartialBlock(
        accumulated: [Element],
        next: [Element]
    ) -> [Element] {
        accumulated + next
    }
}

extension Array {
    public static func flattening(
        @_SpecializedArrayBuilder<Element> content: () -> [Element]
    ) -> Self {
        content()
    }
}
