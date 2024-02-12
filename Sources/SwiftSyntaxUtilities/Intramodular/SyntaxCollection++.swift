//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension SyntaxCollection {
    public mutating func removeAll<T: SyntaxProtocol>(
        _ type: T.Type,
        where shouldBeRemoved: (T) throws -> Bool
    ) rethrows {
        var indicesToRemove: [SyntaxChildrenIndex] = []
        
        for index in self.indices {
            if let element = self[index].as(type) {
                if try shouldBeRemoved(element) {
                    indicesToRemove.append(index)
                }
            }
        }
        
        indicesToRemove.reversed().forEach {
            self.remove(at: $0)
        }
    }

    public mutating func removeAll(
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
        var indicesToRemove: [SyntaxChildrenIndex] = []
        
        for index in self.indices {
            if try shouldBeRemoved(self[index]) {
                indicesToRemove.append(index)
            }
        }
        
        indicesToRemove.reversed().forEach {
            self.remove(at: $0)
        }
    }
}
