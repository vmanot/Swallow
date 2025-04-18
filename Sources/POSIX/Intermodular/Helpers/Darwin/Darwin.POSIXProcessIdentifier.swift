//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXProcessIdentifier: RawRepresentable {
    public static var current: POSIXProcessIdentifier {
        Self(rawValue: getpid())
    }
    
    public let rawValue: pid_t
    
    public init(rawValue: pid_t) {
        self.rawValue = rawValue
    }
    
    public func _isZombie() -> Bool {
        var kinfo = kinfo_proc()
        var size: Int = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, self.rawValue]
        
        sysctl(&mib, u_int(mib.count), &kinfo, &size, nil, 0)
        
        _ = withUnsafePointer(to: &kinfo.kp_proc.p_comm) {
            String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
        }
        
        return kinfo.kp_proc.p_stat == SZOMB
    }
}
