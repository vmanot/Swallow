//
// Copyright (c) Vatsal Manot
//

import Foundation

public protocol LogEntryTextFormatter: Sendable {
    func format(
        _ entry: PassthroughLogger.LogEntry
    ) -> String
}

public struct LogEntryTextFormat: Sendable, LogEntryTextFormatter {
    public var transforms: [any LogEntryTextTransform]
    
    public init(
        transforms: [any LogEntryTextTransform] = []
    ) {
        self.transforms = transforms
    }
    
    public static let plain = Self()
    
    public static let commandLine = Self.linePrefixed(
        prefix: ScopePathLogEntryIndentation(unit: "  ")
    )
    
    public static func linePrefixed(
        prefix: some LogEntryLinePrefixStrategy,
        prefixesMultilineMessages: Bool = true
    ) -> Self {
        Self(
            transforms: [
                LinePrefixLogEntryTextTransform(
                    prefix: prefix,
                    prefixesMultilineMessages: prefixesMultilineMessages
                )
            ]
        )
    }
    
    public func format(
        _ entry: PassthroughLogger.LogEntry
    ) -> String {
        transforms.reduce(
            LogEntryTextFragment(
                entry: entry,
                text: entry.message.description
            )
        ) { fragment, transform in
            transform.transform(fragment)
        }.text
    }
}

public struct LogEntryTextFragment {
    public let entry: PassthroughLogger.LogEntry
    public var text: String
    
    public init(
        entry: PassthroughLogger.LogEntry,
        text: String
    ) {
        self.entry = entry
        self.text = text
    }
}

public protocol LogEntryTextTransform: Sendable {
    func transform(
        _ fragment: LogEntryTextFragment
    ) -> LogEntryTextFragment
}

public protocol LogEntryLinePrefixStrategy: Sendable {
    func prefix(
        for entry: PassthroughLogger.LogEntry
    ) -> String
}

public protocol LogEntryIndentationStrategy: LogEntryLinePrefixStrategy {
    
}

public enum LogEntryScopeTextSelection: Sendable, Hashable {
    case leaf
    case fullPath(separator: String)
}

public struct ScopePathLogEntryTextPrefix: Sendable, Hashable, LogEntryLinePrefixStrategy {
    public var selection: LogEntryScopeTextSelection
    public var suffix: String
    
    public init(
        selection: LogEntryScopeTextSelection = .leaf,
        suffix: String = " "
    ) {
        self.selection = selection
        self.suffix = suffix
    }
    
    public func prefix(
        for entry: PassthroughLogger.LogEntry
    ) -> String {
        let representations = entry.scope.textRepresentations
        
        guard !representations.isEmpty else {
            return ""
        }
        
        let text: String
        
        switch selection {
            case .leaf:
                text = representations.last!.description
            case .fullPath(let separator):
                text = representations.map(\.description).joined(separator: separator)
        }
        
        guard !text.isEmpty else {
            return ""
        }
        
        return text + suffix
    }
}

public struct LinePrefixLogEntryTextTransform: Sendable, LogEntryTextTransform {
    public var prefix: any LogEntryLinePrefixStrategy
    public var prefixesMultilineMessages: Bool
    
    public init(
        prefix: some LogEntryLinePrefixStrategy,
        prefixesMultilineMessages: Bool = true
    ) {
        self.prefix = prefix
        self.prefixesMultilineMessages = prefixesMultilineMessages
    }
    
    public func transform(
        _ fragment: LogEntryTextFragment
    ) -> LogEntryTextFragment {
        let prefix = prefix.prefix(for: fragment.entry)
        
        guard !prefix.isEmpty else {
            return fragment
        }
        
        var result = fragment
        
        if prefixesMultilineMessages {
            result.text = result.text._prefixingEachLine(with: prefix)
        } else {
            result.text = prefix + result.text
        }
        
        return result
    }
}

/// Prefixes the first line and aligns continuation lines beneath its text.
///
/// This is suited to status symbols and other compact terminal markers where
/// repeating the prefix would incorrectly imply a separate event.
public struct AlignedLinePrefixLogEntryTextTransform: Sendable, LogEntryTextTransform {
    public var prefix: any LogEntryLinePrefixStrategy

    public init(
        prefix: some LogEntryLinePrefixStrategy
    ) {
        self.prefix = prefix
    }

    public func transform(
        _ fragment: LogEntryTextFragment
    ) -> LogEntryTextFragment {
        let prefix = prefix.prefix(for: fragment.entry)

        guard !prefix.isEmpty else {
            return fragment
        }

        var result = fragment
        let continuationPrefix = String(repeating: " ", count: prefix.count)
        let lines = fragment.text.components(separatedBy: .newlines)

        result.text = lines.enumerated().map { index, line in
            (index == 0 ? prefix : continuationPrefix) + line
        }.joined(separator: "\n")

        return result
    }
}

public struct NoLogEntryLinePrefix: Hashable, LogEntryLinePrefixStrategy {
    public init() {
        
    }
    
    public func prefix(
        for entry: PassthroughLogger.LogEntry
    ) -> String {
        ""
    }
}

public struct ScopePathLogEntryIndentation: Hashable, LogEntryIndentationStrategy {
    public var unit: String
    public var root: String
    
    public init(
        unit: String = "  ",
        root: String = ""
    ) {
        self.unit = unit
        self.root = root
    }
    
    public func prefix(
        for entry: PassthroughLogger.LogEntry
    ) -> String {
        root + String(repeating: unit, count: entry.scope.textRepresentations.count)
    }
}

extension PassthroughLogger.LogEntry {
    public func formatted(
        using format: LogEntryTextFormat = .plain
    ) -> String {
        format.format(self)
    }
}

extension String {
    fileprivate func _prefixingEachLine(
        with prefix: String
    ) -> String {
        components(separatedBy: .newlines)
            .map { prefix + $0 }
            .joined(separator: "\n")
    }
}
