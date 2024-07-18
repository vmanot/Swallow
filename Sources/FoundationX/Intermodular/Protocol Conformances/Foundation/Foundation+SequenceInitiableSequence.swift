//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Data: Swallow.SequenceInitiableSequence {
    
}

extension NSString {
    public convenience init<S: Sequence>(_ source: S) where S.Element == Element {
        self.init(.init(source))
    }
}
