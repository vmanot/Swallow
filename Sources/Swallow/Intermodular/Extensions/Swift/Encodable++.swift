//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Encodable {
    public func toJSONData(
        prettyPrint: Bool = false
    ) throws -> Data {
        let encoder = prettyPrint ? minifiedJSONEncoder : minifiedJSONEncoder
        
        return try encoder.encode(self, allowFragments: true)
    }
    
    public func toJSONString(
        prettyPrint: Bool = false
    ) -> String? {
        (try? toJSONData(prettyPrint: prettyPrint)).flatMap({ String(data: $0, encoding: .utf8) })
    }
}

private let minifiedJSONEncoder = JSONEncoder()
private let prettyJSONEncoder = build(JSONEncoder()) {
    $0.outputFormatting = .sortedKeys
    $0.outputFormatting = .prettyPrinted
}
