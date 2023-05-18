//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public enum ObjCAssociationPolicy: Initiable {
    case assign
    case retainNonatomic
    case copyNonatomic
    case retain
    case copy

    public init() {
        self = .retain
    }
}

extension ObjCAssociationPolicy: Hashable, RawRepresentable {
    public typealias RawValue = objc_AssociationPolicy
    
    public var rawValue: RawValue {
        switch self {
            case .assign:
                return .OBJC_ASSOCIATION_ASSIGN
            case .retainNonatomic:
                return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            case .copyNonatomic:
                return .OBJC_ASSOCIATION_COPY_NONATOMIC
            case .retain:
                return .OBJC_ASSOCIATION_RETAIN
            case .copy:
                return .OBJC_ASSOCIATION_COPY
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
            case .OBJC_ASSOCIATION_ASSIGN:
                self = .assign
            case .OBJC_ASSOCIATION_RETAIN_NONATOMIC:
                self = .retainNonatomic
            case .OBJC_ASSOCIATION_COPY_NONATOMIC:
                self = .copyNonatomic
            case .OBJC_ASSOCIATION_RETAIN:
                self = .retain
            case .OBJC_ASSOCIATION_COPY:
                self = .copy
            @unknown default:
                return nil
        }
    }
}
