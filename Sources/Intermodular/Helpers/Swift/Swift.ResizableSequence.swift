//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol ResizableSequence: DestructivelyMutableSequence, ExtensibleSequence, SequenceInitiableSequence {
    
}

public protocol ResizableCollection: ExtensibleRangeReplaceableCollection, MutableCollection, ResizableSequence {
    var isEmpty: Bool { get }
}
