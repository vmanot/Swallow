//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias _Swallow_DeclScopeType = Swallow.module.DeclarationScopeType
public typealias _Swallow_DeclScope<ParentScopeType: Hashable, ScopeType: Hashable> = Swallow.module.DeclarationScope<ParentScopeType, ScopeType>
public typealias _Swallow_DeclScopeOf<T: Hashable> = Swallow.module.DeclarationScopeOf<T>
public typealias _Swallow_DeclScopeConjunction<LHS: Hashable, RHS: Hashable> = Swallow.module.DeclarationScopeConjunction<LHS, RHS>
public typealias _Swallow_DeclScopeConjunctionType = Swallow.module.DeclarationScopeConjunctionType 

extension Swallow.module {
    public protocol DeclarationScopeType: Hashable {
        associatedtype ParentScopeType: Hashable
        associatedtype ScopeType: Hashable
    }
    
    public protocol DeclarationScopeConjunctionType: Hashable {
        associatedtype LHS: DeclarationScopeType
        associatedtype RHS: DeclarationScopeType
    }
    
    public protocol NestedDeclarationScopeType: DeclarationScopeType where ScopeType: DeclarationScopeType {
        
    }
    
    public struct DeclarationScope<ParentScopeType: Hashable, ScopeType: Hashable>: DeclarationScopeType {
        public init() {
            
        }
    }
    
    public struct DeclarationScopeConjunction<LHS: Hashable, RHS: Hashable>: Hashable {

    }
    
    public typealias DeclarationScopeOf<ScopeType: Hashable> = DeclarationScope<Never, ScopeType>
    
    public protocol ScopedDeclaration<ScopeType> {
        associatedtype ScopeType: DeclarationScopeType
        
        static var declarationScope: ScopeType { get }
    }
    
    public enum ScopedDeclarations {
        
    }
}

extension Swallow.module.DeclarationScopeConjunction: _Swallow_DeclScopeType where LHS: _Swallow_DeclScopeType, RHS: _Swallow_DeclScopeType {
    public typealias ParentScopeType = _Swallow_DeclScopeConjunction<LHS.ParentScopeType, RHS.ParentScopeType>
    public typealias ScopeType = Hashable2ple<LHS.ScopeType, RHS.ScopeType>
}

extension Swallow.module.DeclarationScope where ParentScopeType == Never {
    public typealias NestedIn<Parent: _Swallow_DeclScopeType> = _Swallow_DeclScope<_Swallow_DeclScopeOf<Parent.ScopeType>, Self.ScopeType> where Parent.ParentScopeType == Never
    
    public static func --> <Parent: _Swallow_DeclScopeType>(
        lhs: Parent,
        rhs: Self
    ) -> Self.NestedIn<Parent> {
        Self.NestedIn<Parent>()
    }
}

extension Swallow.module.DeclarationScope where ParentScopeType == Never {
    public typealias ConjunctionWith<OtherScopeType: _Swallow_DeclScopeType> = _Swallow_DeclScopeConjunction<Self, OtherScopeType>
    
    public static func <--> <OtherScopeType: _Swallow_DeclScopeType>(
        lhs: Self,
        rhs: OtherScopeType
    ) -> Self.ConjunctionWith<OtherScopeType> {
        Self.ConjunctionWith<OtherScopeType>()
    }
}

extension Swallow.module.DeclarationScope: Swallow.module.NestedDeclarationScopeType where ScopeType: Swallow.module.DeclarationScopeType {
    
}

// MARK: - Usage Example

private extension Swallow.module {
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
