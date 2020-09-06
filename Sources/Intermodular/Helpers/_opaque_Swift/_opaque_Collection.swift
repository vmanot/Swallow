//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Collection2 = _opaque_Collection & Collection

public protocol _opaque_Collection: _opaque_Sequence {
    var isEmpty: Bool { get }
    
    static var _opaque_Collection_Element: Any.Type { get }
    static var _opaque_Collection_Index: Any.Type { get }
    
    var _opaque_Collection_startIndex: Any { get }
    var _opaque_Collection_endIndex: Any { get }
    
    func _opaque_Collection_element(atPosition _: Any) -> Any?
    func _opaque_Collection_elements(withinBounds _: Any) -> Any?
    
    func _opaque_Collection_index(after i: Any) -> Any?
    func _opaque_Collection_formIndex(after i: inout Any) -> Void?
    
    func _opaque_Collection_toAnyCollection() -> Any
    func _opaque_Collection_toAnyBidirectionalCollectionUsingFauxRandomAccessCollection() -> Any
    func _opaque_Collection_toAnyRandomAccessCollectionUsingFauxRandomAccessCollection() -> Any
}

extension _opaque_Collection where Self: Collection {
    public static var _opaque_Collection_Element: Any.Type {
        return Element.self
    }
    
    public static var _opaque_Collection_Index: Any.Type {
        return Index.self
    }
    
    public var _opaque_Collection_startIndex: Any {
        return startIndex
    }
    
    public var _opaque_Collection_endIndex: Any {
        return endIndex
    }
    
    public func _opaque_Collection_element(atPosition position: Any) -> Any? {
        return (-?>position).map({ self[$0 as Index] as Any })
    }
    
    public func _opaque_Collection_elements(withinBounds bounds: Any) -> Any? {
        return (-?>bounds).map({ self[$0 as Range<Index>] })
    }
    
    public func _opaque_Collection_index(after i: Any) -> Any? {
        guard let i = i as? Index else {
            return nil
        }
        
        return index(after: i)
    }
    
    public func _opaque_Collection_formIndex(after i: inout Any) -> Void? {
        guard var _i = i as? Index else {
            return nil
        }
        
        formIndex(after: &_i)
        
        i = _i
        
        return ()
    }
    
    public func _opaque_Collection_toAnyCollection() -> Any {
        return AnyCollection(fauxRandomAccessView)
    }
    
    public func _opaque_Collection_toAnyBidirectionalCollectionUsingFauxRandomAccessCollection() -> Any {
        return AnyBidirectionalCollection(fauxRandomAccessView)
    }
    
    public func _opaque_Collection_toAnyRandomAccessCollectionUsingFauxRandomAccessCollection() -> Any {
        return AnyRandomAccessCollection(fauxRandomAccessView)
    }
}
