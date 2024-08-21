//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension ProcessInfo {
    public struct Fingerprint: Codable, CustomStringConvertible, Hashable, Sendable {
        public let processID: Int32
        public let processName: String
        public let processStartTime: Date?
        public let executablePath: String?
        public let commandLineArguments: [String]
        public let parentProcessID: Int32
        public let userIdentifier: UserIdentifier
        public let groupIdentifier: GroupIdentifier
        
        public var description: String {
            "\(processName) (Fingerprint)"
        }
        
        public init(
            processInfo: ProcessInfo
        ) {
            self.processID = Int32(processInfo.processIdentifier)
            self.processName = processInfo.processName
            self.processStartTime = processInfo.startTime
            self.executablePath = Bundle.main.executablePath
            self.commandLineArguments = CommandLine.arguments
            self.parentProcessID = getppid()
            self.userIdentifier = UserIdentifier(rawValue: getuid())
            self.groupIdentifier = GroupIdentifier(rawValue: getgid())
        }
        
        public init() {
            self.init(processInfo: ProcessInfo.processInfo)
        }
    }
    
    private static var _lastFingerprint: Fingerprint?
    
    public static var fingerprint: Fingerprint {
        if let result = _lastFingerprint {
            assert(result == ProcessInfo.processInfo.fingerprint)
            
            return result
        } else {
            let result = ProcessInfo.processInfo.fingerprint
            
            _lastFingerprint = result
            
            return result
        }
        
    }
    
    public var fingerprint: Fingerprint {
        ProcessInfo.Fingerprint(processInfo: self)
    }
}

extension ProcessInfo.Fingerprint {
    public struct UserIdentifier: Codable, Hashable, Sendable {
        public let rawValue: uid_t
        
        public init(rawValue: uid_t) {
            self.rawValue = rawValue
        }
    }
    
    public struct GroupIdentifier: Codable, Hashable, Sendable {
        public let rawValue: gid_t
        
        public init(rawValue: gid_t) {
            self.rawValue = rawValue
        }
    }
}

#if os(macOS)
extension ProcessInfo {
    public var startTime: Date? {
        var info = proc_bsdinfo()
        let size = MemoryLayout<proc_bsdinfo>.size
        let result = proc_pidinfo(processIdentifier, PROC_PIDTBSDINFO, 0, &info, Int32(size))
        
        guard result == size else {
            return nil
        }
        
        let startTime = Double(info.pbi_start_tvsec) + Double(info.pbi_start_tvusec) / 1_000_000
        
        return Date(timeIntervalSince1970: startTime)
    }
}
#else
extension ProcessInfo {
    public var startTime: Date? {
        nil
    }
}
#endif
