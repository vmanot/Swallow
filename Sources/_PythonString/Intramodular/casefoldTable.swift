//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

func createCasefoldTable() -> [UInt32: String] {
    var table: [UInt32: String] = [:]
    
    for scalarValue in UInt32(0)...UInt32(0x10FFFF) {
        if let scalar = UnicodeScalar(scalarValue) {
            let scalarStr = String(scalar)
            let lowercasedStr = scalarStr.lowercased()
            var finalStr = lowercasedStr
            
            if lowercasedStr == scalarStr {
                let transformedStr = scalarStr
                let mutableString = NSMutableString(string: transformedStr)
                
                // Apply Unicode transformation
                if CFStringTransform(mutableString, nil, kCFStringTransformToUnicodeName, false) {
                    let cfTransformedStr = mutableString as String
                    if cfTransformedStr != scalarStr {
                        finalStr = cfTransformedStr
                    }
                }
            }
            
            if finalStr != scalarStr {
                table[scalar.value] = finalStr
            }
        }
    }
    
    return table
}

let casefoldTable = createCasefoldTable()
