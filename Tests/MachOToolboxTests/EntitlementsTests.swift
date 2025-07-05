import Testing
import Foundation
@testable import MachOToolbox

struct EntitlementsTests {
    @Test("Get Entitlements", arguments: ["Entitlements"])
    func test_init(filename: String) throws {
        let url = try #require(testBinaryURL(for: filename))
        let handle = try MachOHandle(url: url)
        let data = handle.header.pointee.entitlements
        let unwrapped = try #require(data)
        let string = String(data: unwrapped, encoding: .utf8)
        let expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>application-identifier</key>\n\t<string>P53D29U9LJ.com.pookjw.MyApp</string>\n\t<key>com.apple.developer.team-identifier</key>\n\t<string>P53D29U9LJ</string>\n\t<key>com.apple.security.application-groups</key>\n\t<array>\n\t\t<string>group.com.pookjw.notegorund</string>\n\t</array>\n\t<key>get-task-allow</key>\n\t<true/>\n</dict>\n</plist>\n"
        #expect(string == expected)
    }
}
