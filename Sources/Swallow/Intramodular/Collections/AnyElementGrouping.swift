//
// Copyright (c) Vatsal Manot
//

import Swift

public enum ElementGrouping<Element> {
    public struct RankedHierarchy {
        public let primary: Element
        public let secondary: Element?
        public let tertiary: Element?
        
        public init(primary: Element) {
            self.primary = primary
            self.secondary = nil
            self.tertiary = nil
        }
        
        public init(primary: Element, secondary: Element?) {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = nil
        }
        
        public init(primary: Element, secondary: Element?, tertiary: Element?) {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
        }
    }
    
    case single(Element)
    case set(any SetProtocol<Element>)
    case sequence(any Sequence<Element>)
    case ranked(RankedHierarchy)
    
    public static func ranked(
        primary: Element
    ) -> Self {
        self.ranked(RankedHierarchy(primary: primary))
    }
    
    public static func ranked(
        primary: Element,
        secondary: Element
    ) -> Self {
        self.ranked(RankedHierarchy(primary: primary, secondary: secondary))
    }
    
    public static func ranked(
        primary: Element,
        secondary: Element,
        tertiary: Element
    ) -> Self {
        self.ranked(RankedHierarchy(primary: primary, secondary: secondary, tertiary: tertiary))
    }
}
