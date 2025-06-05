import Testing
import FoundationEssentials
@testable import MachOToolbox

public struct MachOHandleTests {
    @Test("MachOHandle.init(url:)", arguments: ["MyScript"])
    func test_init(filename: String) throws {
        let url = try #require(testBinaryURL(for: filename))
        _ = try MachOHandle(url: url)
    }
    
    @Test("MachOHandle.importedSymbols", arguments: ["MyScript"])
    func test_importedSymbols(filename: String) throws {
        let url = try #require(testBinaryURL(for: filename))
        let file = try MachOHandle(url: url)
        #expect(!file.importedSymbols.isEmpty)
    }
    
    @Test("MachOHandle.exportedSymbols", arguments: ["MyScript"])
    func test_exportedSymbols(filename: String) throws {
        let url = try #require(testBinaryURL(for: filename))
        let file = try MachOHandle(url: url)
        #expect(!file.exportedSymbols.isEmpty)
    }
}
