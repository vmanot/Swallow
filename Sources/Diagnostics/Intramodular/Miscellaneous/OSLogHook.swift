import os.log

@frozen
public struct os_log_message_s {
    public var trace_id: UInt64
    public var padding: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                         UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) // 80 bytes
    public var format: UnsafePointer<CChar>?
    public var buffer: UnsafePointer<UInt8>?
    public var buffer_sz: Int
    public var privdata: UnsafePointer<UInt8>?
    public var privdata_sz: Int
    public var subsystem: UnsafePointer<CChar>?
    public var category: UnsafePointer<CChar>?
}

public typealias os_log_hook_t = (@convention(block) (UInt8, UnsafeRawPointer?) -> Void)

// Function declarations
@_silgen_name("os_log_set_hook")
func os_log_set_hook(_ level: UInt8, _ hook: @escaping os_log_hook_t) -> os_log_hook_t?

@_silgen_name("os_log_copy_message_string")
func os_log_copy_message_string(_ message: UnsafePointer<os_log_message_s>?) -> UnsafeMutablePointer<CChar>?

// OSLogType enum - based on typical OS log levels

public enum OSPrivate_os_log {
    public typealias os_log_type_t = UInt8
    
    public struct OSLogType {
        public static let debug: UInt8 = 0x02
        public static let info: UInt8 = 0x01
        public static let `default`: UInt8 = 0x00
        public static let error: UInt8 = 0x10
        public static let fault: UInt8 = 0x11
    }

    // High-level type for log messages
    public struct OSLogMessage {
        public let traceID: UInt64
        public let message: String
        public let subsystem: String?
        public let category: String?
        public let format: String?
        
        init?(from rawMessage: UnsafePointer<os_log_message_s>) {
            self.traceID = rawMessage.pointee.trace_id
            
            // Copy the message string
            guard let msgCStr = os_log_copy_message_string(rawMessage) else {
                return nil
            }
            self.message = String(cString: msgCStr)
            free(msgCStr)
            
            // Copy subsystem if available
            if let subsystemPtr = rawMessage.pointee.subsystem {
                self.subsystem = String(cString: subsystemPtr)
            } else {
                self.subsystem = nil
            }
            
            // Copy category if available
            if let categoryPtr = rawMessage.pointee.category {
                self.category = String(cString: categoryPtr)
            } else {
                self.category = nil
            }
            
            // Copy format if available
            if let formatPtr = rawMessage.pointee.format {
                self.format = String(cString: formatPtr)
            } else {
                self.format = nil
            }
        }
    }
}

// High-level log hook manager
public class OSLogHook {
    private var previousHook: os_log_hook_t?
    private let handler: (OSPrivate_os_log.os_log_type_t, OSPrivate_os_log.OSLogMessage) -> Void
    private let level: OSPrivate_os_log.os_log_type_t
    private var isActive = true
    
    public init(
        level: OSPrivate_os_log.os_log_type_t,
        handler: @escaping (OSPrivate_os_log.os_log_type_t, OSPrivate_os_log.OSLogMessage) -> Void
    ) {
        self.handler = handler
        self.level = level
        
        self.previousHook = os_log_set_hook(level) { [weak self] level, msg in
            guard let self = self, self.isActive else { return }
            
            if let msgPtr = msg?.bindMemory(to: os_log_message_s.self, capacity: 1),
               let logMessage = OSPrivate_os_log.OSLogMessage(from: msgPtr) {
                self.handler(level, logMessage)
            }
            
            // Call previous hook if it exists
            self.previousHook?(level, msg)
        }
    }
    
    public func remove() {
        guard isActive else { return }
        isActive = false
        
        // Restore the previous hook
        if let previousHook = previousHook {
            _ = os_log_set_hook(level, previousHook)
        } else {
            // If there was no previous hook, we need to remove ours
            // by setting a no-op hook
            _ = os_log_set_hook(level) { _, _ in }
        }
    }
    
    deinit {
        remove()
    }
}

var hook: OSLogHook?

func hookNSHostingViewWarningExample() {
    hook = OSLogHook(level: OSPrivate_os_log.OSLogType.debug) { level, logMessage in
        if logMessage.message.contains("NSHostingView is being laid out reentrantly") {
            print("gotchya!")
        }
        
        print(logMessage.message)
    }
}
