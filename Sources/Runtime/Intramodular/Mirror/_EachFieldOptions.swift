//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import _RuntimeKeyPath
import Swift

/// Options for calling `_forEachField(of:options:body:)`.
@available(swift 5.2)
@_spi(Reflection)
public struct _EachFieldOptions: OptionSet {
    public var rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Require the top-level type to be a class.
    public static var classType = _EachFieldOptions(rawValue: 1 << 0)
    /// Ignore fields that can't be introspected.
    public static var ignoreUnknown = _EachFieldOptions(rawValue: 1 << 1)
    /// Ignore fields that contain closures.
    public static var ignoreFunctions = _EachFieldOptions(rawValue: 1 << 2)
}

/// Calls the given closure on every field of the specified type.
///
/// If `body` returns `false` for any field, no additional fields are visited.
///
/// - Parameters:
///   - type: The type to inspect.
///   - options: Options to use when reflecting over `type`.
///   - body: A closure to call with information about each field in `type`.
///     The parameters to `body` are a pointer to a C string holding the name
///     of the field, the offset of the field in bytes, the type of the field,
///     and the `_MetadataKind` of the field's type.
/// - Returns: `true` if every invocation of `body` returns `true`; otherwise,
///   `false`.
@available(swift 5.2)
@discardableResult
@_spi(Reflection)
public func _forEachField(
    of type: Any.Type,
    options: _EachFieldOptions = [],
    body: (UnsafePointer<CChar>, Int, Any.Type, TypeMetadata.Kind) -> Bool
) -> Bool {
    // Require class type iff `.classType` is included as an option
    if _swift_isClassType(type) != options.contains(.classType) {
        return false
    }
    
    let childCount = _swift_reflectionMirror_recursiveCount(type)
    for i in 0..<childCount {
        let offset = _swift_reflectionMirror_recursiveChildOffset(type, index: i)
        
        var field = _SwiftRuntimeTypeFieldReflectionMetadata()
        let childType = _swift_reflectionMirror_recursiveChildMetadata(type, index: i, fieldMetadata: &field)
        defer { field.dealloc?(field.name) }
        let kind = TypeMetadata.Kind(childType)
        
        if !body(field.name!, offset, childType, kind) {
            return false
        }
    }
    
    return true
}

/// Calls the given closure on every field of the specified type.
///
/// If `body` returns `false` for any field, no additional fields are visited.
///
/// - Parameters:
///   - type: The type to inspect.
///   - options: Options to use when reflecting over `type`.
///   - body: A closure to call with information about each field in `type`.
///     The parameters to `body` are a pointer to a C string holding the name
///     of the field and an erased keypath for it.
/// - Returns: `true` if every invocation of `body` returns `true`; otherwise,
///   `false`.
@available(swift 5.4)
@discardableResult
@_spi(Reflection)
public func _forEachFieldWithKeyPath<Root>(
    of type: Root.Type,
    options: _EachFieldOptions = [],
    body: (String, PartialKeyPath<Root>) -> Bool
) -> Bool {
    // Class types not supported because the metadata does not have
    // enough information to construct computed properties.
    if _swift_isClassType(type) != options.contains(.classType) {
        return false
    }
    
    let ignoreUnknown = options.contains(.ignoreUnknown)
    let ignoreFunctions = options.contains(.ignoreFunctions)

    let childCount = _swift_reflectionMirror_recursiveCount(type)
    for i in 0..<childCount {
        let offset = _swift_reflectionMirror_recursiveChildOffset(type, index: i)
        
        var field = _SwiftRuntimeTypeFieldReflectionMetadata()
        let childType = _swift_reflectionMirror_recursiveChildMetadata(type, index: i, fieldMetadata: &field)
        
        guard field.name != nil else {
            assertionFailure()
            
            continue
        }

        defer {
            field.dealloc?(field.name)
        }
        
        let kind = TypeMetadata.Kind(childType)
        let supportedType: Bool
        
        switch kind {
            case .struct, .class, .optional, .existential, .existentialMetatype, .tuple, .enum:
                supportedType = true
            default:
                supportedType = false
        }
        
        if !supportedType || !field.isStrong {
            if kind == .function && ignoreFunctions {
                continue
            }
            
            if !ignoreUnknown {
                return false
            }
            
            continue
        }
        
        func keyPathType<Leaf>(for: Leaf.Type) -> PartialKeyPath<Root>.Type {
            if field.isVar { return WritableKeyPath<Root, Leaf>.self }
            return KeyPath<Root, Leaf>.self
        }
        
        let resultSize = MemoryLayout<Int32>.size + MemoryLayout<Int>.size
        let partialKeyPathExistential = _openExistential(childType, do: keyPathType)
        let partialKeyPath = partialKeyPathExistential._create(capacityInBytes: resultSize) {
            var destBuilder = KeyPathBuffer.Builder($0)
            destBuilder.pushHeader(KeyPathBuffer.Header(
                size: resultSize - MemoryLayout<Int>.size,
                trivial: true,
                hasReferencePrefix: false
            ))
            
            let component = RawKeyPathComponent(
                header: RawKeyPathComponent.Header(
                    stored: .struct,
                    mutable: field.isVar,
                    inlineOffset: UInt32(offset)
                ),
                body: UnsafeRawBufferPointer(start: nil, count: 0)
            )
            
            component.clone(
                into: &destBuilder.buffer,
                endOfReferencePrefix: false
            )
        }
        
        let fieldName: String = String(cString: field.name!)
        
        if !body(fieldName, partialKeyPath) {
            return false
        }
    }
    
    return true
}
