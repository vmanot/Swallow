//
//  File.swift
//  Swallow
//
//  Created by Purav Manot on 13/02/25.
//

import Foundation
import Testing

@Suite
class DictionaryProtocolTests {
    @Test
    func testOptionalDictionary() {
        let dict: [String: Int?] = ["one": 1, "nil": nil, "four": 4]
        
        #expect(dict["one"] == 1)
        
        #expect(dict["nil"] != nil)
        #expect(dict["nil"] == Optional<Int>(nil))
        
        #expect(dict.contains(key: "nil"))
        #expect(!dict.contains(key: "infinity"))
    }
}

