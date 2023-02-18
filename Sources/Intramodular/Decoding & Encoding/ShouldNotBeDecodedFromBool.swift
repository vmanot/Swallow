//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

// https://github.com/apple/swift/pull/11885
public protocol ShouldNotBeDecodedFromBool: Decodable {
    init?(exactly number: NSNumber)
}

// MARK: - Conformances

extension Double: ShouldNotBeDecodedFromBool {

}

extension Float: ShouldNotBeDecodedFromBool {

}

extension Int: ShouldNotBeDecodedFromBool {

}

extension Int8: ShouldNotBeDecodedFromBool {

}

extension Int16: ShouldNotBeDecodedFromBool {

}

extension Int32: ShouldNotBeDecodedFromBool {

}

extension Int64: ShouldNotBeDecodedFromBool {

}

extension UInt: ShouldNotBeDecodedFromBool {

}

extension UInt8: ShouldNotBeDecodedFromBool {

}

extension UInt16: ShouldNotBeDecodedFromBool {

}

extension UInt32: ShouldNotBeDecodedFromBool {

}

extension UInt64: ShouldNotBeDecodedFromBool {

}
