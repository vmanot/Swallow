import Foundation

public final class XMLPropertyListHandle: PropertyListHandle, @unchecked Sendable {
    package static func isXML(contents: UnsafeRawPointer, mapSize: off_t) -> Bool {
        let data = Foundation.Data(bytes: contents, count: Int(mapSize))
        return Foundation.XMLParser(data: data).parse()
    }
}
