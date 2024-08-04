//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct _ManagedActorMethodName: Codable, Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

@dynamicMemberLookup
public protocol _ManagedActorMethodTrampolineList: Initiable {
    associatedtype ManagedActorType: _ManagedActorProtocol
        
    dynamic subscript<T: _ManagedActorMethodTrampolineProtocol>(
        dynamicMember keyPath: KeyPath<ManagedActorType, T>
    ) -> ManagedActorMethodTrampolineKeyPath<ManagedActorType, T> { get }
}

// MARK: - Implementation

extension _ManagedActorMethodTrampolineList {
    public dynamic subscript<T: _ManagedActorMethodTrampolineProtocol>(
        dynamicMember keyPath: KeyPath<ManagedActorType, T>
    ) -> ManagedActorMethodTrampolineKeyPath<ManagedActorType, T> {
        get {
            ManagedActorMethodTrampolineKeyPath(keyPath: keyPath)
        }
    }
}

// MARK: - Auxiliary

open class _AnyManagedActorMethodTrampoline {
    public var _caller: Any?
    
    public init() {
        
    }
}

open class _PartialManagedActorMethodTrampoline<ActorType>: _AnyManagedActorMethodTrampoline {
    public typealias OwnerType = ActorType
}

public struct ManagedActorMethodTrampolineKeyPath<ActorType: _ManagedActorProtocol, TrampolineType: _ManagedActorMethodTrampolineProtocol> {
    public let keyPath: KeyPath<ActorType, TrampolineType>
}

public protocol _ManagedActorMethodTrampolineProtocol: _AnyManagedActorMethodTrampoline, Initiable {
    associatedtype OwnerType: _ManagedActorProtocol
    
    typealias _OptionalOwnerType = Optional<OwnerType>
    
    static var name: _ManagedActorMethodName { get }
}

extension _ManagedActorMethodTrampolineProtocol {
    public var caller: OwnerType {
        get {
            self._caller! as! OwnerType
        } set {
            self._caller = newValue
        }
    }
}
