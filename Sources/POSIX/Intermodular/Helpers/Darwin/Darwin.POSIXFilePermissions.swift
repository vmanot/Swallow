//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXFilePermissionBits: Codable, CustomStringConvertible, OptionSet {
    public static let read = with(rawValue: 4)
    public static let write = with(rawValue: 2)
    public static let execute = with(rawValue: 1)

    public let rawValue: Int
    
    public var umaskValue: Int {
        return 7 - self.rawValue
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init(umaskValue: Int) {
        self.rawValue = (7 - umaskValue)
    }
    
    public var description: String {
        let r = self.contains(.read) ? "r" : "-"
        let w = self.contains(.write) ? "w" : "-"
        let x = self.contains(.execute) ? "x" : "-"
        
        return r + w + x
    }
}

public struct POSIXFilePermissions: OptionSet {
    public typealias RawValue = mode_t
    
    public static let userReadable = with(rawValue: S_IRUSR)
    public static let userWritable = with(rawValue: S_IWUSR)
    public static let userExecutable = with(rawValue: S_IXUSR)
    
    public static let groupReadable = with(rawValue: S_IRGRP)
    public static let groupWritable = with(rawValue: S_IWGRP)
    public static let groupExecutable = with(rawValue: S_IXGRP)
    
    public static let otherReadable = with(rawValue: S_IROTH)
    public static let otherWritable = with(rawValue: S_IWOTH)
    public static let otherExecutable = with(rawValue: S_IXOTH)
    
    public static let setUserIDOnExecution = with(rawValue: S_ISUID)
    public static let setGroupIDOnExecution = with(rawValue: S_ISGID)
    public static let saveSwappedTextAfterUser = with(rawValue: S_ISVTX)
    
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public init() {
        self.init(rawValue: 0)
    }
}

extension POSIXFilePermissions {
    public init(class: POSIXFilePermissionsClass, mode: POSIXFilePermissionsMode) throws {
        switch (`class`, mode) {
            case (.user, .read):
                self = .userReadable
            case (.user, .write):
                self = .userWritable
            case (.user, .execute):
                self = .userExecutable

            case (.group, .read):
                self = .groupReadable
            case (.group, .write):
                self = .groupWritable
            case (.group, .execute):
                self = .groupExecutable

            case (.other, .read):
                self = .otherReadable
            case (.other, .write):
                self = .otherWritable
            case (.other, .execute):
                self = .otherExecutable

            case (.special, .setUserIDOnExecution):
                self = .setUserIDOnExecution
            case (.special, .setGroupIDOnExecution):
                self = .setGroupIDOnExecution
            case (.special, .saveSwappedTextAfterUser):
                self = .saveSwappedTextAfterUser

            case (.all, .read):
                self = [.userReadable, .groupReadable, .otherReadable]
            case (.all, .write):
                self = [.userWritable, .groupWritable, .otherWritable]
            case (.all, .execute):
                self = [.userExecutable, .groupExecutable, .otherExecutable]
        
            default:
                throw _PlaceholderError()
        }
    }
}
