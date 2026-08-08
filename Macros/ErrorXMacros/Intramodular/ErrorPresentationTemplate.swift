//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxUtilities

/// A presentation string authored on an error case, with its `\(...)`
/// placeholders rewritten onto that case's associated values.
///
/// Swift type-checks an attached macro's attribute arguments, and a case's
/// associated-value names are not in scope at the attribute. A real Swift
/// interpolation such as `message: "Cannot copy sources for \(module)."`
/// therefore fails to compile before `@ErrorModel` ever runs, with
/// `cannot find 'module' in scope`.
///
/// A template accepts the same spelling inside an *inert* string literal
/// instead. A raw literal is the intended form, because `\(` is not an
/// interpolation there:
///
///     @ErrorCode(message: #"Cannot copy sources for \(module)."#)
///     case unavailableModuleSourceDirectory(module: String)
///
/// A genuinely interpolated literal is also accepted, which is the spelling
/// macro-expansion tests can use because they do not type-check the attribute.
///
/// Each placeholder must begin with the name of exactly one associated value of
/// the enclosing case. Whatever follows that name is emitted verbatim, so
/// `\(xcFrameworkURL.path)` works. A literal `\(` cannot appear in a template.
struct ErrorPresentationTemplate {
  private enum Segment {
    /// Content already escaped for embedding in a single-line `"` literal.
    case escapedLiteralContent(String)

    /// Source for an expression to interpolate.
    case interpolatedExpression(String)
  }

  private let segments: [Segment]

  /// The generated case bindings this template reads.
  let referencedBindingNames: Set<String>

  /// Source for a Swift string-literal expression producing this string.
  var expressionSource: String {
    var result = "\""

    for segment in segments {
      switch segment {
      case .escapedLiteralContent(let content):
        result += content
      case .interpolatedExpression(let source):
        result += "\\(" + source + ")"
      }
    }

    return result + "\""
  }
}

extension ErrorPresentationTemplate {
  /// Parses `expression` as the value of `@ErrorCode`'s `label` argument.
  ///
  /// - Parameter resolveBindingName: Maps an associated-value name written in
  ///   a placeholder to the binding the generated `switch` introduces for it,
  ///   throwing when the name does not select exactly one associated value.
  init(
    expression: ExprSyntax,
    label: String,
    resolveBindingName: (String) throws -> String
  ) throws {
    var segments: [Segment] = []
    var referencedBindingNames: Set<String> = []

    func appendPlaceholder(_ placeholder: String) throws {
      let substitution = try Self._substitutedPlaceholder(
        placeholder,
        label: label,
        resolveBindingName: resolveBindingName
      )

      referencedBindingNames.insert(substitution.bindingName)
      segments.append(.interpolatedExpression(substitution.source))
    }

    if let representedValue = expression.representedStringLiteralValue {
      // An inert literal: placeholders survive into the represented value.
      for part in try Self._parts(inRepresentedValue: representedValue, label: label) {
        switch part {
        case .literal(let content):
          segments.append(.escapedLiteralContent(content._errorXEscapedStringLiteralContent))
        case .placeholder(let placeholder):
          try appendPlaceholder(placeholder)
        }
      }
    } else if let literal = expression.as(StringLiteralExprSyntax.self) {
      // A genuinely interpolated literal.
      guard literal.openingPounds == nil,
        literal.openingQuote.tokenKind == .stringQuote
      else {
        throw ErrorXMacroDiagnostic.error(
          .invalidPresentation,
          "@ErrorCode '\(label):' cannot combine string interpolation with a raw or multiline string literal."
        )
      }

      for segment in literal.segments {
        switch segment {
        case .stringSegment(let stringSegment):
          // Already escaped for a single-line `"` literal.
          segments.append(.escapedLiteralContent(stringSegment.content.text))
        case .expressionSegment(let expressionSegment):
          guard expressionSegment.expressions.count == 1,
            let interpolated = expressionSegment.expressions.first,
            interpolated.label == nil
          else {
            throw ErrorXMacroDiagnostic.error(
              .invalidPresentationPlaceholder,
              "@ErrorCode '\(label):' placeholders take one unlabeled expression."
            )
          }

          try appendPlaceholder(interpolated.expression.trimmedDescription)
        }
      }
    } else {
      throw ErrorXMacroDiagnostic.error(
        .invalidPresentation,
        "Expected '\(label):' to be a string literal."
      )
    }

    self.segments = segments
    self.referencedBindingNames = referencedBindingNames
  }
}

