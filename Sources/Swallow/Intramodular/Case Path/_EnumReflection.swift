//
// This file contains code originally derived from swift-case-paths
// https://github.com/pointfreeco/swift-case-paths/blob/main/LICENSE
//
// Partially rewritten and reimplemented for performance and functionality reasons
// where direct dependency was not feasible.
//
// Copyright (c) 2020 Point-Free, Inc.
// Copyright (c) 2025 Vatsal Manot
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Swift

extension CasePath {
    /// Returns a case path for the given embed function.
    ///
    /// - Note: This operator is only intended to be used with enum cases that have no associated
    ///   values. Its behavior is otherwise undefined.
    /// - Parameter embed: An embed function.
    /// - Returns: A case path.
    public init(_ embed: @escaping (Value) -> Root) {
        func open<Wrapped>(_: Wrapped.Type) -> (Root) -> Value? {
            _EnumReflection.optionalPromotedExtractHelp(unsafeBitCast(embed, to: ((Value) -> Wrapped?).self))
            as! (Root) -> Value?
        }
        let extract =
        ((_Witness<Root>.self as? _AnyOptional.Type)?.wrappedType)
            .map { _openExistential($0, do: open) }
        ?? _EnumReflection.extractHelp(embed)
        
        self.init(
            embed: embed,
            extract: extract
        )
    }
}

extension CasePath where Value == Void {
    /// Returns a void case path for a case with no associated value.
    ///
    /// - Note: This operator is only intended to be used with enum cases that have no associated
    ///   values. Its behavior is otherwise undefined.
    /// - Parameter root: A case with no an associated value.
    /// - Returns: A void case path.
    public init(_ root: Root) {
        func open<Wrapped>(_: Wrapped.Type) -> (Root) -> Void? {
            _EnumReflection.optionalPromotedExtractVoidHelp(unsafeBitCast(root, to: Wrapped?.self)) as! (Root) -> Void?
        }
        let extract =
        ((_Witness<Root>.self as? _AnyOptional.Type)?.wrappedType)
            .map { _openExistential($0, do: open) }
        ?? _EnumReflection.extractVoidHelp(root)
        self.init(embed: { root }, extract: extract)
    }
}

extension CasePath where Root == Value {
    /// Returns the identity case path for the given type. Enables `CasePath(MyType.self)` syntax.
    ///
    /// - Parameter type: A type for which to return the identity case path.
    /// - Returns: An identity case path.
    public init(_ type: Root.Type) {
        self = .self
    }
}

public enum _EnumReflection {
    static func extractHelp<Root, Value>(
        _ embed: @escaping (Value) -> Root
    ) -> (Root) -> Value? {
        guard
            let metadata = EnumMetadata(Root.self),
            metadata.typeDescriptor.fieldDescriptor != nil
        else {
            assertionFailure("embed parameter must be a valid enum case initializer")
            return { _ in nil }
        }
        
        var cachedTag: UInt32?
        var cachedStrategy: (isIndirect: Bool, associatedValueType: Any.Type)?
        
        return { root in
            let rootTag = metadata.tag(of: root)
            
            if let cachedTag = cachedTag, let (isIndirect, associatedValueType) = cachedStrategy {
                guard rootTag == cachedTag else {
                    return nil
                }
                
                return EnumMetadata
                    ._project(root, isIndirect: isIndirect, associatedValueType: associatedValueType)?
                    .value as? Value
            }
            
            guard
                let (value, isIndirect, type) = EnumMetadata._project(root),
                let value = value as? Value
            else { return nil }
            
            let embedTag = metadata.tag(of: embed(value))
            cachedTag = embedTag
            if embedTag == rootTag {
                cachedStrategy = (isIndirect, type)
                return value
            } else {
                return nil
            }
        }
    }
    
    static func optionalPromotedExtractHelp<Root, Value>(
        _ embed: @escaping (Value) -> Root?
    ) -> (Root?) -> Value? {
        guard Root.self != Value.self else { return { $0 as! Value? } }
        guard
            let metadata = EnumMetadata(Root.self),
            metadata.typeDescriptor.fieldDescriptor != nil
        else {
            assertionFailure("embed parameter must be a valid enum case initializer")
            return { _ in nil }
        }
        
        var cachedTag: UInt32?
        
        return { optionalRoot in
            guard let root = optionalRoot else { return nil }
            
            let rootTag = metadata.tag(of: root)
            
            if let cachedTag = cachedTag {
                guard rootTag == cachedTag else { return nil }
            }
            
            guard let value = EnumMetadata.project(root) as? Value
            else { return nil }
            
            guard let embedded = embed(value) else { return nil }
            let embedTag = metadata.tag(of: embedded)
            cachedTag = embedTag
            return embedTag == rootTag ? value : nil
        }
    }
    
