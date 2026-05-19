//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Internal normalized structure for traversing composed failures.
struct _ErrorFailureTopology: Sendable {
    var root: Node

    init(
        root: Node
    ) {
        self.root = root
    }

    init(
        _ tree: _ErrorFailureTree
    ) {
        self.init(root: Node(tree))
    }
}

extension _ErrorFailureTopology {
    enum Node: Sendable {
        case error(AnyError)
        case relation(Relation)

        init(
            _ tree: _ErrorFailureTree
        ) {
            switch tree {
                case .error(let error):
                    self = .error(error)
                case .relation(let relation):
                    self = .relation(.init(relation))
            }
        }
    }

    struct Relation: Sendable {
        var role: _ErrorFailureRelationRole
        var children: [Node]
        var context: [_ErrorContextBinding]

        init(
            role: _ErrorFailureRelationRole,
            children: [Node],
            context: [_ErrorContextBinding]
        ) {
            self.role = role
            self.children = children
            self.context = context
        }

        init(
            _ relation: _ErrorFailureRelation
        ) {
            self.init(
                role: relation.role,
                children: relation.children.map(Node.init),
                context: relation.context
            )
        }
    }

    struct Path: Hashable, Sendable {
        var indices: [Int]

        init(
            indices: [Int] = []
        ) {
            self.indices = indices
        }

        func appending(
            _ index: Int
        ) -> Self {
            .init(indices: indices + [index])
        }
    }

    struct IdentityOccurrence: Sendable {
        var path: Path
        var relationRoles: [_ErrorFailureRelationRole]
        var error: AnyError
        var identity: _ErrorIdentity
    }

    struct ContextOccurrence: Sendable {
        var path: Path
        var relationRoles: [_ErrorFailureRelationRole]
        var context: _ErrorContextBinding
    }

    struct DiagnosticLabelOccurrence: Sendable {
        var path: Path
        var relationRoles: [_ErrorFailureRelationRole]
        var label: _ErrorDiagnosticLabel
    }
}

extension _ErrorFailureTopology {
    private static let maximumDepth = 64

    func identityOccurrences() -> [IdentityOccurrence] {
        var result: [IdentityOccurrence] = []
        var visitedClassErrors: Set<ObjectIdentifier> = []

        _collectIdentityOccurrences(
            in: root,
            path: .init(),
            relationRoles: [],
            depth: 0,
            visitedClassErrors: &visitedClassErrors,
            result: &result
        )

        return result
    }

    func contextBindings() -> [_ErrorContextBinding] {
        contextOccurrences().map(\.context)
    }

    func contextOccurrences() -> [ContextOccurrence] {
        var result: [ContextOccurrence] = []
        var visitedClassErrors: Set<ObjectIdentifier> = []

        _collectContextOccurrences(
            in: root,
            path: .init(),
            relationRoles: [],
            depth: 0,
            visitedClassErrors: &visitedClassErrors,
            result: &result
        )

        return result
    }

    func diagnosticLabelOccurrences() -> [DiagnosticLabelOccurrence] {
        var result: [DiagnosticLabelOccurrence] = []
        var visitedClassErrors: Set<ObjectIdentifier> = []

        _collectDiagnosticLabelOccurrences(
            in: root,
            path: .init(),
            relationRoles: [],
            depth: 0,
            visitedClassErrors: &visitedClassErrors,
            result: &result
        )

        return result
    }

