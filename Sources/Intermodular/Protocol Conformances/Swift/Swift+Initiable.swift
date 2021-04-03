//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnyCollection: Initiable {
    public init() {
        self.init([])
    }
}

extension AnyBidirectionalCollection: Initiable {
    public init() {
        self.init([])
    }
}

extension AnyRandomAccessCollection: Initiable {
    public init() {
        self.init([])
    }
}

extension AnySequence: Initiable {
    public init() {
        self.init(EmptyCollection.Iterator())
    }
}

extension Array: Initiable {
    
}

extension ArraySlice: Initiable {
    
}

extension ContiguousArray: Initiable {
    
}

extension Dictionary: Initiable {
    
}

extension EmptyCollection: Initiable {
    
}

extension EmptyCollection.Iterator: Initiable {
    
}

extension KeyValuePairs: Initiable {
    public init() {
        self = [:]
    }
}

extension Set: Initiable {
    
}

extension String: Initiable {
    
}

extension UTF8: Initiable {
    
}

extension UTF16: Initiable {
    
}

extension UTF32: Initiable {
    
}
