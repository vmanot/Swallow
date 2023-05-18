//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A person's gender.
public enum PersonGender: String, Codable {
    case male
    case female
    case other
    
    public var title: String {
        switch self {
            case .male:
                return "Male"
            case .female:
                return "Female"
            case .other:
                return "Other"
        }
    }
}
