//
// Copyright (c) Vatsal Manot
//

import Foundation

#if canImport(os)
import os
#endif

/// Runtime-owned emission carrier.
///
/// Keep sink methods boring. Context belongs here when it has real semantics.
struct _PassthroughLogEmission {
    let entry: PassthroughLogger.LogEntry
}

protocol _SynchronousPassthroughLogSink: Sendable {
    func _emitSynchronously(_ emission: _PassthroughLogEmission)
}

struct _DefaultPassthroughLogSink: Sendable, _SynchronousPassthroughLogSink {
    static let `default` = Self(_PlatformLogSink.default)
    
    private let base: any _SynchronousPassthroughLogSink
    
    init(
        _ base: some _SynchronousPassthroughLogSink
    ) {
        self.base = base
    }
    
    func _emitSynchronously(
        _ emission: _PassthroughLogEmission
    ) {
        base._emitSynchronously(emission)
    }
}

final class _PlatformLogSink: _SynchronousPassthroughLogSink, @unchecked Sendable {
    static let `default` = _PlatformLogSink()
    
    #if canImport(OSLog)
    private let logger: OSLoggerProtocol?
    #endif
    
    private init() {
        #if canImport(OSLog)
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            self.logger = OSLogger(
                subsystem: Bundle.main.bundleIdentifier ?? "<main>",
                category: "Diagnostics"
            )
        } else {
            self.logger = nil
        }
        #endif
    }
    
    func _emitSynchronously(
        _ emission: _PassthroughLogEmission
    ) {
        #if canImport(OSLog)
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            if let logger = logger as? OSLogger {
                logger._log(
                    level: emission.entry.level,
                    emission.entry.message.description
                )
            }
        }
        #endif
    }
}
