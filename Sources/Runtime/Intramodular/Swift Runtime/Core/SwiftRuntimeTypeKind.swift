//
// Copyright (c) Vatsal Manot
//

import Swallow

public enum SwiftRuntimeTypeKind {
    struct Flags {
        static let kindIsNonHeap = 0x200
        static let kindIsRuntimePrivate = 0x100
        static let kindIsNonType = 0x400
    }
    
    case `struct`
    case `enum`
    case optional
    case opaque
    case tuple
    case function
    case existential
    case metatype
    case objCClassWrapper
    case existentialMetatype
    case foreignClass
    case heapLocalVariable
    case heapGenericLocalVariable
    case errorObject
    case `class`
    
    init(rawValue: Int) {
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
                self = .class
        }
    }
}
