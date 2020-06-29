//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_ResizableSequence: opaque_DestructivelyMutableSequence, opaque_ExtensibleSequence, opaque_SequenceInitiableSequence, Initiable {
    
}

public protocol opaque_ResizableCollection: opaque_ExtensibleRangeReplaceableCollection, opaque_MutableCollection, opaque_ResizableSequence {
    
}
