//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension PatternBindingSyntax {
    /// What this binding's accessor syntax proves about property storage.
    public enum SyntacticPropertyStorage: Hashable, Sendable {
        case stored
        case accessorBacked
        case mixedOrMalformedAccessors
    }

    /// Classifies storage solely from this binding's accessor syntax.
    ///
    /// No accessor block and unique observer-only blocks are stored. Getter
    /// bodies and non-observer accessor lists are accessor-backed. Empty lists,
    /// duplicate observers, and mixed observer/non-observer lists cannot be
    /// classified without accepting malformed source as a valid storage form.
    public var syntacticPropertyStorage: SyntacticPropertyStorage {
        switch accessorBlock?.accessors {
            case nil:
                return .stored
            case .getter:
                return .accessorBacked
            case .accessors(let accessors):
                guard !accessors.isEmpty else {
                    return .mixedOrMalformedAccessors
                }

                let observerSpecifiers = accessors.compactMap { accessor -> Keyword? in
                    switch accessor.accessorSpecifier.tokenKind {
                        case .keyword(.willSet):
                            return .willSet
                        case .keyword(.didSet):
                            return .didSet
                        default:
                            return nil
                    }
                }

                guard !observerSpecifiers.isEmpty else {
                    return .accessorBacked
                }

                guard observerSpecifiers.count == accessors.count,
                      Set(observerSpecifiers).count == observerSpecifiers.count else {
                    return .mixedOrMalformedAccessors
                }

                return .stored
            @unknown default:
                return .mixedOrMalformedAccessors
        }
    }

    public var setter: AccessorDeclSyntax? {
        get {
            guard
                let accessors: AccessorBlockSyntax.Accessors = accessorBlock?.accessors,
                case let .accessors(list) = accessors
            else {
                return nil
            }
            
            return list.first(where: {
                $0.accessorSpecifier.tokenKind == .keyword(.set)
            })
        }
        
        set {
            setNewAccessor(specifier: .set, newValue: newValue)
        }
    }
    
    public var getter: AccessorDeclSyntax? {
        get {
            switch accessorBlock?.accessors {
                case let .accessors(list):
                    return list.first(where: {
                        $0.accessorSpecifier.tokenKind == .keyword(.get)
                    })
                case let .getter(body):
                    return AccessorDeclSyntax(accessorSpecifier: .keyword(.get), body: .init(statements: body))
                case .none:
                    return nil
                @unknown default:
                    return nil
            }
        } set {
            let newValue = newValue.map { accessor in
                var accessor = accessor
                accessor.accessorSpecifier = .keyword(.get)

                return accessor
            }
            let newAccessors: AccessorBlockSyntax.Accessors
            
            switch accessorBlock?.accessors {
                case .getter, .none:
                    if let newValue {
                        if let body = newValue.body {
                            newAccessors = .getter(body.statements)
                        } else {
                            let accessors = AccessorDeclListSyntax {
                                newValue
                            }
                            newAccessors = .accessors(accessors)
                        }
                    } else {
                        accessorBlock = .none
                        return
                    }
                    
                case let .accessors(list):
                    var newList = list
                    let accessor = list.first(where: { accessor in
                        accessor.accessorSpecifier.tokenKind == .keyword(.get)
                    })
                    if let accessor,
                       let index = list.firstIndex(of: accessor) {
                        if let newValue {
                            newList[index] = newValue
                        } else {
                            newList.remove(at: index)
                        }
                    } else if let newValue {
                        newList.append(newValue)
                    }
                    newAccessors = .accessors(newList)
                @unknown default:
                    return
            }

            replaceAccessors(with: newAccessors)
        }
    }
    
}

extension PatternBindingSyntax {
    public var willSet: AccessorDeclSyntax? {
        get {
            if let accessors = accessorBlock?.accessors,
               case let .accessors(list) = accessors {
                return list.first(where: {
                    $0.accessorSpecifier.tokenKind == .keyword(.willSet)
                })
            }
            return nil
        }
        set {
            setNewAccessor(specifier: .willSet, newValue: newValue)
        }
    }
    
    public var didSet: AccessorDeclSyntax? {
        get {
            if let accessors = accessorBlock?.accessors,
               case let .accessors(list) = accessors {
                return list.first(where: {
                    $0.accessorSpecifier.tokenKind == .keyword(.didSet)
                })
            }
            return nil
        }
        set {
            setNewAccessor(specifier: .didSet, newValue: newValue)
        }
    }
}

extension PatternBindingSyntax {
    private mutating func setNewAccessor(
        specifier: Keyword,
        newValue: AccessorDeclSyntax?
    ) {
        let newValue = newValue.map { accessor in
            var accessor = accessor
            accessor.accessorSpecifier = .keyword(specifier)

            return accessor
        }
        let newAccessors: AccessorBlockSyntax.Accessors
        
        switch accessorBlock?.accessors {
            case let .getter(body):
                guard let newValue else {
                    return
                }
                
                newAccessors = .accessors(
                    AccessorDeclListSyntax {
                        AccessorDeclSyntax(accessorSpecifier: .keyword(.get), body: .init(statements: body))
                        newValue
                    }
                )
            case let .accessors(list):
                var newList = list
                let accessor = list.first(where: { accessor in
                    accessor.accessorSpecifier.tokenKind == .keyword(specifier)
                })
                if let accessor,
                   let index = list.firstIndex(of: accessor) {
                    if let newValue {
                        newList[index] = newValue
                    } else {
                        newList.remove(at: index)
                    }
                } else if let newValue {
                    newList.append(newValue)
                }
                newAccessors = .accessors(newList)
            case nil:
                guard let newValue else {
                    return
                }
                
                newAccessors = .accessors(
                    AccessorDeclListSyntax {
                        newValue
                    }
                )
            @unknown default:
                return
        }

        replaceAccessors(with: newAccessors)
    }

    private mutating func replaceAccessors(
        with newAccessors: AccessorBlockSyntax.Accessors
    ) {
        if case .accessors(let list) = newAccessors, list.isEmpty {
            accessorBlock = nil

            return
        }

        if accessorBlock == nil {
            accessorBlock = .init(accessors: newAccessors)
        } else {
            accessorBlock = accessorBlock?.with(\.accessors, newAccessors)
        }
    }
}
