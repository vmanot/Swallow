import Testing
import Foundation
import Swallow
@testable import MachOToolbox

struct MapOHandleTests {
    @Test("MapHandle.init(url:) (Foundation)", arguments: ["MyScript"])
    func test_initWithFoundationURL(filename: String) throws {
        let feURL: Foundation.URL = try #require(testBinaryURL(for: filename))
        let url = Foundation.URL(fileURLWithPath: feURL.path(percentEncoded: false))
        let handle = try MapHandle(url: url)
        #expect(handle.mapSize > 0)
    }
    
    @Test("MapHandle.init(url:) (FoundationEssentials)", arguments: ["MyScript"])
    func test_initWithFoundationEssentialsURL(filename: String) throws {
        let feURL: Foundation.URL = try #require(testBinaryURL(for: filename))
        let handle = try MapHandle(url: feURL)
        #expect(handle.mapSize > 0)
    }
}
