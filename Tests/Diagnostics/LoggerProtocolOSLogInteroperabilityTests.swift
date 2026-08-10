//
// Copyright (c) Vatsal Manot
//

#if canImport(OSLog)
@testable import Diagnostics
import OSLog
import Testing

@Suite
struct LoggerProtocolOSLogInteroperabilityTests {
    @Test
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func concreteLoggerRetainsPrivacyAPIAndGenericLoggerSupportsVerbatimMessages() {
        let logger = Logger(
            subsystem: "com.preternatural.SwallowTests",
            category: "LoggerProtocol"
        )
        let token = "sensitive"

        logger.debug("Token: \(token, privacy: .private)")
        emitStaticDebug(using: logger)
    }

    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    private func emitStaticDebug<L: LoggerProtocol>(
        using logger: L
    ) where L.LogMessage == OSLogMessage {
        logger.debug(verbatim: "Release started")
    }
}
#endif
