//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum CodingPathElement: Codable, CustomStringConvertible, Hashable, Sendable {
    case key(AnyCodingKey)
    case `super`(key: AnyCodingKey?)
    
    public var key: AnyCodingKey? {
        guard case .key(let result) = self else {
            return nil
        }
        
        return result
    }
    
    public init(_ key: any CodingKey) {
        self = .key(AnyCodingKey(erasing: key))
    }
    
    public var description: String {
        switch self {
            case .key(let key):
                return key.description
            case .super(let key):
                return key.map({ ".super(\"\($0.description)\")" }) ?? ".super"
        }
    }
}

public struct CodingPath: Codable, CustomStringConvertible, Hashable, Sendable, Sequence {
    private var base: [CodingPathElement]

    public var description: String {
        base.map({ $0.description }).joined(separator: " -> ")
    }

    public init(_ path: [CodingKey]) {
        self.base = path.map({ CodingPathElement.key(AnyCodingKey(erasing: $0)) })
    }
    
    public mutating func append(_ element: CodingPathElement) {
        self.base.append(element)
    }
    
    public mutating func append(_ element: any CodingKey) {
        self.base.append(CodingPathElement(element))
    }
    
    public func makeIterator() -> Array<CodingPathElement>.Iterator {
        base.makeIterator()
    }
}

// MARK: - Extensions

extension CodingPathElement {
    public func toAnyCodingKey() -> AnyCodingKey {
        switch self {
            case .key(let value):
                return .init(erasing: value)
            case .super(_):
                runtimeIssue(.unimplemented)
                
                return .init(stringValue: "super")
        }
    }
}

// MARK: - Conformances

extension CodingPathElement: CodingKey {
    public var stringValue: String {
        return toAnyCodingKey().stringValue
    }
    
    public var intValue: Int? {
        return toAnyCodingKey().intValue
    }
    
    public init(stringValue: String) {
        self = .key(AnyCodingKey(stringValue: stringValue))
    }
    
    public init(intValue: Int) {
        self = .key(AnyCodingKey(intValue: intValue))
    }
}
