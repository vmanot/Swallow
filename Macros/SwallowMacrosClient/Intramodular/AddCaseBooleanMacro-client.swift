//
// Copyright (c) Vatsal Manot
//

@_exported import ObjectiveC
import Swift

@attached(member, names: arbitrary)
public macro AddCaseBoolean() = #externalMacro(
    module: "SwallowMacros",
    type: "AddCaseBooleanMacro"
)

// MARK: - Auxiliary

public typealias Policy = objc_AssociationPolicy

public func getAssociatedObject(
    _ object: AnyObject,
    _ key: UnsafeRawPointer
) -> Any? {
    objc_getAssociatedObject(object, key)
}

public func setAssociatedObject(
    _ object: AnyObject,
    _ key: UnsafeRawPointer,
    _ value: Any?,
    _ policy: objc_AssociationPolicy = .retain(.nonatomic)
) {
    objc_setAssociatedObject(
        object,
        key,
        value,
        policy
    )
}
