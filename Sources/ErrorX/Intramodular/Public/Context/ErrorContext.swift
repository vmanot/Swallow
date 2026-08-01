//
// Copyright (c) Vatsal Manot
//

/// Facts attached to an error occurrence or to the act of observing it.
public struct ErrorContext: Hashable, Sendable, RandomAccessCollection, RangeReplaceableCollection,
  ExpressibleByArrayLiteral, CustomStringConvertible, CustomDebugStringConvertible
{
  /// A stable, type-erased context key.
  public struct AnyKey: Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// The stable name of this key.
    public let name: String

    /// The stable name of this key.
    public var description: String {
      name
    }

    /// A structural description of the erased key.
    public var debugDescription: String {
      "ErrorContext.AnyKey(\(String(reflecting: name)))"
    }

    /// Creates a key with the given stable name.
    public init(_ name: String) {
      self.name = name
    }

    /// Erases the value type of `key`.
    public init<ContextValue: ErrorContextValue>(_ key: Key<ContextValue>) {
      self.init(key.name)
    }

    /// Creates a key from a string literal.
    public init(stringLiteral value: String) {
      self.init(value)
    }
  }

  /// A stable context key whose value type is checked at the call site.
  ///
  /// Keys with the same stable name and value type compare equal regardless of
  /// their default privacy.
  public struct Key<Value: ErrorContextValue>: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// The stable name of this key.
    public let name: String

    /// The privacy used when an entry does not provide one explicitly.
    public let defaultPrivacy: Privacy

    /// The stable name of this key.
    public var description: String {
      name
    }

    /// A structural description of the typed key.
    public var debugDescription: String {
      "ErrorContext.Key<\(String(reflecting: Value.self))>(\(String(reflecting: name)), privacy: \(defaultPrivacy.debugDescription))"
    }

    /// Creates a key with the given stable name and default privacy.
    public init(
      _ name: String,
      privacy: Privacy = .private
    ) {
      self.name = name
      self.defaultPrivacy = privacy
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
    }
  }

  /// Privacy policy applied when context crosses a process or presentation boundary.
  public enum Privacy: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// Context that may be exported or presented by default.
    case `public`

    /// Context available to trusted, in-process consumers.
    case `private`

    /// Context available only to an explicit diagnostic projection.
    case sensitive

    /// Context that is never revealed by a projection.
    case secret

    /// A stable textual name for the privacy policy.
    public var description: String {
      switch self {
      case .public:
        return "public"
      case .private:
        return "private"
      case .sensitive:
        return "sensitive"
      case .secret:
        return "secret"
      }
    }

    /// A source-like description of the privacy policy.
    public var debugDescription: String {
      ".\(description)"
    }
  }

  /// A value with a stable scalar representation suitable for diagnostics and export.
  public enum Value: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// A string value.
    case string(String)

    /// An integer value.
    case integer(Int)

    /// A Boolean value.
    case boolean(Bool)

    /// A double-precision floating-point value.
    case double(Double)

    /// A placeholder for a value omitted under the given privacy policy.
    case redacted(Privacy)

    /// The value's diagnostic text.
    public var description: String {
      switch self {
      case .string(let value):
        return value
      case .integer(let value):
        return String(value)
      case .boolean(let value):
        return String(value)
      case .double(let value):
        return String(value)
      case .redacted(.private):
        return "<private>"
      case .redacted(.secret):
        return "<secret>"
      case .redacted:
        return "<redacted>"
      }
    }

    /// A source-like description preserving the value's scalar kind.
    public var debugDescription: String {
      switch self {
      case .string(let value):
        return ".string(\(String(reflecting: value)))"
      case .integer(let value):
        return ".integer(\(value))"
      case .boolean(let value):
        return ".boolean(\(value))"
      case .double(let value):
        return ".double(\(value))"
      case .redacted(let privacy):
        return ".redacted(\(privacy.debugDescription))"
      }
    }
  }

  /// One keyed context value.
  public struct Entry: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// The entry's type-erased key.
    public let key: AnyKey

    /// The entry's scalar value.
    public let value: Value

    /// The policy controlling where the value may be exposed.
    public let privacy: Privacy

    /// Creates an entry from an already-erased value.
    public init(
      key: AnyKey,
      value: Value,
      privacy: Privacy = .private
    ) {
      self.key = key
      self.value = value
      self.privacy = privacy
    }

    /// Creates an entry with an untyped key and a convertible value.
    public init<ContextValue: ErrorContextValue>(
      key: AnyKey,
      value: ContextValue,
      privacy: Privacy = .private
    ) {
      self.init(
        key: key,
        value: value.errorContextValue,
        privacy: privacy
      )
    }

    /// Creates an entry with a typed key and a matching value.
    public init<ContextValue: ErrorContextValue>(
      key: Key<ContextValue>,
      value: ContextValue,
      privacy: Privacy? = nil
    ) {
      self.init(
        key: AnyKey(key),
        value: value.errorContextValue,
        privacy: privacy ?? key.defaultPrivacy
      )
    }

    /// Returns this entry if it is visible under `projection`.
    public func projected(using projection: Projection) -> Self? {
      let isVisible: Bool

      switch privacy {
      case .public:
        isVisible = true
      case .private:
        isVisible = projection.visibility != .publicOnly
      case .sensitive:
        isVisible = projection.visibility == .diagnostic
      case .secret:
        isVisible = false
      }

      if isVisible {
        return self
      }

      guard projection.redaction == .placeholder else {
        return nil
      }

      return Self(key: key, value: .redacted(privacy), privacy: privacy)
    }

    /// A privacy-preserving keyed representation of the entry.
    public var description: String {
      "\(key.name)=\(_valueForDescription.description)"
    }

    /// A privacy-preserving structural description of the entry.
    public var debugDescription: String {
      "ErrorContext.Entry(key: \(key.debugDescription), value: \(_valueForDescription.debugDescription), privacy: \(privacy.debugDescription))"
    }

    private var _valueForDescription: Value {
      privacy == .public ? value : .redacted(privacy)
    }
  }

  /// Policy for exposing context at a presentation or export boundary.
  public struct Projection: Hashable, Sendable, CustomStringConvertible,
    CustomDebugStringConvertible
  {
    /// The most restrictive privacy level made visible by a projection.
    public enum Visibility: Hashable, Sendable, CustomStringConvertible,
      CustomDebugStringConvertible
    {
      /// Includes only public context.
      case publicOnly

      /// Includes public and private context.
      case includingPrivate

      /// Includes public, private, and sensitive context.
      case diagnostic

      public var description: String {
        switch self {
        case .publicOnly:
          return "publicOnly"
        case .includingPrivate:
          return "includingPrivate"
        case .diagnostic:
          return "diagnostic"
        }
      }

      public var debugDescription: String {
        ".\(description)"
      }
    }

    /// How a projection handles values that are not visible.
    public enum Redaction: Hashable, Sendable, CustomStringConvertible,
      CustomDebugStringConvertible
    {
      /// Removes values that are not visible.
      case omit

      /// Replaces values that are not visible with a placeholder.
      case placeholder

      public var description: String {
        switch self {
        case .omit:
          return "omit"
        case .placeholder:
          return "placeholder"
        }
      }

      public var debugDescription: String {
        ".\(description)"
      }
    }

    /// The context made visible by this projection.
    public let visibility: Visibility

    /// The treatment of context that is not visible.
    public let redaction: Redaction

    /// Creates a projection with the given visibility and redaction behavior.
    public init(
      visibility: Visibility,
      redaction: Redaction = .omit
    ) {
      self.visibility = visibility
      self.redaction = redaction
    }

    /// A projection that includes public context and omits everything else.
    public static let publicOnly = Self(visibility: .publicOnly)

    /// A projection that also includes private context.
    public static let includingPrivate = Self(visibility: .includingPrivate)

    /// A projection that also includes sensitive diagnostic context.
    public static let diagnostic = Self(visibility: .diagnostic)

    public var description: String {
      "\(visibility.description), \(redaction.description)"
    }

    public var debugDescription: String {
      "ErrorContext.Projection(visibility: \(visibility.debugDescription), redaction: \(redaction.debugDescription))"
    }
  }

  public typealias Index = Int
  public typealias Element = Entry

  private var entries: [Entry]

  public var startIndex: Index {
    entries.startIndex
  }

  public var endIndex: Index {
    entries.endIndex
  }

  /// Creates an empty context.
  public init() {
    entries = []
  }

  /// Creates context containing `entries` in iteration order.
  public init<S: Sequence>(_ entries: S) where S.Element == Entry {
    self.entries = Array(entries)
  }

  public init(arrayLiteral elements: Entry...) {
    self.init(elements)
  }

  public subscript(position: Index) -> Entry {
    entries[position]
  }

  public mutating func replaceSubrange<C: Collection>(
    _ subrange: Range<Index>,
    with newElements: C
  ) where C.Element == Entry {
    entries.replaceSubrange(subrange, with: newElements)
  }

  /// Returns the first value for `key` in insertion order.
  public subscript<ContextValue: ErrorContextValue>(key: Key<ContextValue>) -> ContextValue? {
    values(for: key).first
  }

  /// Returns every value for `key` in insertion order.
  public func values<ContextValue: ErrorContextValue>(
    for key: Key<ContextValue>
  ) -> [ContextValue] {
    entries.compactMap { entry in
      guard entry.key == AnyKey(key) else {
        return nil
      }

      return ContextValue(errorContextValue: entry.value)
    }
  }

  /// Returns every type-erased value for `key` in insertion order.
  public func values(for key: AnyKey) -> [Value] {
    entries.compactMap { entry in
      entry.key == key ? entry.value : nil
    }
  }

  /// Returns context safe to expose under `projection`.
  public func projected(using projection: Projection = .publicOnly) -> Self {
    Self(lazy.compactMap { $0.projected(using: projection) })
  }

  /// Public context in insertion order.
  public var description: String {
    "[\(projected().map(\.description).joined(separator: ", "))]"
  }

  /// A structural description with nonpublic values redacted.
  public var debugDescription: String {
    let entries = map(\.debugDescription).joined(separator: ", ")
    return "ErrorContext([\(entries)])"
  }
}
