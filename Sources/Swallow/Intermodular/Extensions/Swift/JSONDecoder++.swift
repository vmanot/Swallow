//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension JSONDecoder {
    private struct FragmentDecodingBox<T: Decodable>: Decodable {
        var value: T
        
        init(from decoder: Decoder) throws {
            let type = decoder.userInfo[.fragmentBoxedType] as! T.Type
            var container = try decoder.unkeyedContainer()
            self.value = try container.decode(type)
        }
    }
    
    public convenience init(
        dateDecodingStrategy: DateDecodingStrategy? = nil,
        dataDecodingStrategy: DataDecodingStrategy? = nil,
        keyDecodingStrategy: KeyDecodingStrategy? = nil,
        nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy? = nil
    ) {
        self.init()
        
        dateDecodingStrategy.map(into: &self.dateDecodingStrategy)
        dataDecodingStrategy.map(into: &self.dataDecodingStrategy)
        keyDecodingStrategy.map(into: &self.keyDecodingStrategy)
        nonConformingFloatDecodingStrategy.map(into: &self.nonConformingFloatDecodingStrategy)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data, allowFragments: Bool) throws -> T {
        guard allowFragments else {
            return try decode(type, from: data)
        }
        
        do {
            return try decode(type, from: data)
        } catch {
            if error.isFragmentDecodingError {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let boxedData = try JSONSerialization.data(withJSONObject: [jsonObject])
                    let decoder = copy()
                    
                    decoder.userInfo[.fragmentBoxedType] = type
                    
                    return try decoder
                        .decode(FragmentDecodingBox<T>.self, from: boxedData)
                        .value
                } catch {
                    throw error
                }
            } else {
                throw error
            }
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
}

extension JSONDecoder.DateDecodingStrategy {
    public static var iso8601X: Self {
        .custom { decoder in
            enum DateError: String, Error {
                case invalidDate
            }
            
            let formatter = DateFormatter()
            
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            throw DateError.invalidDate
        }
    }
}

// MARK: - Auxiliary

fileprivate extension CodingUserInfoKey {
    static let fragmentBoxedType = CodingUserInfoKey(rawValue: "fragmentBoxedType")!
}

fileprivate extension Error {
    var isFragmentDecodingError: Bool {
        guard let error = self as? DecodingError, case let DecodingError.dataCorrupted(context) = error else {
            return false
        }
        
        guard let nsError = (context.underlyingError as NSError?) else {
            return false
        }
        
        return fragile {
            true
                && context.debugDescription == "The given data was not valid JSON."
            && (nsError.debugDescription.contains("option to allow fragments not set") || nsError.debugDescription.contains("after top-level value around"))
        }
    }
}
