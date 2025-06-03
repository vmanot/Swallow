#if canImport(Foundation)
import Foundation
import FoundationEssentials

func testBinaryURL(for filename: String) -> FoundationEssentials.URL? {
    guard let url = Foundation.Bundle.module.url(forResource: filename, withExtension: nil, subdirectory: "TestBinaries") else {
        return nil
    }
    
    return FoundationEssentials.URL(filePath: url.path(percentEncoded: false))
}

#else
#error("TODO")
#endif
