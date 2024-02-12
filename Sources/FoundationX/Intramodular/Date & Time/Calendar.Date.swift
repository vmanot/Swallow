//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Calendar {
    /// A type that represents a calendar date.
    public struct Date: Codable, Comparable, Hashable {
        public let year: Int
        public let month: Int
        public let day: Int
        
        public init(year: Int, month: Int, day: Int) {
            self.year = year
            self.month = month
            self.day = day
        }
        
        public init(from date: Foundation.Date, in calendar: Calendar = .current) {
            self.year = calendar.component(.year, from: date)
            self.month = calendar.component(.month, from: date)
            self.day = calendar.component(.day, from: date)
        }
        
        public init() {
            self.init(from: .init())
        }
        
        public static func < (lhs: Date, rhs: Date) -> Bool {
            if lhs.year < rhs.year {
                return true
            } else if lhs.year > rhs.year {
                return false
            }
            
            if lhs.month < rhs.month {
                return true
            } else if lhs.month > rhs.month {
                return false
            }
            
            if lhs.day < rhs.day {
                return true
            } else if lhs.day > rhs.day {
                return false
            }
            
            return false
        }
    }
}

// MARK: - Conformances

extension Calendar.Date: CustomStringConvertible {
    public var description: String {
        DateFormatter(dateFormat: "yyyy-MM-dd").string(from: Date(from: self))
    }
}

extension Calendar.Date: LosslessStringConvertible {
    public init?(_ description: String) {
        if let date = DateFormatter(dateFormat: "yyyy-MM-dd").date(from: description) {
            self.init(from: date)
        } else {
            return nil
        }
    }
}

// MARK: - Auxiliary

extension Date {
    public init(
        from date: Calendar.Date,
        in calendar: Calendar = .current
    ) {
        self = DateComponents(from: date, in: calendar).date!
    }
}

extension DateComponents {
    public init(
        from date: Calendar.Date,
        in calendar: Calendar = .current
    ) {
        self.init(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: date.year,
            month: date.month,
            day: date.day
        )
    }
}

// MARK: - SwiftUI -

#if canImport(SwiftUI)
import SwiftUI
#if swift(<5.9)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension DatePicker {
    public init(
        selection: Binding<Calendar.Date>,
        in calendar: Calendar = .current,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            displayedComponents: [.date],
            label: label
        )
    }
    
    public init(
        selection: Binding<Calendar.Date>,
        across range: ClosedRange<Calendar.Date>,
        in calendar: Calendar = .current,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            in: ClosedRange(
                lowerBound: .init(from: range.lowerBound, in: calendar),
                upperBound: .init(from: range.upperBound, in: calendar)
            ),
            displayedComponents: [.date],
            label: label
        )
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension DatePicker where Label == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            titleKey,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            displayedComponents: [.date]
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            title,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            displayedComponents: [.date]
        )
    }
    
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Calendar.Date>,
        across range: ClosedRange<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            titleKey,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            in: ClosedRange(
                lowerBound: .init(from: range.lowerBound, in: calendar),
                upperBound: .init(from: range.upperBound, in: calendar)
            ),
            displayedComponents: [.date]
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Calendar.Date>,
        across range: ClosedRange<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            title,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            in: ClosedRange(
                lowerBound: .init(from: range.lowerBound, in: calendar),
                upperBound: .init(from: range.upperBound, in: calendar)
            ),
            displayedComponents: [.date]
        )
    }
}

#elseif !os(watchOS)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension DatePicker {
    public init(
        selection: Binding<Calendar.Date>,
        in calendar: Calendar = .current,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            displayedComponents: [.date],
            label: label
        )
    }
    
    public init(
        selection: Binding<Calendar.Date>,
        across range: ClosedRange<Calendar.Date>,
        in calendar: Calendar = .current,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            in: ClosedRange(
                lowerBound: .init(from: range.lowerBound, in: calendar),
                upperBound: .init(from: range.upperBound, in: calendar)
            ),
            displayedComponents: [.date],
            label: label
        )
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension DatePicker where Label == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            titleKey,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            displayedComponents: [.date]
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            title,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            displayedComponents: [.date]
        )
    }
    
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Calendar.Date>,
        across range: ClosedRange<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            titleKey,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            in: ClosedRange(
                lowerBound: .init(from: range.lowerBound, in: calendar),
                upperBound: .init(from: range.upperBound, in: calendar)
            ),
            displayedComponents: [.date]
        )
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Calendar.Date>,
        across range: ClosedRange<Calendar.Date>,
        in calendar: Calendar = .current
    ) {
        self.init(
            title,
            selection: Binding(
                get: { Date(from: selection.wrappedValue, in: calendar) },
                set: { selection.wrappedValue = Calendar.Date(from: $0, in: calendar) }
            ),
            in: ClosedRange(
                lowerBound: .init(from: range.lowerBound, in: calendar),
                upperBound: .init(from: range.upperBound, in: calendar)
            ),
            displayedComponents: [.date]
        )
    }
}
#endif
#endif