    private func _collectDiagnosticLabelOccurrences(
        in node: Node,
        path: Path,
        relationRoles: [_ErrorFailureRelationRole],
        depth: Int,
        visitedClassErrors: inout Set<ObjectIdentifier>,
        result: inout [DiagnosticLabelOccurrence]
    ) {
        guard depth < Self.maximumDepth else {
            return
        }

        switch node {
            case .error(let error):
                let base = error.base._errorXBase

                if let objectIdentifier = _classObjectIdentifier(of: base) {
                    guard visitedClassErrors.insert(objectIdentifier).inserted else {
                        return
                    }
                }

                guard let error = base as? any _ErrorDiagnosticLabelsRepresentable else {
                    return
                }

                result.append(
                    contentsOf: error.errorDiagnosticLabels.map { (label: _ErrorDiagnosticLabel) in
                        .init(
                            path: path,
                            relationRoles: relationRoles,
                            label: label
                        )
                    }
                )
            case .relation(let relation):
                let currentRoles = relationRoles + [relation.role]

                for (index, child) in relation.children.enumerated() {
                    _collectDiagnosticLabelOccurrences(
                        in: child,
                        path: path.appending(index),
                        relationRoles: currentRoles,
                        depth: depth + 1,
                        visitedClassErrors: &visitedClassErrors,
                        result: &result
                    )
                }
        }
    }

    private func _collectContextOccurrences(
        in node: Node,
        path: Path,
        relationRoles: [_ErrorFailureRelationRole],
        depth: Int,
        visitedClassErrors: inout Set<ObjectIdentifier>,
        result: inout [ContextOccurrence]
    ) {
        guard depth < Self.maximumDepth else {
            return
        }

        switch node {
            case .error(let error):
                let base = error.base._errorXBase

                if let objectIdentifier = _classObjectIdentifier(of: base) {
                    guard visitedClassErrors.insert(objectIdentifier).inserted else {
                        return
                    }
                }

                let bindings: [_ErrorContextBinding]

                if let descriptorCase = (base as? any _ErrorDescribed)?._errorDescriptorCase {
                    bindings = descriptorCase.context
                } else if let error = base as? any _ErrorOccurrenceContextRepresentable {
                    bindings = error.errorOccurrenceContextBindings
                } else {
                    bindings = []
                }

                result.append(
                    contentsOf: bindings.map { binding in
                        .init(
                            path: path,
                            relationRoles: relationRoles,
                            context: binding
                        )
                    }
                )
            case .relation(let relation):
                let currentRoles = relationRoles + [relation.role]

                result.append(
                    contentsOf: relation.context.map { binding in
                        .init(
                            path: path,
                            relationRoles: currentRoles,
                            context: binding
                        )
                    }
                )

                for (index, child) in relation.children.enumerated() {
                    _collectContextOccurrences(
                        in: child,
                        path: path.appending(index),
                        relationRoles: currentRoles,
                        depth: depth + 1,
                        visitedClassErrors: &visitedClassErrors,
                        result: &result
                    )
                }
        }
    }

    private func _collectIdentityOccurrences(
        in node: Node,
        path: Path,
        relationRoles: [_ErrorFailureRelationRole],
        depth: Int,
        visitedClassErrors: inout Set<ObjectIdentifier>,
        result: inout [IdentityOccurrence]
    ) {
        guard depth < Self.maximumDepth else {
            return
        }

        switch node {
            case .error(let error):
                let base = error.base._errorXBase

                if let objectIdentifier = _classObjectIdentifier(of: base) {
                    guard visitedClassErrors.insert(objectIdentifier).inserted else {
                        return
                    }
                }

                if let identity = base._errorIdentity {
                    result.append(
                        .init(
                            path: path,
                            relationRoles: relationRoles,
                            error: AnyError(erasing: base),
                            identity: identity
                        )
                    )
                }
            case .relation(let relation):
                for (index, child) in relation.children.enumerated() {
                    _collectIdentityOccurrences(
                        in: child,
                        path: path.appending(index),
                        relationRoles: relationRoles + [relation.role],
                        depth: depth + 1,
                        visitedClassErrors: &visitedClassErrors,
                        result: &result
                    )
                }
        }
    }

    private func _classObjectIdentifier(
        of error: any Error
    ) -> ObjectIdentifier? {
        guard Mirror(reflecting: error).displayStyle == .class else {
            return nil
        }

        return ObjectIdentifier(error as AnyObject)
    }
}
