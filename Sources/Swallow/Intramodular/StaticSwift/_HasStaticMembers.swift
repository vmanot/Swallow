//
// Copyright (c) Vatsal Manot
//

import Swift

open class _StaticMembersOf<T> {
    public required init() {
        
    }
}

@dynamicMemberLookup
public protocol _HasStaticMembers {
    associatedtype _StaticMembers: _StaticMembersOf<Self>
    
    static subscript<T>(dynamicMember keyPath: KeyPath<_StaticMembers, T>) -> T { get }
}

extension _HasStaticMembers {
    static subscript<T>(dynamicMember keyPath: KeyPath<_StaticMembers, T>) -> T {
        get {
            _StaticMembers.init()[keyPath: keyPath]
        }
    }
}
