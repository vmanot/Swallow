//
// Copyright (c) Vatsal Manot
//

import Swift

extension _StaticSwift {
    public protocol DeclarationScopeType: Hashable {
        associatedtype ParentScopeType: Hashable
        associatedtype ScopeType: Hashable
    }
    
    public struct DeclarationScope<ParentScopeType: Hashable, ScopeType: Hashable>: DeclarationScopeType {
        public init() {
            
        }
    }
    
    public typealias DeclarationScopeOf<ScopeType: Hashable> = DeclarationScope<Never, ScopeType>
    
    public static func _declarationScope<S: DeclarationScopeType>(
        _ scope: S
    ) -> S {
        scope
    }
}

extension _StaticSwift {
    public protocol DeclarationScopedType<ScopeType> {
        associatedtype ScopeType: _StaticSwift.DeclarationScopeType
        
        static var _StaticSwift_declarationScope: ScopeType { get }
    }
    
    /// A declaration scope that is nested within another declaration scope.
    public protocol NestedDeclarationScopeType: DeclarationScopeType where ScopeType: DeclarationScopeType {
        
    }
    
    public enum DeclarationScoped: _StaticSwift.Namespace {
        
    }
}

extension _StaticSwift {
    /// A conjunction of two declaration scopes.
    public protocol DeclarationScopeConjunctionType: Hashable {
        associatedtype LHS: DeclarationScopeType
        associatedtype RHS: DeclarationScopeType
    }
    
    public struct DeclarationScopeConjunction<LHS: Hashable, RHS: Hashable>: Hashable {
        
    }
}

extension _StaticSwift.DeclarationScope: _StaticSwift.NestedDeclarationScopeType where ScopeType: _StaticSwift.DeclarationScopeType {
    
}

extension _StaticSwift.DeclarationScope where ParentScopeType == Never {
    public typealias NestedIn<Parent: _StaticSwift_DeclScopeType> = _StaticSwift_DeclScope<_StaticSwift_DeclScopeOf<Parent.ScopeType>, Self.ScopeType> where Parent.ParentScopeType == Never
    
    public static func --> <Parent: _StaticSwift_DeclScopeType>(
        lhs: Parent,
        rhs: Self
    ) -> Self.NestedIn<Parent> {
        Self.NestedIn<Parent>()
    }
}

extension _StaticSwift.DeclarationScopeConjunction: _StaticSwift_DeclScopeType where LHS: _StaticSwift_DeclScopeType, RHS: _StaticSwift_DeclScopeType {
    public typealias ParentScopeType = _StaticSwift_DeclScopeConjunction<LHS.ParentScopeType, RHS.ParentScopeType>
    public typealias ScopeType = Hashable2ple<LHS.ScopeType, RHS.ScopeType>
}

extension _StaticSwift.DeclarationScope where ParentScopeType == Never {
    public typealias ConjunctionWith<OtherScopeType: _StaticSwift_DeclScopeType> = _StaticSwift_DeclScopeConjunction<Self, OtherScopeType>
    
    public static func <--> <OtherScopeType: _StaticSwift_DeclScopeType>(
        lhs: Self,
        rhs: OtherScopeType
    ) -> Self.ConjunctionWith<OtherScopeType> {
        Self.ConjunctionWith<OtherScopeType>()
    }
}

// MARK: - Supplementary

public typealias _StaticSwift_DeclScopeType = _StaticSwift.DeclarationScopeType
public typealias _StaticSwift_DeclScope<ParentScopeType: Hashable, ScopeType: Hashable> = _StaticSwift.DeclarationScope<ParentScopeType, ScopeType>
public typealias _StaticSwift_DeclScopeOf<T: Hashable> = _StaticSwift.DeclarationScopeOf<T>
public typealias _StaticSwift_DeclScopeConjunction<LHS: Hashable, RHS: Hashable> = _StaticSwift.DeclarationScopeConjunction<LHS, RHS>
public typealias _StaticSwift_DeclScopeConjunctionType = _StaticSwift.DeclarationScopeConjunctionType

// MARK: - Usage Example

private extension _StaticSwift {
    struct ExampleScopes {
        public struct One: Hashable {
            
        }
        
        public struct Two: Hashable {
            
        }
    }
    
    typealias ExampleDeclScope_1 = DeclarationScopeOf<ExampleScopes.One>
    typealias ExampleDeclScope_2 = DeclarationScopeOf<ExampleScopes.Two>
    typealias ExampleDeclScope_1_2 = DeclarationScopeOf<ExampleDeclScope_2>.NestedIn<DeclarationScopeOf<ExampleDeclScope_1>>
}


