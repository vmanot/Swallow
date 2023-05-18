//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A weighted type.
public protocol Weighted<Weight> {
    associatedtype Weight: Numeric
    
    var weight: Weight { get }
}

/// A weighted type whose weight can be changed.
public protocol MutableWeighted: Weighted {
    var weight: Weight { get set }
}
