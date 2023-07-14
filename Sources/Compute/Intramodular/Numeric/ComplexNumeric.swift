//
// Copyright (c) Vatsal Manot
//

import simd
import Swallow

public protocol ComplexNumeric: Numeric {
    associatedtype Real: Numeric
    associatedtype Imaginary: Numeric
    
    var real: Real { get }
    var imaginary: Imaginary { get }
    
    init(real: Real, imaginary: Imaginary)
}

public protocol Quaternion: Numeric {
    associatedtype Real: Numeric
    associatedtype Imaginary
    
    var real: Real { get }
    var imaginary: Imaginary { get }
    
    init(real: Real, imaginary: Imaginary)
}
