#if canImport(Darwin)
@_exported import OSLog

extension Logger {
    private static let machOSwift = Logger(subsystem: "ai.preternatural.machoswift", category: "MachOSwift")
    
    @_transparent
    static func machOSwift(level: OSLogType, _ format: String, _ arguments: any CVarArg...) {
        let message = String(format: format, arguments: arguments)
        machOSwift.log(level: level, "\(message)")
    }
    
    @_transparent
    static func machOSwift(level: OSLogType, _ message: @autoclosure () -> Any) {
        machOSwift(level: level, String(describing: message()))
    }
}
#else
#error("TODO")
#endif
