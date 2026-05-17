//
// Copyright (c) Vatsal Manot
//

extension _ErrorReporting {
    public static func report<Operation: _ErrorObservationOperation>(
        _ error: any Swift.Error,
        operation: Operation
    ) -> _ErrorReport {
        report(
            error,
            observation: .init(
                scenario: .init(
                    typeIdentifier: String(reflecting: Operation.self),
                    stableIdentifier: operation.stableIdentifier
                ),
                contextBindings: [
                    .init(
                        key: _UnstructuredErrorObservationOperation._contextKey,
                        value: .string(operation.stableIdentifier)
                    )
                ]
            )
        )
    }

    public static func report<Failure: _ErrorX, Operation: _ErrorObservationOperation>(
        _ error: Failure,
        operation: Operation
    ) -> _ErrorReport {
        report(error as any Swift.Error, operation: operation)
    }
}

extension Error {
    public func _errorReport<Operation: _ErrorObservationOperation>(
        operation: Operation
    ) -> _ErrorReport {
        _ErrorReporting.report(self as any Swift.Error, operation: operation)
    }

    public func _diagnosticDescription<Operation: _ErrorObservationOperation>(
        operation: Operation,
        detailLevel: _ErrorDiagnosticDescription.DetailLevel = .compact,
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> String {
        _ErrorReporting.report(self as any Swift.Error, operation: operation)
            ._diagnosticDescription(
                detailLevel: detailLevel,
                contextProjectionPolicy: contextProjectionPolicy
            )
            .description
    }

    public func _nsErrorExportRepresentation<Operation: _ErrorObservationOperation>(
        operation: Operation,
        contextProjectionPolicy: _ErrorContextBinding.ProjectionPolicy = .publicOnly
    ) -> _NSErrorExportRepresentation {
        _NSErrorExportRepresentation(
            _ErrorReporting.report(self as any Swift.Error, operation: operation),
            contextProjectionPolicy: contextProjectionPolicy
        )
    }
}

extension _UnstructuredErrorObservationOperation {
    fileprivate static var _contextKey: _ErrorContextBinding.Key {
        "_error.observation.operation"
    }
}
