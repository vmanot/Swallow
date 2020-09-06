//
// Copyright (c) Vatsal Manot
//

import Swift

extension CustomDebugStringConvertible {
    private func describe(label: String?, value: Any) -> String {
        if let label = label {
            if value is String {
                return "\(label): \"\(value)\""
            }
            
            else {
                return "\(label): \(value)"
            }
        } else {
            return "\(value)"
        }
    }
    
    public var debugDescription: String {
        let mirror = Mirror(reflecting: self)
        
        var children = Array(mirror.children)
        var superclassMirror = mirror.superclassMirror
        
        repeat {
            if let superclassChildren = superclassMirror?.children {
                children += superclassChildren
            }
            
            superclassMirror = superclassMirror?.superclassMirror
        }
        
        while superclassMirror != nil
        
        let components = children.map(describe)
        
        return components.isEmpty ? "\(type(of: self))" : "\(mirror.subjectType)(\(components.joined(separator: ", ")))"
    }
}
