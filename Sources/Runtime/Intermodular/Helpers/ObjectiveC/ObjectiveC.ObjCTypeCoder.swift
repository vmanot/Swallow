//
// Copyright (c) Vatsal Manot
//

import Compute
import Foundation
import ObjectiveC
import Swallow

public struct ObjCTypeCoder {
    public static var registry = BidirectionalMap<TypeMetadata, ObjCTypeEncoding>()
}

extension ObjCTypeCoder {
    public static func encode(
        possibleClass type: Any.Type
    ) -> ObjCTypeEncoding? {
        switch TypeMetadata(type).kind {
            case .class, .foreignClass, .objCClassWrapper:
                return ObjCTypeEncoding("@")
            case .metatype:
                return ObjCTypeEncoding("#")
                
            default:
                return nil
        }
    }
    
    public static func encode(
        possibleSimple type: Any.Type
    ) -> ObjCTypeEncoding? {
        switch type {
            case AnyObject.self:
                return ObjCTypeEncoding("@")
            case UnsafePointer<CChar>.self:
                return ObjCTypeEncoding("*")
            case Void.self:
                return ObjCTypeEncoding("v")
                
            default:
                return nil
        }
    }
    
    public static func encode(_ type: Any.Type) throws -> ObjCTypeEncoding? {
        if let result = registry[TypeMetadata(type)] {
            return result
        } else if let result = try ((type as? (any OptionalProtocol.Type))?._opaque_Optional_WrappedType).map({ try encode($0) }) {
            return result
        } else if let result = try (type as? ObjCTypeEncodable.Type)?.objCTypeEncoding {
            return result
        } else if let result = encode(possibleSimple: type) {
            return result
        } else if let result = encode(possibleClass: type) {
            return result
        } else if let result = try encode(possibleStructure: type) {
            return result
        }
        
        return nil
    }
    
    public static func encode(possibleStructure type: Any.Type) throws -> ObjCTypeEncoding? {
        guard let type = TypeMetadata.Structure(type) else {
            return nil
        }
        
        var encodedTypes: [ObjCTypeEncoding] = []
        
        for field in type.fields {
            guard let encoded = try ObjCTypeCoder.encode(field.type.base) else {
                return nil
            }
            
            encodedTypes += encoded
        }
        
        if encodedTypes.count == 1 {
            return encodedTypes.first!
        } else {
            return encodedTypes.reduce(+)!.encapsulatingInBraces()
        }
    }
    
    public static func encode(unknownIfNil type: Any.Type) throws -> ObjCTypeEncoding {
        return try encode(type) ?? .unknown
    }
}

public protocol ObjCTypeContainerDecoderRule {
    static var prefix: String { get }
    static var suffix: String { get }
    
    static func process(_: [Any.Type]) throws -> Any.Type
}

extension ObjCTypeContainerDecoderRule {
    
}

extension ObjCTypeCoder {
    public static func decode(possibleSimple type: ObjCTypeEncoding) -> Any.Type? {
        switch type.value {
            case "c":
                return CChar.self
            case "i":
                return CInt.self
            case "s":
                return CShort.self
            case "l":
                return CLong.self
            case "q":
                return CLongLong.self
            case "C":
                return CUnsignedChar.self
            case "I":
                return CUnsignedInt.self
            case "S":
                return CUnsignedShort.self
            case "L":
                return CUnsignedLong.self
            case "Q":
                return CUnsignedLongLong.self
            case "f":
                return CFloat.self
            case "d":
                return CDouble.self
            case "B":
                return Bool.self
            case "v":
                return Void.self
            case "*":
                return UnsafePointer<CChar>.self
            case "@":
                return Optional<AnyObject>.self
            case "#":
                return Optional<AnyClass>.self
            case ":":
                return Selector.self
            case "?":
                fallthrough
                
            case "{_NSRange=QQ}":
                return NSRange.self
                
            default:
                return nil
        }
    }
}

extension ObjCTypeCoder {
    public static var rules: [ObjCTypeContainerDecoderRule.Type] = [
        ObjCTypeContainerDecoderRuleForConstantPointer.self,
        ObjCTypeContainerDecoderRuleForPointer.self,
        ObjCTypeContainerDecoderRuleForStructure.self,
        ObjCTypeContainerDecoderRuleForUnion.self
    ]
    
    public static func decode(
        atom encoding: String
    ) throws -> [Any.Type] {
        if encoding.contains("b") {
            let sizeInBits = encoding
                .replacingOccurrences(of: "b", with: "")
                .map({ (element: Character) in
                    Int(String(element))!
                })
                .reduce(0, +)
            
            return Array<Any.Type>(repeating: Byte.self, count: sizeInBits / 8)
        }
        
        return try encoding.map({ try decode(.init(.init($0))) })
    }
    
    public static func indent(
        _ value: RecursiveArray<String>
    ) -> RecursiveArray<String> {
        var value = value.flatteningToUnitIfNecessary()
        var needsIndent = false
        var indentCount: Int = 0
        
        for (index, element) in value.enumerated() {
            let index = index - indentCount
            
            if needsIndent {
                value[recursive: index] = [value[index - 1], .right(RecursiveArray(element).nested())]
                
                value.remove(at: index - 1)
                
                indentCount += 1
                
                needsIndent = false
            }
            
            if element.leftValue == "^" || element.leftValue == "r^" {
                needsIndent = true
            }
        }
        
        return value.flatteningToUnitIfNecessary()
    }
    
    public static func decode(
        _ encoding: RecursiveArray<String>
    ) throws -> Any.Type {
        let encoding = indent(encoding)
        
        if let unitValue = encoding.leftValue {
            return try ObjCTypeContainerDecoderRuleForNoRule.process(try decode(atom: unitValue))
        } else if let rule = (encoding.first?.leftValue).flatMap({ (prefix: String) in
            rules.find({ $0.prefix == prefix })
        }) {
            var encoding = encoding
            
            encoding.removeFirst()
            
            if !rule.suffix.isEmpty {
                if encoding.last != nil {
                    encoding.removeLast()
                }
            }
            
            if let unitValue = encoding.leftValue {
                return try rule.process(try decode(atom: unitValue))
            }
            
            else {
                return try rule.process(try encoding.map({ try decode(.init($0)) }))
            }
        }
        
        throw Never.Reason.unexpected
    }
    
    public static func decode(
        parsing encoding: ObjCTypeEncoding
    ) -> Any.Type? {
        var parser = SequenceParser<String>()
        
        parser.insert(prefix: "{", suffix: "}")
        parser.insert(prefix: "(", suffix: ")")
        parser.insert(token: "^")
        parser.insert(token: "r^")
        
        parser.stripPrefixesAndSuffixes = false
        
        return try? decode(parser.input(encoding.losingNominalPrecision.value).recursiveMap({ String($0) }))
    }
    
    public static func decode(_ encoding: ObjCTypeEncoding) throws -> Any.Type {
        if let result = registry[encoding]?.base {
            return result
        } else if let result = decode(possibleSimple: encoding) {
            return result
        } else if let result = decode(parsing: encoding) {
            return result
        } else {
            let types = Array<Any.Type>(repeating: Byte.self, count: try encoding.sizeInBytes)
            
            return try TypeMetadata(tupleWithTypes: types).base
        }
    }
}
