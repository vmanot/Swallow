//
// Copyright (c) Vatsal Manot
//

import simd
import Swallow

extension simd.simd_quatd: Swallow.MutableArithmeticOperatable, Swift.Numeric {
    public var magnitude: Double {
        return length
    }
    
    public init?<T: BinaryInteger>(exactly source: T) {
        guard let real = Double(exactly: source) else {
            return nil
        }
        
        self.init(real: real, imag: .init())
    }
    
    public init(integerLiteral value: Double.IntegerLiteralType) {
        self.init(vector: simd_double4(x: .init(value), y: 0, z: 0, w: 0))
    }
}

extension simd.simd_quatf: Swallow.MutableArithmeticOperatable, Swift.Numeric {
    public var magnitude: Float {
        return length
    }

    public init?<T: BinaryInteger>(exactly source: T) {
        guard let real = Float(exactly: source) else {
            return nil
        }

        self.init(real: real, imag: .init())
    }

    public init(integerLiteral value: Float.IntegerLiteralType) {
        self.init(vector: simd_float4(x: .init(value), y: 0, z: 0, w: 0))
    }
}
