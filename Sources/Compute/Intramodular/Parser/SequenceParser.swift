//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct SequenceParser<S: NonDestroyingCollection> where S.SubSequence: Hashable & SequenceInitiableSequence, S.Element: Hashable {
    private struct PrefixSuffixPair: Hashable {
        let prefix: S.SubSequence
        let suffix: S.SubSequence
    }
    
    private var prefixSuffixPairs: Set<PrefixSuffixPair> = []
    private var tokenizer: SequenceTokenizer<S> = SequenceTokenizer()
    
    public var stripPrefixesAndSuffixes: Bool
    
    public init(stripPrefixesAndSuffixes: Bool = true) {
        self.stripPrefixesAndSuffixes = stripPrefixesAndSuffixes
    }
    
    public init() {
        self.init(stripPrefixesAndSuffixes: true)
    }
    
    public mutating func insert(
        prefix: S.SubSequence,
        suffix: S.SubSequence
    ) {
        prefixSuffixPairs.insert(PrefixSuffixPair(prefix: prefix, suffix: suffix))
        
        tokenizer.tokens += [prefix, suffix]
    }
    
    public mutating func insert(
        token: S.SubSequence
    ) {
        tokenizer.tokens += token
    }
    
    public mutating func insert(
        tokens: Set<S.SubSequence>
    ) {
        tokenizer.tokens += tokens
    }
    
    public func input(_ sequence: S) -> RecursiveArray<S.SubSequence> {
        var stack: [RecursiveArray<S.SubSequence>] = [[]]
        
        for subSequence in tokenizer.input(sequence) {
            if let prefixPair = prefixSuffixPairs.first(where: { $0.prefix == subSequence }) {
                handlePrefix(prefixPair, &stack)
            } else if let suffixPair = prefixSuffixPairs.first(where: { $0.suffix == subSequence }) {
                handleSuffix(suffixPair, &stack)
            } else {
                stack[stack.count - 1].append(.left(subSequence))
            }
        }
        
        return stack.first ?? []
    }
    
    private func handlePrefix(
        _ pair: PrefixSuffixPair,
        _ stack: inout [RecursiveArray<S.SubSequence>]
    ) {
        stack.append([])
        if !stripPrefixesAndSuffixes {
            stack[stack.count - 1].append(.left(pair.prefix))
        }
    }
    
    private func handleSuffix(
        _ pair: PrefixSuffixPair,
        _ stack: inout [RecursiveArray<S.SubSequence>]
    ) {
        if !stripPrefixesAndSuffixes {
            stack[stack.count - 1].append(.left(pair.suffix))
        }
        let last = stack.removeLast()
        stack[stack.count - 1].append(.right(last))
    }
}

extension SequenceParser {
    public struct AttributedNode: CustomStringConvertible {
        public let value: S.SubSequence
        public let attributes: Set<S.SubSequence>
        
        public var description: String {
            return "(\(Array(attributes)), \(value))"
        }
        
        public func has(_ attribute: S.SubSequence) -> Bool {
            return attributes.contains(attribute)
        }
    }
    
    public func parseWithAttributes(
        _ sequence: S,
        attributes: Set<S.SubSequence>
    ) -> RecursiveArray<AttributedNode> {
        let parsed: RecursiveArray = input(sequence).recursiveAdjacencyMap()
        let filtered = parsed.recursiveFilter({
            x in !(x.value.leftValue.map({ attributes.contains($0) }) ?? true)
        }) as RecursiveArray
        
        return filtered.recursiveMap { element in
            AttributedNode(
                value: element.value.leftValue!,
                attributes: getAttributes(from: element, in: attributes)
            )
        }
    }
    
    private func getAttributes(
        from element: RecursiveAdjacencyMapElement<RecursiveArray<S.SubSequence>>,
        in attributes: Set<S.SubSequence>
    ) -> Set<S.SubSequence> {
        var result: Set<S.SubSequence> = []
        var current = element.left
        
        while let left = current {
            if let leftValue = left.value.leftValue, attributes.contains(leftValue) {
                result.insert(leftValue)
            } else {
                break
            }
            
            current = left.left
        }
        
        return result
    }
}
