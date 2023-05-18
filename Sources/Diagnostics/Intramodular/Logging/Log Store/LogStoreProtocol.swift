//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A type that represents a log store.
///
/// A log store allows you to fetch and query log messages.
public protocol LogStoreProtocol {
    associatedtype LogEntry
    associatedtype LogEntries: Sequence where LogEntries.Element == LogEntry
    associatedtype LogEnumeratorOptions
    associatedtype LogPosition
    
    func getEntries(
        with options: LogEnumeratorOptions,
        at position: LogPosition?,
        matching predicate: NSPredicate?
    ) throws -> LogEntries
}

// MARK: - Implemented Conformances

#if canImport(OSLog)
import OSLog
@available(macOS 10.15, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension OSLogStore: LogStoreProtocol {
    public typealias LogEntry = OSLogEntry
    public typealias LogEntries = AnySequence<OSLogEntry>
    public typealias LogEnumeratorOptions = OSLogEnumerator.Options
    public typealias LogPosition = OSLogPosition
}
#endif
