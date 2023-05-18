//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Date {
    public init(
        from string: String,
        format: String,
        in calendar: Calendar = .current
    ) throws {
        let formatter = DateFormatter()
        
        formatter.calendar = calendar
        formatter.dateFormat = format
        
        self = try formatter.date(from: string).unwrap()
    }
    
    /// Convert this date to a `String` given a certain format.
    public func toString(dateFormat format: String) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    /// Convert this date to a `String` given a certain format.
    public func toString(
        dateStyle: DateFormatter.Style,
        timeStyle: DateFormatter.Style
    ) -> String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        
        return formatter.string(from: self)
    }
}

extension Date {
    /// Returns all the date components of a date.
    public func components(calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(in: .current, from: self)
    }
    
    public func get(
        _ components: Calendar.Component...,
        calendar: Calendar = Calendar.current
    ) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    public func get(
        _ component: Calendar.Component,
        calendar: Calendar = Calendar.current
    ) -> Int {
        return calendar.component(component, from: self)
    }
    
    public func get(
        _ component: Calendar.Component,
        to other: Date,
        calendar: Calendar = Calendar.current
    ) throws -> Int {
        return try calendar.dateComponents([component], from: self, to: other).value(for: component).unwrap()
    }
    
    /// Number of days (relative to this date) to a given date.
    public func days(to other: Date, in calendar: Calendar = .current) throws -> Int {
        try get(.day, to: other)
    }
}

extension Date {
    private enum DateCalculationFailed: Error {
        case adding(Calendar.Component, value: Int, to: Date)
    }
    
    public func adding(_ component: Calendar.Component, value: Int) throws -> Date {
        do {
            return try Calendar.current.date(byAdding: component, value: value, to: self).unwrap()
        } catch {
            throw DateCalculationFailed.adding(component, value: value, to: self)
        }
    }
    
    public func adding(days value: Int) throws -> Date {
        return try adding(.day, value: value)
    }
    
    public func adding(weeks value: Int) throws -> Date {
        return try adding(.weekOfMonth, value: value)
    }
}

extension Date {
    public var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    public var endOfDay: Date {
        var components = DateComponents()
        
        components.day = 1
        components.second = -1
        
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    public var startOfMonth: Date {
        Calendar.current.date(from: startOfDay.get(.year, .month))!
    }
    
    public var endOfMonth: Date {
        var components = DateComponents()
        
        components.month = 1
        components.second = -1
        
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}

extension Date {
    public var yearsToNow: Int {
        (try? get(.year, to: Date())) ?? 0
    }
    
    public var monthsToNow: Int {
        (try? get(.month, to: Date())) ?? 0
    }
    
    public var weeksToNow: Int {
        (try? get(.weekOfYear, to: Date())) ?? 0
    }
    
    public var daysToNow: Int {
        (try? get(.day, to: Date())) ?? 0
    }
    
    public var hoursToNow: Int {
        (try? get(.hour, to: Date())) ?? 0
    }
    
    public var minutesToNow: Int {
        (try? get(.minute, to: Date())) ?? 0
    }
    
    public var secondsToNow: Int {
        (try? get(.second, to: Date())) ?? 0
    }
}

extension Date {
    public var dd_dot_MM_dot_YYYY: String {
        toString(dateFormat: "dd.MM.yyyy")
    }
    
    public var hh_colon_mm_colon_space_a: String {
        toString(dateFormat: "hh:mm a")
    }
    
    public var hh_colon_mm_colon_ss_space_a: String {
        toString(dateFormat: "hh:mm:ss a")
    }
}

extension Date {
    public static func + (lhs: Self, rhs: DispatchTimeInterval) -> Self {
        lhs.addingTimeInterval(TimeInterval(from: rhs))
    }
    
    public static func - (lhs: Self, rhs: DispatchTimeInterval) -> Self {
        lhs.addingTimeInterval(-TimeInterval(from: rhs))
    }
}

// MARK: - Auxiliary

fileprivate extension TimeInterval {
    init(from interval: DispatchTimeInterval) {
        switch interval {
            case let .seconds(s):
                self = .init(s)
            case let .milliseconds(ms):
                self = .init(TimeInterval(ms) / 1000.0)
            case let .microseconds(us):
                self = .init(Int64(us) * Int64(NSEC_PER_USEC)) / TimeInterval(NSEC_PER_SEC)
            case let .nanoseconds(ns):
                self = .init(ns) / TimeInterval(NSEC_PER_SEC)
            case .never:
                fatalError()
            @unknown default:
                fatalError()
        }
    }
}
