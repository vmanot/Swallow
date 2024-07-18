//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Foundation.Calendar.Component: Codable, Swift.RawRepresentable {
    public var rawValue: String {
        if let _leapMonthRawValue {
            return _leapMonthRawValue
        }
        
        switch self {
            case .era:
                return "era"
            case .year:
                return "year"
            case .month:
                return "month"
            case .day:
                return "day"
            case .hour:
                return "hour"
            case .minute:
                return "minute"
            case .second:
                return "second"
            case .weekday:
                return "weekday"
            case .weekdayOrdinal:
                return "weekdayOrdinal"
            case .quarter:
                return "quarter"
            case .weekOfMonth:
                return "weekOfMonth"
            case .weekOfYear:
                return "weekOfYear"
            case .yearForWeekOfYear:
                return "yearForWeekOfYear"
            case .nanosecond:
                return "nanosecond"
            case .calendar:
                return "calendar"
            case .timeZone:
                return "timeZone"
            default:
                assertionFailure()
                
                return "unknown"
        }
    }
    
    private var _leapMonthRawValue: String? {
        #if swift(>=5.9)
        if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            if self == .isLeapMonth {
                return "isLeapMonth"
            }
        }
        #endif
        
        return nil
    }
    
    public init?(rawValue: String) {
        switch rawValue {
            case Self.era.rawValue:
                self = .era
            case Self.year.rawValue:
                self = .year
            case Self.month.rawValue:
                self = .month
            case Self.day.rawValue:
                self = .day
            case Self.hour.rawValue:
                self = .hour
            case Self.minute.rawValue:
                self = .minute
            case Self.second.rawValue:
                self = .second
            case Self.weekday.rawValue:
                self = .weekday
            case Self.weekdayOrdinal.rawValue:
                self = .weekdayOrdinal
            case Self.quarter.rawValue:
                self = .quarter
            case Self.weekOfMonth.rawValue:
                self = .weekOfMonth
            case Self.weekOfYear.rawValue:
                self = .weekOfYear
            case Self.yearForWeekOfYear.rawValue:
                self = .yearForWeekOfYear
            case Self.nanosecond.rawValue:
                self = .nanosecond
            case Self.calendar.rawValue:
                self = .calendar
            case Self.timeZone.rawValue:
                self = .timeZone
                
            default:
                return nil
        }
    }
}

extension URLQueryItem: Codable {
    private struct _CodableRepresentation: Codable {
        let name: String
        let value: String?
    }
    
    public init(from decoder: Decoder) throws {
        let codableRepresentation = try decoder.decodeSingleValue(_CodableRepresentation.self)
        
        self.init(name: codableRepresentation.name, value: codableRepresentation.value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(_CodableRepresentation(name: name, value: value))
    }
}
