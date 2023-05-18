//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Date: CustomStringFormattable {
    public typealias CustomStringFormatter = DateFormatter
}

extension PersonNameComponents: CustomStringFormattable {
    public typealias CustomStringFormatter = PersonNameComponentsFormatter
}
