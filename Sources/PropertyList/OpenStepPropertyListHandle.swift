import Foundation

public final class OpenStepPropertyListHandle: PropertyListHandle, @unchecked Sendable {
    package static func isOpenStep(contents: UnsafeRawPointer, mapSize: off_t) -> Bool {
        let data = Foundation.Data(bytes: contents, count: Int(mapSize))
        let format: PropertyListSerialization.PropertyListFormat? = withUnsafeTemporaryAllocation(of: PropertyListSerialization.PropertyListFormat.self, capacity: 1) { pointer in
            do {
                _ = try PropertyListSerialization.propertyList(from: data, format: pointer.baseAddress)
                return pointer.baseAddress?.pointee
            } catch {
                return nil
            }
        }
        
        return format == .openStep
    }
}
