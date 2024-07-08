//
// Copyright (c) Vatsal Manot
//

import Foundation
import FoundationX
import ObjectiveC
import Swallow

public struct ObjCTypeEncoding: Hashable, Wrapper, Sendable {
    public typealias Value = String
    
    public let value: String
    
    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Extensions

extension ObjCTypeEncoding {
    public static var unknown = Self("?")
    public static var void = Self("v")
    
    public var isSizeZero: Bool {
        self == .void || ((try? TypeMetadata(toMetatype()).isSizeZero) ?? false)
    }
    
    public var losingNominalPrecision: ObjCTypeEncoding {
        var resultValue = value
        
        resultValue.replace(RegularExpression().match("\"").match(.word).match("\""), with: "")
        resultValue.replace(RegularExpression().match("{").match(.word).match("="), with: "{")
        resultValue.replace(RegularExpression().match("(").match(.word).match("="), with: "(")
        
        return .init(resultValue)
    }
    
    public func encapsulatingInBraces() -> ObjCTypeEncoding {
        return .init("{\(value)}")
    }
}

// MARK: - Conformances

extension ObjCTypeEncoding: AdditionOperatable {
    public static func + (lhs: ObjCTypeEncoding, rhs: ObjCTypeEncoding) -> ObjCTypeEncoding {
        return .init(lhs.value + rhs.value)
    }
    
    public static func + (lhs: String, rhs: ObjCTypeEncoding) -> ObjCTypeEncoding {
        return .init(lhs) + rhs
    }
    
    public static func + (lhs: ObjCTypeEncoding, rhs: String) -> ObjCTypeEncoding {
        return lhs + .init(rhs)
    }
}

extension ObjCTypeEncoding: CustomStringConvertible {
    public var description: String {
        String(describing: value)
    }
}

extension ObjCTypeEncoding: StringInitializable, StringConvertible {
    public var stringValue: String {
        return value
    }
    
    public init(stringValue: String) {
        self.init(stringValue)
    }
}

// MARK: - Auxiliary Extensions

extension ObjCTypeEncoding {
    public var sizeAndAlignmentInBytes: (size: Int, alignment: Int) {
        var result = (size: 0, alignment: 0)
        NSGetSizeAndAlignment(value, &result.size, &result.alignment)
        return result
    }
    
    public var sizeInBytes: Int {
        get throws {
            if value.hasPrefix("{") && value.hasSuffix("}") {
                if value.contains("RESERVED") {
                    throw Never.Reason.unsupported
                }
            }
            
            var result = 0
            NSGetSizeAndAlignment(value, &result, nil)
            return result
        }
    }
    
    public var alignmentInBytes: Int {
        var result = 0
        NSGetSizeAndAlignment(value, nil, &result)
        return result
    }
}

extension ObjCTypeEncoding {
    public init(
        returnTypeFrom nsMethodSignature: NSMethodSignatureProtocol
    ) {
        self.init(String(cString: nsMethodSignature.methodReturnType))
    }
}
