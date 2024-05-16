//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct SequenceParser<S: NonDestroyingCollection> where S.SubSequence: Hashable & SequenceInitiableSequence, S.Element: Hashable {
    var prefixSuffixTuples: Set<Hashable2ple<S.SubSequence, S.SubSequence>> = []
    var tokenizer = SequenceTokenizer<S>()
    
    public var stripPrefixesAndSuffixes: Bool = true
    
    public init() {
        
    }
    
    public mutating func insert(prefix: S.SubSequence, suffix: S.SubSequence) {
        prefixSuffixTuples += .init((prefix, suffix))
        
        tokenizer.tokens += prefix
        tokenizer.tokens += suffix
    }
    
    public mutating func insert(token: S.SubSequence) {
        tokenizer.tokens += token
    }
    
    public mutating func insert(tokens: Set<S.SubSequence>) {
        tokenizer.tokens += tokens
    }
}

extension SequenceParser {
    public func input(
        _ sequence: S
    ) -> RecursiveArray<S.SubSequence> {
        var stack: [RecursiveArray<S.SubSequence>] = [[]]
        
        for subSequence in tokenizer.input(sequence) {
            if let prefix = prefixSuffixTuples.find({ $0.value.0 == subSequence }) {
                stack.append([])
                
                if !stripPrefixesAndSuffixes {
                    stack[.last] += prefix.value.0
                }
            }
            
            else if let suffix = prefixSuffixTuples.find({ $0.value.1 == subSequence }) {
                if !stripPrefixesAndSuffixes {
                    stack[.last] += suffix.value.1
                }
                
                stack[.last] += stack.removeLast()
            }
            
            else {
                stack[.last] += subSequence
            }
        }
        
        return stack.first.forceUnwrap()
    }
}

extension SequenceParser {
    public class AttributedNode: CustomStringConvertible {
        public let value: S.SubSequence
        public let attributes: Set<S.SubSequence>
        
        public var description: String {
            return String(describing: (Array(attributes), value))
        }
        
        public init(_ value: S.SubSequence, attributes: Set<S.SubSequence>) {
            self.value = value
            self.attributes = attributes
        }
        
        public func has(_ attribute: S.SubSequence) -> Bool {
            return attributes.contains(attribute)
        }
    }
    
    public func input(_ sequence: S, attributes: Set<S.SubSequence>) -> RecursiveArray<AttributedNode> {
        let output = input(sequence).recursiveAdjacencyMap()
        let filtered = output.recursiveFilter({ x in !(x.value.leftValue.map({ attributes.contains($0) }) ?? true) }) as RecursiveArray
        
        func getAttributes(from element: RecursiveAdjacencyMapElement<RecursiveArray<S.SubSequence>>) -> Set<S.SubSequence> {
            var lastLeft = element.left
            
            var result: Set<S.SubSequence> = []
            
            while let left = lastLeft {
                if let leftValue = left.value.leftValue, attributes.contains(leftValue) {
                    result.insert(leftValue)
                }
                
                else {
                    break
                }
                
                lastLeft = left.left
            }
            
            return result
        }
        
        return filtered.recursiveMap({ AttributedNode($0.value.leftValue!, attributes: getAttributes(from: $0)) })
    }
}
