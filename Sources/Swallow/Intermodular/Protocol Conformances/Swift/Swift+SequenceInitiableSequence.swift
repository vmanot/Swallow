//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnySequence: SequenceInitiableSequence {
    
}

extension Array: SequenceInitiableSequence {
    
}

extension ArraySlice: SequenceInitiableSequence {
    
}

extension ContiguousArray: SequenceInitiableSequence {
    
}

extension Dictionary: SequenceInitiableSequence {
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init()
        
        append(contentsOf: sequence)
    }
}

extension KeyValuePairs: SequenceInitiableSequence {
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self = (unsafeBitCast(KeyValuePairs.init(dictionaryLiteral:)) as ((Array) -> KeyValuePairs))(Array(sequence))
    }
}

extension Set: SequenceInitiableSequence {
    
}

extension String: SequenceInitiableSequence {
    
}

extension String.UnicodeScalarView: SequenceInitiableSequence {
    
}

extension Substring: SequenceInitiableSequence {
    
}
