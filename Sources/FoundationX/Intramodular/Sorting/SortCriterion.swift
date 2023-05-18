//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// Represents a sorting criterion.
public struct SortCriterion<T> {
    /// A custom comparator for objects of type `T`.
    public typealias Comparator = (T, T) -> ComparisonResult
    
    public enum Order {
        case ascending
        case descending
    }
    
    let property: PartialKeyPath<T>
    let order: Order
    let comparator: Comparator?
    
    init(
        property: PartialKeyPath<T>,
        order: Order = .ascending,
        comparator: Comparator? = nil
    ) {
        self.property = property
        self.order = order
        self.comparator = comparator
    }
}

