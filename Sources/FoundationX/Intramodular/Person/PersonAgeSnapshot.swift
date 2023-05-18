//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift


public struct PersonAgeSnapshot: CustomStringConvertible, Hashable {
    public let value: Int
    
    public var description: String {
        "\(value) year\(value == 1 ? "" : "s")"
    }
    
    public init(
        from birthdate: Date,
        relativeTo currentData: Date = Date(),
        in calendar: Calendar
    ) throws {
        let dateComponents = calendar.dateComponents([.year], from: birthdate, to: currentData)
        
        self.value = try dateComponents.year.unwrap()
    }
}