    static func extractVoidHelp<Root>(
        _ root: Root
    ) -> (Root) -> Void? {
        guard
            let metadata = EnumMetadata(Root.self),
            metadata.typeDescriptor.fieldDescriptor != nil
        else {
            assertionFailure("value must be a valid enum case")
            return { _ in nil }
        }
        
        let cachedTag = metadata.tag(of: root)
        return { root in metadata.tag(of: root) == cachedTag ? () : nil }
    }
    
    static func optionalPromotedExtractVoidHelp<Root>(
        _ root: Root?
    ) -> (Root?) -> Void? {
        guard
            let root = root,
            let metadata = EnumMetadata(Root.self),
            metadata.typeDescriptor.fieldDescriptor != nil
        else {
            assertionFailure("value must be a valid enum case")
            return { _ in nil }
        }
        
        let cachedTag = metadata.tag(of: root)
        return { root in root.flatMap(metadata.tag(of:)) == cachedTag ? () : nil }
    }
}

private protocol Metadata {
    var ptr: UnsafeRawPointer { get }
}

extension Metadata {
    var valueWitnessTable: ValueWitnessTable {
        ValueWitnessTable(
            ptr: self.ptr.load(fromByteOffset: -pointerSize, as: UnsafeRawPointer.self)
        )
    }
    
    var kind: MetadataKind { self.ptr.load(as: MetadataKind.self) }
}

private struct MetadataKind: Equatable {
    var rawValue: UInt
    
    // https://github.com/apple/swift/blob/main/include/swift/ABI/MetadataValues.h
    // https://github.com/apple/swift/blob/main/include/swift/ABI/MetadataKind.def
    static var enumeration: Self { .init(rawValue: 0x201) }
    static var optional: Self { .init(rawValue: 0x202) }
    static var tuple: Self { .init(rawValue: 0x301) }
    static var existential: Self { .init(rawValue: 0x303) }
}

@_spi(Reflection) public struct EnumMetadata: Metadata {
    let ptr: UnsafeRawPointer
    
    fileprivate init(assumingEnum type: Any.Type) {
        self.ptr = unsafeBitCast(type, to: UnsafeRawPointer.self)
    }
    
    @_spi(Reflection) public init?(_ type: Any.Type) {
        self.init(assumingEnum: type)
        guard self.kind == .enumeration || self.kind == .optional else { return nil }
    }
    
    fileprivate var genericArguments: GenericArgumentVector? {
        guard typeDescriptor.flags.contains(.isGeneric) else { return nil }
        return .init(ptr: self.ptr.advanced(by: 2 * pointerSize))
    }
    
    @_spi(Reflection) public var typeDescriptor: EnumTypeDescriptor {
        EnumTypeDescriptor(
            ptr: self.ptr.load(fromByteOffset: pointerSize, as: UnsafeRawPointer.self)
        )
    }
    
    @_spi(Reflection) public func tag<Enum>(of value: Enum) -> UInt32 {
        // NB: Workaround for https://github.com/apple/swift/issues/61708
        guard self.typeDescriptor.emptyCaseCount + self.typeDescriptor.payloadCaseCount > 1
        else { return 0 }
        return withUnsafePointer(to: value) {
            self.valueWitnessTable.getEnumTag($0, self.ptr)
        }
    }
}

extension EnumMetadata {
    @_spi(Reflection) public func associatedValueType(forTag tag: UInt32) -> Any.Type {
        guard
            let typeName = self.typeDescriptor.fieldDescriptor?.field(atIndex: tag).typeName,
            let type = _swift_getTypeByMangledNameInContext(
                unsafeBitCast(typeName.ptr),
                .init(typeName.length),
                genericContext: self.typeDescriptor.ptr,
                genericArguments: self.genericArguments?.ptr
            )
        else {
            return Void.self
        }
        
        return type
    }
    
    @_spi(Reflection) public func caseName(forTag tag: UInt32) -> String? {
        self.typeDescriptor.fieldDescriptor?.field(atIndex: tag).name
    }
}

extension EnumMetadata {
    func destructivelyProjectPayload(of value: UnsafeMutableRawPointer) {
        self.valueWitnessTable.destructiveProjectEnumData(value, ptr)
    }
    
    func destructivelyInjectTag(_ tag: UInt32, intoPayload payload: UnsafeMutableRawPointer) {
        self.valueWitnessTable.destructiveInjectEnumData(payload, tag, ptr)
    }
    
