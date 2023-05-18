//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// The granularity of a `Date`.
public enum DateGranularity: String, CaseIterable, Codable, Hashable {
    case era
    case year
    case month
    case day
    case hour
    case minute
    case second
    case nanosecond
}
