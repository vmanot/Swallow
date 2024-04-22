//
// Copyright (c) Vatsal Manot
//

import MachO
import Swallow

extension DynamicLinkEditor.Image {
    public enum LoadCommandType: CustomStringConvertible, Hashable, Sendable {
        case segment
        case symtab
        case symseg
        case thread
        case unixThread
        case loadFvmlib
        case idFvmlib
        case ident
        case fvmfile
        case prepage
        case dysymtab
        case loadDylib
        case idDylib
        case loadDylinker
        case idDylinker
        case preboundDylib
        case routines
        case subFramework
        case subUmbrella
        case subClient
        case subLibrary
        case twoLevelHints
        case prebindCksum
        case segment64
        
        case unknown(Int32)
        
        public init(rawValue: Int32) {
            switch rawValue {
                case LC_SEGMENT:
                    self = .segment
                case LC_SYMTAB:
                    self = .symtab
                case LC_SYMSEG:
                    self = .symseg
                case LC_THREAD:
                    self = .thread
                case LC_UNIXTHREAD:
                    self = .unixThread
                case LC_LOADFVMLIB:
                    self = .loadFvmlib
                case LC_IDFVMLIB:
                    self = .idFvmlib
                case LC_IDENT:
                    self = .ident
                case LC_FVMFILE:
                    self = .fvmfile
                case LC_PREPAGE:
                    self = .prepage
                case LC_DYSYMTAB:
                    self = .dysymtab
                case LC_LOAD_DYLIB:
                    self = .loadDylib
                case LC_ID_DYLIB:
                    self = .idDylib
                case LC_LOAD_DYLINKER:
                    self = .loadDylinker
                case LC_ID_DYLINKER:
                    self = .idDylinker
                case LC_PREBOUND_DYLIB:
                    self = .preboundDylib
                case LC_ROUTINES:
                    self = .routines
                case LC_SUB_FRAMEWORK:
                    self = .subFramework
                case LC_SUB_UMBRELLA:
                    self = .subUmbrella
                case LC_SUB_CLIENT:
                    self = .subClient
                case LC_SUB_LIBRARY:
                    self = .subLibrary
                case LC_TWOLEVEL_HINTS:
                    self = .twoLevelHints
                case LC_PREBIND_CKSUM:
                    self = .prebindCksum
                case LC_SEGMENT_64:
                    self = .segment64
                default:
                    self = .unknown(rawValue)
            }
        }
        
        public var description: String {
            switch self {
                case .segment:
                    return "LC_SEGMENT"
                case .symtab:
                    return "LC_SYMTAB"
                case .symseg:
                    return "LC_SYMSEG"
                case .thread:
                    return "LC_THREAD"
                case .unixThread:
                    return "LC_UNIXTHREAD"
                case .loadFvmlib:
                    return "LC_LOADFVMLIB"
                case .idFvmlib:
                    return "LC_IDFVMLIB"
                case .ident:
                    return "LC_IDENT"
                case .fvmfile:
                    return "LC_FVMFILE"
                case .prepage:
                    return "LC_PREPAGE"
                case .dysymtab:
                    return "LC_DYSYMTAB"
                case .loadDylib:
                    return "LC_LOAD_DYLIB"
                case .idDylib:
                    return "LC_ID_DYLIB"
                case .loadDylinker:
                    return "LC_LOAD_DYLINKER"
                case .idDylinker:
                    return "LC_ID_DYLINKER"
                case .preboundDylib:
                    return "LC_PREBOUND_DYLIB"
                case .routines:
                    return "LC_ROUTINES"
                case .subFramework:
                    return "LC_SUB_FRAMEWORK"
                case .subUmbrella:
                    return "LC_SUB_UMBRELLA"
                case .subClient:
                    return "LC_SUB_CLIENT"
                case .subLibrary:
                    return "LC_SUB_LIBRARY"
                case .twoLevelHints:
                    return "LC_TWOLEVEL_HINTS"
                case .prebindCksum:
                    return "LC_PREBIND_CKSUM"
                case .segment64:
                    return "LC_SEGMENT_64"
                case .unknown(let rawValue):
                    return "\(rawValue) <unknown>"
            }
        }
    }
}
