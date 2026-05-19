//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A structured subject that a diagnostic label can point at.
public enum _ErrorDiagnosticSubject: Hashable, Sendable, CustomStringConvertible {
    case commandLineArgument(index: Int)
    case commandLineArgumentRange(lowerBound: Int, upperBound: Int)
    case commandLineOption(name: String)
    case commandLineSubcommand(path: [String])
    case sourceLocation(SourceCodeLocation)

    public var description: String {
        switch self {
            case .commandLineArgument(let index):
                return "argument[\(index)]"
            case .commandLineArgumentRange(let lowerBound, let upperBound):
                return "arguments[\(lowerBound)..<\(upperBound)]"
            case .commandLineOption(let name):
                return "option \(name)"
            case .commandLineSubcommand(let path):
                return "subcommand \(path.joined(separator: " "))"
            case .sourceLocation(let location):
                return String(describing: location)
        }
    }
}

/// A labeled diagnostic pointer associated with an error occurrence.
public struct _ErrorDiagnosticLabel: Hashable, Sendable, CustomStringConvertible {
    public var subject: _ErrorDiagnosticSubject
    public var message: String?
    public var privacy: _ErrorContextPrivacy

    public init(
        subject: _ErrorDiagnosticSubject,
        message: String? = nil,
        privacy: _ErrorContextPrivacy = .public
    ) {
        self.subject = subject
        self.message = message
        self.privacy = privacy
    }

    public var description: String {
        if let message, !message.isEmpty {
            return "\(subject): \(message)"
        } else {
            return subject.description
        }
    }

    public func projected(
        using policy: _ErrorContextBinding.ProjectionPolicy
    ) -> Self? {
        switch privacy {
            case .public:
                return self
            case .private:
                switch policy.visibility {
                    case .publicOnly:
                        return policy.includesRedactedPlaceholders ? redacted("<redacted>") : nil
                    case .publicAndPrivate, .allDiagnostic:
                        return self
                }
            case .sensitive:
                switch policy.visibility {
                    case .publicOnly:
                        return policy.includesRedactedPlaceholders ? redacted("<redacted>") : nil
                    case .publicAndPrivate:
                        return redacted("<redacted>")
                    case .allDiagnostic:
                        return self
                }
            case .secret:
                return policy.includesRedactedPlaceholders ? redacted("<secret>") : nil
            case .redacted:
                return redacted("<redacted>")
            case .omitted:
                return nil
        }
    }

    private func redacted(
        _ placeholder: String
    ) -> Self {
        .init(
            subject: subject,
            message: placeholder,
            privacy: privacy
        )
    }
}

/// Manual fallback for errors that provide diagnostic labels.
public protocol _ErrorDiagnosticLabelsRepresentable {
    var errorDiagnosticLabels: [_ErrorDiagnosticLabel] { get }
}
