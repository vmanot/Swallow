import Testing
import FoundationEssentials
@testable @_spi(MachOToolBoxTests) import MachOToolbox

#if canImport(Foundation)
import Foundation
#endif

public struct MapOHandleTests {
#if canImport(Foundation)
    @Test("MapHandle.init(url:) (Foundation)", arguments: ["MyScript"])
    func test_initWithFoundationURL(filename: String) throws {
        let feURL: FoundationEssentials.URL = try #require(testBinaryURL(for: filename))
        let url = Foundation.URL(fileURLWithPath: feURL.path(percentEncoded: false))
        let handle = try MapHandle(_url: url)
        #expect(handle.mapSize > 0)
    }
#endif
    
    @Test("MapHandle.init(url:) (FoundationEssentials)", arguments: ["MyScript"])
    func test_initWithFoundationEssentialsURL(filename: String) throws {
        let feURL: FoundationEssentials.URL = try #require(testBinaryURL(for: filename))
        let handle = try MapHandle(_url: feURL)
        #expect(handle.mapSize > 0)
    }
}