extension ErrorPresentationTemplate {
  private enum Part {
    case literal(String)
    case placeholder(String)
  }

  /// Splits an inert literal's represented value on its `\(...)` placeholders.
  private static func _parts(
    inRepresentedValue value: String,
    label: String
  ) throws -> [Part] {
    var result: [Part] = []
    var literal = ""
    var index = value.startIndex

    while index < value.endIndex {
      let next = value.index(after: index)

      guard value[index] == "\\", next < value.endIndex, value[next] == "(" else {
        literal.append(value[index])

        index = next

        continue
      }

      var cursor = value.index(after: next)
      var placeholder = ""
      var depth = 1
      var isInsideStringLiteral = false

      while cursor < value.endIndex {
        let character = value[cursor]

        if character == "\"" {
          isInsideStringLiteral.toggle()
        } else if !isInsideStringLiteral, character == "(" {
          depth += 1
        } else if !isInsideStringLiteral, character == ")" {
          depth -= 1

          if depth == 0 {
            break
          }
        }

        placeholder.append(character)

        cursor = value.index(after: cursor)
      }

      guard depth == 0 else {
        throw ErrorXMacroDiagnostic.error(
          .invalidPresentation,
          "@ErrorCode '\(label):' has an unterminated '\\(' placeholder."
        )
      }

      if !literal.isEmpty {
        result.append(.literal(literal))

        literal = ""
      }

      result.append(.placeholder(placeholder))

      index = value.index(after: cursor)
    }

    if !literal.isEmpty {
      result.append(.literal(literal))
    }

    return result
  }

  /// Rewrites a placeholder's leading associated-value name onto its binding.
  private static func _substitutedPlaceholder(
    _ placeholder: String,
    label: String,
    resolveBindingName: (String) throws -> String
  ) throws -> (source: String, bindingName: String) {
    let body = Substring(placeholder).drop { $0 == " " || $0 == "\t" }
    let name = body.prefix { $0.isLetter || $0.isNumber || $0 == "_" }

    // An all-digit name is a positional index, which is the only way to reach an associated value
    // that has no label — `case invalidSourceRepository(String)` is referenced as `\(0)`.
    let isPositionalIndex: Bool = !name.isEmpty && name.allSatisfy(\.isNumber)

    guard let first = name.first, first.isLetter || first == "_" || isPositionalIndex else {
      throw ErrorXMacroDiagnostic.error(
        .invalidPresentationPlaceholder,
        "@ErrorCode '\(label):' placeholder '\\(\(placeholder))' must begin with an associated-value name or a positional index."
      )
    }

    let bindingName = try resolveBindingName(String(name))

    return (
      source: bindingName + String(body.dropFirst(name.count)),
      bindingName: bindingName
    )
  }
}

extension String {
  /// This string escaped for embedding in a single-line `"` string literal.
  fileprivate var _errorXEscapedStringLiteralContent: String {
    var result = ""

    for character in self {
      switch character {
      case "\\":
        result += "\\\\"
      case "\"":
        result += "\\\""
      case "\n":
        result += "\\n"
      case "\r":
        result += "\\r"
      case "\t":
        result += "\\t"
      case "\0":
        result += "\\0"
      default:
        result.append(character)
      }
    }

    return result
  }
}
