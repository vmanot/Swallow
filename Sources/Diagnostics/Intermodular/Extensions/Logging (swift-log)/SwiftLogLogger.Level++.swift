//
// Copyright (c) Vatsal Manot
//

#if canImport(Logging)
import Logging
import Swift

extension SwiftLogLogger.Level {
    public var name: String {
        switch self {
            case .trace:
                return "Trace"
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .notice:
                return "Notice"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            case .critical:
                return "Critical"
        }
    }
}
#endif
