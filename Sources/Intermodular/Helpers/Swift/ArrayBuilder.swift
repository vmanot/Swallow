//
// Copyright (c) Vatsal Manot
//

import Swift

@resultBuilder
open class ArrayBuilder<Element> {
    @inlinable
    public static func buildBlock() -> [Element] {
        []
    }

    @inlinable
    public static func buildBlock(_ element: Element) -> [Element] {
        [element]
    }

    @inlinable
    public static func buildBlock(_ elements: Element...) -> [Element] {
        elements
    }

    @inlinable
    public static func buildBlock(_ elements: [Element]) -> [Element] {
        elements
    }
}
