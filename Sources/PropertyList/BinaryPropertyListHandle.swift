import _FoundationCShims

public final class BinaryPropertyListHandle: PropertyListHandle, @unchecked Sendable {
    static func isBplist(contents: UnsafeRawPointer, mapSize: off_t) -> Bool {
        let bplistXXLen = 8
        guard mapSize >= MemoryLayout<_FoundationCShims.BPlistTrailer>.size + bplistXXLen + 1 else {
            return false
        }
        
        // TODO: swift-foundation/Sources/FoundationEssentials/PropertyList/BPlistScanner.swift
        return true
    }
}
