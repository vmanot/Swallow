import Testing
import FoundationEssentials
@testable import MachOToolbox

public struct FatHandleTests {
    @Test("FatHandle.init(url:)", arguments: ["Symbols"])
    func test_init(filename: String) throws {
        let url = try #require(testBinaryURL(for: filename))
        _ = try FatHandle(url: url)
    }
    
    @Test("FatHandle.importedSymbols(for:)", arguments: ["Symbols"])
    func test_importedSymbols(filename: String) throws {
        let url = try #require(testBinaryURL(for: filename))
        let handle = try FatHandle(url: url)
        let symbolds = try #require(handle.importedSymbols(for: .arm64))
        #expect(!symbolds.isEmpty)
    }
    
    @Test("FatHandle.exportedSymbols(for:)", arguments: ["Symbols"])
    func test_exportedSymbols(filename: String) throws {
        let url = try #require(testBinaryURL(for: filename))
        let handle = try FatHandle(url: url)
        let symbolds = try #require(handle.exportedSymbols(for: .arm64))
        #expect(!symbolds.isEmpty)
    }
}
