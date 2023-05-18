//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension NSPredicate {
    /// A Boolean value indicating whether the predicate always evaluates to `false`.
    public var isAlwaysFalse: Bool {
        predicateFormat == "FALSEPREDICATE"
    }
}
