//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// An enumeration for the times of the day.
///
/// https://www.englishclub.com/ref/esl/Power_of_7/7_Times_of_the_Day_2939.php
public enum TimeOfDay: String, Codable {
    case midnight
    case midday
    case morning
    case afternoon
    case evening
    case dawn
    case dusk
}
