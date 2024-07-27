//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

extension ExtensibleSequence where Self: SequenceInitiableSequence, Element: Countable & UTF8Representable, Element.Count == Int {
    public init(
        utf8StringsFromSwiftRuntime utf8Strings: UnsafePointer<CChar>,
        count: Int
    ) throws {
        self.init(noSequence: ())
        
        var utf8Strings = utf8Strings.mutableRepresentation
        
        for _ in 0..<count {
            let element = try Element(validatingUTF8String: NullTerminatedUTF8String(utf8Strings)).forceUnwrap()
            
            append(element)
            
            utf8Strings += (element.count + 1)
        }
    }
    
    public init(
        validatingDoublyNullTerminatedUTF8StringsFromSwiftRuntime utf8Strings: UnsafePointer<CChar>
    ) throws {        
        self.init(noSequence: ())
        
        var utf8Strings = utf8Strings.mutableRepresentation

        while (utf8Strings[0], utf8Strings[1]) != (0, 0) {
            let element = try Element(validatingUTF8String: NullTerminatedUTF8String(utf8Strings)).forceUnwrap()
            
            append(element)
            
            utf8Strings += (element.count + 1)
        }
    }
}
