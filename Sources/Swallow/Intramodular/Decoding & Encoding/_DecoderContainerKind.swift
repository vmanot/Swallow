//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// The kind of container vended by a `Decoder`.
public enum _DecoderContainerKind: Equatable {
    /// A single value decoding container.
    case singleValue
    
    /// An unkeyed decoding container.
    case unkeyed
    
    /// A keyed decoding container.
    case keyed(by: Metatype<any CodingKey.Type>)
}
