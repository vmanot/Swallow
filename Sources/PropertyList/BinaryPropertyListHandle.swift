import _FoundationPrivate

public final class BinaryPropertyListHandle: PropertyListHandle, @unchecked Sendable {
    package static func isBplist(contents: UnsafeRawPointer, mapSize: off_t) -> Bool {
        let bplistXXLen = 8
        guard mapSize >= MemoryLayout<_FoundationPrivate.BPlistTrailer>.size + bplistXXLen + 1 else {
            return false
        }
        
        let string = StaticString(stringLiteral: "bplist0")
        let result = memcmp(contents, string.utf8Start, string.utf8CodeUnitCount)
        
        return result == 0
    }
}
