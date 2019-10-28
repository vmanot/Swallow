//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension JoinedSequence {
    public init(base: Base) {
        self.init(base: base, separator: EmptyCollection.Iterator())
    }
}
