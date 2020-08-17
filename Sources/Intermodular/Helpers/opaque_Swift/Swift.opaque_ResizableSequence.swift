//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_ResizableSequence: _opaque_DestructivelyMutableSequence, _opaque_ExtensibleSequence, _opaque_SequenceInitiableSequence, Initiable {
    
}

public protocol _opaque_ResizableCollection: _opaque_ExtensibleRangeReplaceableCollection, _opaque_MutableCollection, _opaque_ResizableSequence {
    
}
