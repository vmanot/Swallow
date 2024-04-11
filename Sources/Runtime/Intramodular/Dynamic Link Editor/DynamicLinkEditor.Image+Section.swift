//
// Copyright (c) Vatsal Manot
//

import Foundation
import MachO

extension DynamicLinkEditor.Image {
    public enum TextSection: String {
        case ustring = "__ustring"
        case const = "__const"
        case text = "__text"
        case cstring = "__cstring"
        case objc_classname = "__objc_classname"
        case objc_methname = "__objc_methname"
        case objc_methtype = "__objc_methtype"
        case gcc_except_tab = "__gcc_except_tab"
        
        case swift5types = "__swift5_types"
        case swift5proto = "__swift5_proto"
        case swift5protos = "__swift5_protos"
        case swift5filemd = "__swift5_fieldmd"
        case swift5replace = "__swift5_replace"
        case swift5reflstr = "__swift5_reflstr"
        case swift5typeref = "__swift5_typeref"
        
        case stubs = "__stubs"
        case stub_help = "__stub_helper"
    }
    
    public enum DataSection: String {
        case got = "__got"
        case la_symbol_ptr = "__la_symbol_ptr"
        case mod_init_func = "__mod_init_func"
        case const = "__const"
        case cfstring = "__cfstring"
        case objc_classlist = "__objc_classlist"
        case objc_nlclslist = "__objc_nlclslist"
        case objc_catlist = "__objc_catlist"
        case objc_nlcatlist = "__objc_nlcatlist"
        case objc_protolist = "__objc_protolist"
        case objc_imageinfo = "__objc_imageinfo"
        case objc_const = "__objc_const"
        case objc_selrefs = "__objc_selrefs"
        case objc_classrefs = "__objc_classrefs"
        case objc_superrefs = "__objc_superrefs"
        case objc_ivar = "__objc_ivar"
        case objc_data = "__objc_data"
        case data = "__data"
        case swift_hooks = "__swift_hooks"
        case swift51_hooks = "__swift51_hooks"
    }

    public enum SectionType: UInt32 {
        case S_REGULAR = 0
        case S_ZEROFILL
        case S_CSTRING_LITERALS
        case S_4BYTE_LITERALS
        case S_8BYTE_LITERALS
        case S_LITERAL_POINTERS
        case S_NON_LAZY_SYMBOL_POINTERS
        case S_LAZY_SYMBOL_POINTERS
        case S_SYMBOL_STUBS
        case S_MOD_INIT_FUNC_POINTERS
        case S_MOD_TERM_FUNC_POINTERS
        case S_COALESCED
        case S_GB_ZEROFILL
        case S_INTERPOSING
        case S_16BYTE_LITERALS
        case S_DTRACE_DOF
        case S_LAZY_DYLIB_SYMBOL_POINTERS
        case S_THREAD_LOCAL_REGULAR
        case S_THREAD_LOCAL_ZEROFILL
        case S_THREAD_LOCAL_VARIABLES
        case S_THREAD_LOCAL_VARIABLE_POINTERS
        case S_THREAD_LOCAL_INIT_FUNCTION_POINTERS
        case S_INIT_FUNC_OFFSETS
        
        case S_ATTRIBUTES_USR = 0xff000000  /* User setable attributes */
        case S_ATTR_PURE_INSTRUCTIONS = 0x80000000  /* section contains only true machine instructions */
        
        public var hasIndirectSymbolTableEntries: Bool {
            switch self {
                case .S_NON_LAZY_SYMBOL_POINTERS, .S_LAZY_SYMBOL_POINTERS, .S_LAZY_DYLIB_SYMBOL_POINTERS, .S_SYMBOL_STUBS:
                    return true
                default:
                    return false
            }
        }
    }
    
    struct Section64 {
        private(set) var sectname: String
        private(set) var segname: String
        private(set) var info: section_64
        
        public var align: UInt32 {
            return UInt32(pow(Double(2), Double(info.align)))
        }
        public var fileOffset: UInt32 {
            return info.offset;
        }
        
        public var num: Int {
            let num: Int = Int(info.size) / Int(align);
            
            return num
        }
        
        init(section: section_64) {
            self.segname = String(tuple16: section.segname)
            self.sectname = String(String(tuple16: section.sectname).prefix(16))
            self.info = section
        }
    }
}
