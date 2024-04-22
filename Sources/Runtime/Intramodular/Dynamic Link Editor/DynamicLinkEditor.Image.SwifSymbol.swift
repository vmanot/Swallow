//
// Copyright (c) Vatsal Manot
//

import MachO
import Swift

extension DynamicLinkEditor.Image {
    public struct SwiftSymbol: Hashable {
        public let base: UnsafeRawSymbol
                
        public var address: DynamicLibraryLoader.SymbolAddress {
            base.address
        }
        
        public var mangledName: String {
            base.name
        }

        public var demangledName: String {
            _stdlib_demangleName(mangledName)
        }
                
        init?(symbol: UnsafeRawSymbol) {
            guard symbol.type == .definedInSection, symbol.name.hasPrefix("_$s") else {
                return nil
            }
                    
            self.base = symbol
        }
    }
    
    public var swiftSymbols: [SwiftSymbol] {
        let result = self._rawSymbolIterator?.compactMap {
            SwiftSymbol(symbol: $0)
        } ?? []
        
        return result
    }
}

// MARK: - Conformances

extension DynamicLinkEditor.Image.SwiftSymbol: CustomStringConvertible {
    public var description: String {
        demangledName
    }
}
