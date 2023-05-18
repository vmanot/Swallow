//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Sliceable: Collection {
    init()
    
    subscript (_ start: Int?, _ stop: Int?, _ step: Int?) -> Self { get }
    subscript (_ start: Int?, _ end: Int?) -> Self { get }
    subscript (_ i: Int) -> Self.Element { get }
    subscript (_ slice: Slice) -> Self { get }
    
    mutating func append(_ newElement: Self.Element)
}

extension Sliceable {
    public subscript(_ start: Int?, _ stop: Int?, _ step: Int?) -> Self {
        return self[Slice(start: start, stop: stop, step: step)]
    }
    
    public subscript(_ start: Int?, _ end: Int?) -> Self {
        return self[start, end, nil]
    }
    
    public subscript (_ slice: Slice) -> Self {
        var (start, _, step, loop) = slice.adjustIndex(self.count)
        var result = Self.init()
        for _ in 0..<loop {
            result.append(self[start])
            start += step
        }
        return result
    }
}

func backIndex(i: Int, l: Int) -> Int {
    return i < 0 ? l + i : i
}

extension String: Sliceable {
    public subscript (_ i: Int) -> Character {
        get {
            return self[self.index(self.startIndex, offsetBy: backIndex(i: i, l: self.count))]
        } set(c) {
            let v = self.index(self.startIndex, offsetBy: backIndex(i: i, l: self.count))
            let v2 = self.index(v, offsetBy: 1)
            self.replaceSubrange(v..<v2, with: [c])
        }
    }
}