    @_spi(Reflection) public static func project<Enum>(_ root: Enum) -> Any? {
        Self._project(root)?.value
    }
    
    fileprivate static func _project<Enum>(
        _ root: Enum,
        isIndirect: Bool? = nil,
        associatedValueType: Any.Type? = nil
    ) -> (value: Any, isIndirect: Bool, associatedValueType: Any.Type)? {
        guard let metadata = Self(Enum.self)
        else { return nil }
        
        let tag = metadata.tag(of: root)
        guard
            let isIndirect = isIndirect
                ?? metadata
                .typeDescriptor
                .fieldDescriptor?
                .field(atIndex: tag)
                .flags
                .contains(.isIndirectCase)
        else { return nil }
        
        var root = root
        return withUnsafeMutableBytes(of: &root) { rawBuffer in
            guard let pointer = rawBuffer.baseAddress
            else { return nil }
            metadata.destructivelyProjectPayload(of: pointer)
            defer { metadata.destructivelyInjectTag(tag, intoPayload: pointer) }
            func open<T>(_ type: T.Type) -> T {
                isIndirect
                ? pointer
                    .load(as: UnsafeRawPointer.self)  // Load the heap object pointer.
                    .advanced(by: 2 * pointerSize)  // Skip the heap object header.
                    .load(as: type)
                : pointer.load(as: type)
            }
            let type: Any.Type
            if let associatedValueType = associatedValueType {
                type = associatedValueType
            } else {
                var associatedValueType = metadata.associatedValueType(forTag: tag)
                if let tupleMetadata = TupleMetadata(associatedValueType), tupleMetadata.elementCount == 1 {
                    associatedValueType = tupleMetadata.element(at: 0).type
                }
                type = associatedValueType
            }
            let value: Any = _openExistential(type, do: open)
            return (value: value, isIndirect: isIndirect, associatedValueType: type)
        }
    }
}

@_spi(Reflection) public struct EnumTypeDescriptor: Equatable {
    let ptr: UnsafeRawPointer
    
    var flags: Flags { Flags(rawValue: self.ptr.load(as: UInt32.self)) }
    
    fileprivate var fieldDescriptor: FieldDescriptor? {
        self.ptr
            .advanced(by: 4 * 4)
            .loadRelativePointer()
            .map(FieldDescriptor.init)
    }
    
    var payloadCaseCount: UInt32 { self.ptr.load(fromByteOffset: 5 * 4, as: UInt32.self) & 0xFFFFFF }
    
    var emptyCaseCount: UInt32 { self.ptr.load(fromByteOffset: 6 * 4, as: UInt32.self) }
}

extension EnumTypeDescriptor {
    struct Flags: OptionSet {
        let rawValue: UInt32
        
        static var isGeneric: Self { .init(rawValue: 0x80) }
    }
}

private struct TupleMetadata: Metadata {
    let ptr: UnsafeRawPointer
    
    init?(_ type: Any.Type) {
        self.ptr = unsafeBitCast(type, to: UnsafeRawPointer.self)
        guard self.kind == .tuple else { return nil }
    }
    
    var elementCount: UInt {
        self.ptr
            .advanced(by: pointerSize)  // kind
            .load(as: UInt.self)
    }
    
    var labels: UnsafePointer<UInt8>? {
        self.ptr
            .advanced(by: pointerSize)  // kind
            .advanced(by: pointerSize)  // elementCount
            .load(as: UnsafePointer<UInt8>?.self)
    }
    
    func element(at i: Int) -> Element {
        Element(
            ptr:
                self.ptr
                .advanced(by: pointerSize)  // kind
                .advanced(by: pointerSize)  // elementCount
                .advanced(by: pointerSize)  // labels pointer
                .advanced(by: i * 2 * pointerSize)
        )
    }
}

extension TupleMetadata {
    struct Element: Equatable {
        let ptr: UnsafeRawPointer
        
        var type: Any.Type { self.ptr.load(as: Any.Type.self) }
        
        var offset: UInt32 { self.ptr.load(fromByteOffset: pointerSize, as: UInt32.self) }
        
        static func == (lhs: Element, rhs: Element) -> Bool {
            lhs.type == rhs.type && lhs.offset == rhs.offset
        }
    }
}

extension TupleMetadata {
    func hasSameLayout(as other: TupleMetadata) -> Bool {
        self.elementCount == other.elementCount
        && (0..<Int(self.elementCount)).allSatisfy { self.element(at: $0) == other.element(at: $0) }
    }
}

