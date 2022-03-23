//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@resultBuilder
open class ArrayBuilder {
    public static func buildBlock<Element>() -> [Element] {
        []
    }

    public static func buildBlock<Element>(_ element: Element) -> [Element] {
        [element]
    }

    public static func buildBlock<Element>(_ elements: Element...) -> [Element] {
        elements
    }

    public static func buildBlock<Element>(_ elements: [Element]) -> [Element] {
        elements
    }
    
    public static func buildIf<Element>(_ content: Element?) -> [Element] {
        if let content = content {
            return [content]
        } else {
            return []
        }
    }
    
    public static func buildEither<Element>(first: Element) -> [Element] {
        [first]
    }
    
    public static func buildEither<Element>(second: Element) -> [Element] {
        [second]
    }
}
