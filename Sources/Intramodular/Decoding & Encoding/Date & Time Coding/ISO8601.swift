//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// Decodes `String` values as an ISO8601 `Date`.
///
/// `@ISO8601Date` relies on an `ISO8601DateFormatter` in order to decode `String` values into `Date`s. Encoding the `Date` will encode the value into the original string value.
///
/// For example, decoding json data with a `String` representation  of `"1996-12-19T16:39:57-08:00"` produces a valid `Date` representing 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time).
public struct ISO8601: DateCodingStrategy {
    public static func decode(_ value: String) throws -> Date {
        guard let date = ISO8601DateFormatter().date(from: value) else {
            enum DateError: String, Error {
                case invalidDate
            }
            
            let formatter = DateFormatter()
            
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            
            if let date = formatter.date(from: value) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            
            if let date = formatter.date(from: value) {
                return date
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid date format."))
            }
        }
        
        return date
    }
    
    public static func encode(_ date: Date) throws -> String {
        let formatter = ISO8601DateFormatter()
        
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter.string(from: date)
    }
}
