//
// Copyright (c) Vatsal Manot
//

import ObjectiveC

extension objc_AssociationPolicy {
    public enum Atomicity {
        case atomic
        case nonatomic
    }
    
    public static var assign: Self {
        .OBJC_ASSOCIATION_ASSIGN
    }
    
    public static func retain(_ atomicity: Atomicity) -> Self {
        switch atomicity {
            case .atomic:
                return .OBJC_ASSOCIATION_RETAIN
            case .nonatomic:
                return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        }
    }
    
    public static func copy(_ atomicity: Atomicity) -> Self {
        switch atomicity {
            case .atomic:
                return .OBJC_ASSOCIATION_COPY
            case .nonatomic:
                return .OBJC_ASSOCIATION_COPY_NONATOMIC
        }
    }
}
