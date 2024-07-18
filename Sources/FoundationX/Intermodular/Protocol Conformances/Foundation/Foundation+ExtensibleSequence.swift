//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Data: Swallow.ExtensibleSequence {
    public typealias ElementInsertResult = Void
    public typealias ElementsInsertResult = Void
    public typealias ElementAppendResult = Void
    public typealias ElementsAppendResult = Void
    
    public mutating func insert(_ newElement: Element) {
        insert(contentsOf: CollectionOfOne(newElement))
    }
    
    public mutating func insert<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        let newElements = Array(newElements)
        
        replaceSubrange(0..<0, with: newElements)
    }
    
    public mutating func append(_ newElement: Element) {
        append(contentsOf: newElement.bytes)
    }
}

extension NSMutableArray: Swallow.ExtensibleSequence {
    public typealias ElementInsertResult = Void
    public typealias ElementsInsertResult = Void
    public typealias ElementAppendResult = Void
    public typealias ElementsAppendResult = Void
    
    @objc public dynamic func insert(_ newElement: Element) {
        insert(newElement, at: 0)
    }
    
    @objc public dynamic func append(_ newElement: Element) {
        add(newElement)
    }
}

extension NSMutableData: Swallow.ExtensibleSequence {
    @objc public dynamic func insert(_ newElement: Element) {
        insert(contentsOf: CollectionOfOne(newElement))
    }
    
    public func insert<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        let newElements = Array(newElements)
        
        replaceBytes(in: .init(0..<0), withBytes: newElements, length: newElements.count)
    }
    
    @objc public dynamic func append(_ newElement: Element) {
        append(contentsOf: CollectionOfOne(newElement))
    }
    
    public func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        let newElements = Array(newElements)
        
        append(newElements, length: newElements.count)
    }
}
