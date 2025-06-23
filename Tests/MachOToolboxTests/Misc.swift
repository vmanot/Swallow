import Foundation

func testBinaryURL(for filename: String) -> Foundation.URL? {
    guard let url = Foundation.Bundle.module.url(forResource: filename, withExtension: nil, subdirectory: "TestBinaries") else {
        return nil
    }
    
    return Foundation.URL(filePath: url.path(percentEncoded: false))
}
