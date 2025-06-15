#if canImport(Darwin)
@_exported import OSLog

extension Logger {
    private static let machOToolbox = Logger(subsystem: "ai.preternatural.machoswift", category: "MachOToolbox")
    
    @_transparent
    static func machOToolbox(level: OSLogType, _ format: String, _ arguments: any CVarArg...) {
        let message = String(format: format, arguments: arguments)
        machOToolbox.log(level: level, "\(message)")
    }
    
    @_transparent
    static func machOToolbox(level: OSLogType, _ message: @autoclosure () -> Any) {
        machOToolbox(level: level, String(describing: message()))
    }
}
#else
#error("TODO")
#endif
