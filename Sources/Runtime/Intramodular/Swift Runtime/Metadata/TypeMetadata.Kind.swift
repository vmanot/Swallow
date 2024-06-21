//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    @frozen
    public enum Kind: UInt, Equatable {
        case `class` = 0
        case `struct` = 0x200     // 0 | nonHeap
        case `enum` = 0x201       // 1 | nonHeap
        case optional = 0x202     // 2 | nonHeap
        case foreignClass = 0x203 // 3 | nonHeap
        case opaque = 0x300       // 0 | runtimePrivate | nonHeap
        case tuple = 0x301        // 1 | runtimePrivate | nonHeap
        case function = 0x302     // 2 | runtimePrivate | nonHeap
        case existential = 0x303  // 3 | runtimePrivate | nonHeap
        case metatype = 0x304     // 4 | runtimePrivate | nonHeap
        case objCClassWrapper = 0x305     // 5 | runtimePrivate | nonHeap
        case existentialMetatype = 0x306  // 6 | runtimePrivate | nonHeap
        case heapLocalVariable = 0x400    // 0 | nonType
        case heapGenericLocalVariable = 0x500 // 0 | nonType | runtimePrivate
        case errorObject = 0x501  // 1 | nonType | runtimePrivate
        case unknown = 0xffff
        
        init(_ type: Any.Type) {
            let v = _swift_getMetadataKind(type)
            if let result = Self(rawValue: v) {
                self = result
            } else {
                self = .unknown
            }
        }
        
        public init?(_rawValue rawValue: Int) {
            switch rawValue {
                case 1:
                    self = .struct
                case (0 | Flags.kindIsNonHeap):
                    self = .struct
                case 2:
                    self = .enum
                case (1 | Flags.kindIsNonHeap):
                    self = .enum
                case 3:
                    self = .optional
                case (2 | Flags.kindIsNonHeap):
                    self = .optional
                case 8:
                    self = .opaque
                case (3 | Flags.kindIsNonHeap):
                    self = .foreignClass
                case 9:
                    self = .tuple
                case (0 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap):
                    self = .opaque
                case 10:
                    self = .function
                case (1 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap):
                    self = .tuple
                case 12:
                    self = .existential
                case (2 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap):
                    self = .function
                case 13:
                    self = .metatype
                case (3 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap):
                    self = .existential
                case 14:
                    self = .objCClassWrapper
                case (4 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap):
                    self = .metatype
                case 15:
                    self = .existentialMetatype
                case (5 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap):
                    self = .objCClassWrapper
                case 16:
                    self = .foreignClass
                case (6 | Flags.kindIsRuntimePrivate | Flags.kindIsNonHeap):
                    self = .existentialMetatype
                case 64:
                    self = .heapLocalVariable
                case (0 | Flags.kindIsNonType):
                    self = .heapLocalVariable
                case 65:
                    self = .heapGenericLocalVariable
                case (0 | Flags.kindIsNonType | Flags.kindIsRuntimePrivate):
                    self = .heapGenericLocalVariable
                case 128:
                    self = .errorObject
                case (1 | Flags.kindIsNonType | Flags.kindIsRuntimePrivate):
                    self = .errorObject
                default:
                    return nil
            }
        }
    }
}

extension TypeMetadata {
    struct Flags {
        static let kindIsRuntimePrivate = 0x100
        static let kindIsNonHeap = 0x200
        static let kindIsNonType = 0x400
    }
}

// MARK: - Helpers

@_spi(Internal)
extension TypeMetadata {
    public var _contextDescriptorFlags: SwiftRuntimeContextDescriptorFlags {
        unsafeBitCast(self, to: UnsafePointer<SwiftRuntimeContextDescriptorFlags>.self).pointee
    }
}

extension TypeMetadata {
    public var _kind: TypeMetadata.Kind? {
        TypeMetadata.Kind(base)
    }
    
    public var kind: TypeMetadata.Kind {
        if let _kind = _contextDescriptorFlags.kind {
            switch _kind {
                case .module:
                    break
                case .`extension`:
                    break
                case .anonymous:
                    break
                case .`protocol`:
                    break
                case .opaqueType:
                    break
                case .`class`:
                    return .class
                case .`struct`:
                    break
                case .`enum`:
                    break
            }
        }
        
        guard let kind = _kind else {
            if _swift_isClassType(base) {
                return .class
            } else {
                let _baseMetatype = Swift.type(of: base)
                
                if TypeMetadata(_baseMetatype)._kind == .existentialMetatype {
                    return .existential
                } else if TypeMetadata(_baseMetatype)._kind == .metatype {
                    if let _kind = self._kind {
                        return _kind
                    } else if let _maybeExistentialMetatype = _swift_getExistentialMetatypeMetadata(base) {
                        if TypeMetadata(_maybeExistentialMetatype)._kind == .existentialMetatype {
                            return .existential
                        }
                    }
                }
                
                assertionFailure()
                
                return .class
            }
        }
        
        return kind
    }
}

extension TypeMetadata {
    public var typed: Any {
        switch kind {
            case .`struct`:
                return unsafeBitCast(self, to: TypeMetadata.Structure.self)
            case .`enum`:
                return unsafeBitCast(self, to: TypeMetadata.Enumeration.self)
            case .tuple:
                return unsafeBitCast(self, to: TypeMetadata.Tuple.self)
            case .function:
                return unsafeBitCast(self, to: TypeMetadata.Function.self)
            case .existential:
                return unsafeBitCast(self, to: TypeMetadata.Existential.self)
            case .`class`:
                return unsafeBitCast(self, to: TypeMetadata.Class.self)
            case .objCClassWrapper:
                return unsafeBitCast(self, to: ObjCClass.self)
            default:
                return self
        }
    }
    
    public var _nominalType: (any _NominalTypeMetadataType)? {
        try? cast(self.typed)
    }
}
