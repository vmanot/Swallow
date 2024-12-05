//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Calendar.Date {
    public struct DateFormat: RawRepresentable {
        public let rawValue: String
        
        // Initializers required by RawRepresentable
        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension Calendar.Date.DateFormat {
    // Prioritize ISO 8601
    public static let iso8601 = Self("yyyy-MM-dd")              // Standard ISO 8601 format
    public static let iso8601Compact = Self("yyyyMMdd")         // Compact ISO 8601
    
    // Common US formats (Month-Day-Year)
    public static let usNumeric = Self("MM/dd/yyyy")            // Example: 12/05/2024
    public static let usWritten = Self("MMMM d, yyyy")          // Example: December 5, 2024
    
    // Common European formats (Day-Month-Year)
    public static let europeanNumeric = Self("dd/MM/yyyy")      // Example: 05/12/2024
    public static let europeanWritten = Self("d MMMM yyyy")     // Example: 5 December 2024
    
    // Unix Timestamps
    public static let unixEpoch = Self("yyyy-MM-dd'T'HH:mm:ssZ") // Example: 2024-12-05T14:23:00Z
    
    // Compact formats
    public static let compact = Self("yyyyMMdd")                // Example: 20241205
    public static let shortYearCompact = Self("yyMMdd")         // Example: 241205
    
    // Abbreviated month
    public static let abbreviatedMonth = Self("dd-MMM-yyyy")    // Example: 05-Dec-2024
}
