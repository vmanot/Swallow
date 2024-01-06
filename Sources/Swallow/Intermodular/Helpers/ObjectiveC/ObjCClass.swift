//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swift

internal struct ObjCClass {
    var value: AnyClass
    
    init(_ value: AnyClass) {
        self.value = value
    }
}

extension ObjCClass {
    var superclass: ObjCClass? {
        return class_getSuperclass(value).map(ObjCClass.init)
    }
    
    func isKind(of other: ObjCClass) -> Bool {
        TODO.here(.fix)
        
        let supercls = class_getSuperclass
        
        if let lhs = value as? NSObject.Type, let rhs = other.value as? NSObject.Type {
            return lhs.isKind(of: rhs)
        }
        
        return false
            || supercls(value) == other.value
            || supercls(supercls(value)) == other.value
            || supercls(supercls(supercls(value))) == other.value
            || supercls(supercls(supercls(supercls(value)))) == other.value
            || supercls(supercls(supercls(supercls(supercls(value))))) == other.value
    }
}

// MARK: - Conformances

extension ObjCClass: CaseIterable {
    @_optimize(speed)
    @_transparent
    static var allCases: [ObjCClass] {
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        var result: [ObjCClass] = Array(repeating: .init(NSObject.self), count: numberOfClasses)
        
        result.withUnsafeMutableBytes {
            do {
                let classes = AutoreleasingUnsafeMutablePointer<AnyClass>(try $0.baseAddress.unwrap().assumingMemoryBound(to: AnyClass.self))
                
                objc_getClassList(classes, Int32(numberOfClasses))
            } catch {
                debugPrint("Could not resolve a master list of all Objective-C classes. Critical runtime failure.")
            }
        }
        
        return result
    }
}

extension ObjCClass: CustomStringConvertible {
    var description: String {
        String(describing: value)
    }
}

extension ObjCClass: Equatable {
    static func == (lhs: ObjCClass, rhs: ObjCClass) -> Bool {
        lhs.value == rhs.value
    }
}

internal func ~= (lhs: ObjCClass, rhs: ObjCClass) -> Bool {
    lhs.isKind(of: rhs)
}
