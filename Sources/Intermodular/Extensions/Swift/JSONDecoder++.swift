//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

fileprivate extension CodingUserInfoKey {
    static let fragmentBoxedType = CodingUserInfoKey(rawValue: "fragmentBoxedType")!
}

extension JSONDecoder {
    private struct FragmentDecodingBox<T: Decodable>: Decodable {
        var value: T
        
        init(from decoder: Decoder) throws {
            let type = decoder.userInfo[.fragmentBoxedType] as! T.Type
            var container = try decoder.unkeyedContainer()
            self.value = try container.decode(type)
        }
    }
    
    private func copy() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        decoder.userInfo = userInfo
        return decoder
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data, allowFragments: Bool) throws -> T {
        guard allowFragments else {
            return try decode(type, from: data)
        }
        
        do {
            return try decode(type, from: data)
        } catch {
            if error.isFragmentDecodeError {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let boxedData = try JSONSerialization.data(withJSONObject: [jsonObject])
                let decoder = copy()
                
                decoder.userInfo[.fragmentBoxedType] = type
                
                return try decoder
                    .decode(FragmentDecodingBox<T>.self, from: boxedData)
                    .value
            } else {
                throw error
            }
        }
    }
}

// MARK: - Helpers -

extension Error {
    fileprivate var isFragmentDecodeError: Bool {
        guard let error = self as? DecodingError, case let DecodingError.dataCorrupted(context) = error else {
            return false
        }
        
        return fragile {
            true
                && context.debugDescription == "The given data was not valid JSON."
                && (context.underlyingError as NSError?)?
                .debugDescription
                .contains("option to allow fragments not set") ?? false
        }
    }
}
