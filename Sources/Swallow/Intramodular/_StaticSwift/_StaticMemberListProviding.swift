//
// Copyright (c) Vatsal Manot
//

import Swift

extension _StaticSwift {
    open class MemberListOf<T> {
        public required init() {
            
        }
    }
}

@dynamicMemberLookup
public protocol _StaticMemberListProviding {
    associatedtype _StaticMemberListType: _StaticSwift.MemberListOf<Self>
    
    static subscript<T>(
        dynamicMember keyPath: KeyPath<_StaticMemberListType, T>
    ) -> T { get }
}

extension _StaticMemberListProviding {
    public static subscript<T>(
        dynamicMember keyPath: KeyPath<_StaticMemberListType, T>
    ) -> T {
        get {
            _StaticMemberListType.init()[keyPath: keyPath]
        }
    }
}