private struct ExistentialMetadata: Metadata {
    let ptr: UnsafeRawPointer
    
    init?(_ type: Any.Type?) {
        self.ptr = unsafeBitCast(type, to: UnsafeRawPointer.self)
        guard self.kind == .existential else { return nil }
    }
    
    var isClassConstrained: Bool {
        self.ptr.advanced(by: pointerSize).load(as: UInt32.self) & 0x8000_0000 == 0
    }
}

private struct FieldDescriptor {
    let ptr: UnsafeRawPointer
    
    /// The size of a FieldRecord as stored in the executable.
    var recordSize: Int { Int(self.ptr.advanced(by: 2 * 4 + 2).load(as: UInt16.self)) }
    
    func field(atIndex i: UInt32) -> FieldRecord {
        FieldRecord(
            ptr: self.ptr.advanced(by: 2 * 4 + 2 * 2 + 4).advanced(by: Int(i) * recordSize)
        )
    }
}

private struct FieldRecord {
    let ptr: UnsafeRawPointer
    
    var flags: Flags { Flags(rawValue: self.ptr.load(as: UInt32.self)) }
    
    var typeName: MangledTypeName? {
        self.ptr
            .advanced(by: 4)
            .loadRelativePointer()
            .map { MangledTypeName(ptr: $0.assumingMemoryBound(to: UInt8.self)) }
    }
    
    var name: String? {
        self.ptr
            .advanced(by: 4)
            .advanced(by: 4)
            .loadRelativePointer()
            .map { String(cString: $0.assumingMemoryBound(to: CChar.self)) }
    }
}

extension FieldRecord {
    struct Flags: OptionSet {
        var rawValue: UInt32
        
        static var isIndirectCase: Self { .init(rawValue: 1) }
    }
}

private struct MangledTypeName {
    let ptr: UnsafePointer<UInt8>
    
    var length: UInt {
        // https://github.com/apple/swift/blob/main/docs/ABI/Mangling.rst
        var ptr = self.ptr
        while true {
            switch ptr.pointee {
                case 0:
                    return UInt(bitPattern: ptr - self.ptr)
                case 0x01...0x17:
                    // Relative symbolic reference
                    ptr = ptr.advanced(by: 5)
                case 0x18...0x1f:
                    // Absolute symbolic reference
                    ptr = ptr.advanced(by: 1 + pointerSize)
                default:
                    ptr = ptr.advanced(by: 1)
            }
        }
    }
}

private struct ValueWitnessTable {
    let ptr: UnsafeRawPointer
    
    var getEnumTag: @convention(c) (_ value: UnsafeRawPointer, _ metadata: UnsafeRawPointer) -> UInt32
    {
        self.ptr.advanced(by: 10 * pointerSize + 2 * 4).loadInferredType()
    }
    
    // This witness transforms an enum value into its associated value, in place.
    var destructiveProjectEnumData:
    @convention(c) (_ value: UnsafeMutableRawPointer, _ metadata: UnsafeRawPointer) -> Void
    {
        self.ptr.advanced(by: 11 * pointerSize + 2 * 4).loadInferredType()
    }
    
    // This witness transforms an associated value into its enum value, in place.
    var destructiveInjectEnumData:
    @convention(c) (_ value: UnsafeMutableRawPointer, _ tag: UInt32, _ metadata: UnsafeRawPointer)
    -> Void
    {
        self.ptr.advanced(by: 12 * pointerSize + 2 * 4).loadInferredType()
    }
}

private struct GenericArgumentVector {
    let ptr: UnsafeRawPointer
}

extension GenericArgumentVector {
    func type(atIndex i: Int) -> Any.Type {
        return ptr.load(fromByteOffset: i * pointerSize, as: Any.Type.self)
    }
}

extension UnsafeRawPointer {
    fileprivate func loadInferredType<Type>() -> Type {
        self.load(as: Type.self)
    }
    
    fileprivate func loadRelativePointer() -> UnsafeRawPointer? {
        let offset = Int(load(as: Int32.self))
        return offset == 0 ? nil : self + offset
    }
}

// This is the size of any Unsafe*Pointer and also the size of Int and UInt.
private let pointerSize = MemoryLayout<UnsafeRawPointer>.size

private protocol _Optional {
    associatedtype Wrapped
}
extension Optional: _Optional {}
private enum _Witness<A> {}
private protocol _AnyOptional {
    static var wrappedType: Any.Type { get }
}
extension _Witness: _AnyOptional where A: _Optional {
    static var wrappedType: Any.Type {
        A.Wrapped.self
    }
}
