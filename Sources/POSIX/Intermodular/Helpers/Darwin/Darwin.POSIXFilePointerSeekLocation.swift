//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

extension POSIXFilePointer {
    public enum SeekLocation: RawRepresentable {
        public typealias RawValue = Int32
        
        case none
        case current
        case endOfFile
        
        public var rawValue: RawValue {
            switch self {
                case .none:
                    return SEEK_SET
                case .current:
                    return SEEK_CUR
                case .endOfFile:
                    return SEEK_END
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue {
                case type(of: self).none.rawValue:
                    self = .none
                case type(of: self).current.rawValue:
                    self = .current
                case type(of: self).endOfFile.rawValue:
                    self = .endOfFile
                
                default:
                    return nil
            }
        }
    }
}
