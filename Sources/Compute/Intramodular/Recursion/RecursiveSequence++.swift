//
// Copyright (c) Vatsal Manot
//

import Swallow

extension RecursiveSequence {
    public func topLevelUnits() -> AnySequence<Unit> {
        return .init(lazy.map(keyPath: \.leftValue).compact())
    }
    
    public func topLevelSequences() -> AnySequence<Self> {
        return .init(lazy.map(keyPath: \.rightValue).compact())
    }
}

extension RecursiveSequence  {
    public func recursiveForEach<T>(
        _ iterator: ((Unit) throws -> T)
    ) rethrows {
        try forEach({ try $0.collapse(iterator, { try $0.recursiveForEach(iterator) }) })
    }
    
    public func recursiveMap<RDS: SequenceInitiableRecursiveSequence>(
        _ transform: ((Unit) throws -> RDS.Unit)
    ) rethrows -> RDS {
        return .init(try map({ try $0.map(transform, { try $0.recursiveMap(transform) }) }))
    }
    
    public func recursiveFilter<RDS: SequenceInitiableRecursiveSequence>(
        _ predicate: ((Unit) throws -> Bool)
    ) rethrows -> RDS where RDS.Unit == Unit {
        return .init(try map({ try $0.filterOrMap(predicate, { try $0.recursiveFilter(predicate) }) }).compact())
    }
    
    public func recursiveReduce<T>(_ initialResult: T, _ nextPartialResult: ((T, Unit) throws -> T)) rethrows -> T {
        return try reduce(initialResult, { (x, y) in try y.reduce({ try nextPartialResult(x, $0) }, { try $0.recursiveReduce(x, nextPartialResult) }) })
    }
    
    public func recursiveReduce<T>(_ nextPartialResult: ((T?, Unit?) throws -> T?)) rethrows -> T? {
        return try reduce(nil, { (x, y) in try y.reduce({ try nextPartialResult(x, $0) }, { try $0.recursiveReduce(x, nextPartialResult) }) })
    }
    
    public func recursiveCompactReduce(_ nextPartialResult: ((Unit, Unit) throws -> Unit)) rethrows -> Unit? {
        var result: Unit?
        
        for element in self {
            if let unit = element.leftValue {
                result = try result.map({ try nextPartialResult($0, unit) }) ?? unit
            } else if let unit = try element.rightValue!.recursiveCompactReduce(nextPartialResult) {
                result = try result.map({ try nextPartialResult($0, unit) }) ?? unit
            }
        }
        
        return result
    }
    
    public func recursiveCompactConcatenate<S: SequenceInitiableSequence>(_ combine: ((S) throws -> Unit)) rethrows -> Unit? where S.Element == Unit {
        return try combine(try _map({ try combine($0.reduce(S.init(element:), { try $0.recursiveCompactConcatenate(combine).map(S.init(element:)) ?? .init(noSequence: ()) })) }))
    }
}
