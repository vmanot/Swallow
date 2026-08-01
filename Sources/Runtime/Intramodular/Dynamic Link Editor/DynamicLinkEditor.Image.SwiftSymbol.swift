//
// Copyright (c) Vatsal Manot
//

import MachO
import Swift

extension DynamicLinkEditor.Image {
    public struct SwiftSymbol: Hashable {
        public let base: LoadedSymbol
        public let address: DynamicLibraryLoader.SymbolAddress
                
        public var mangledName: String {
            base.metadata.name.rawValue
        }

        public var demangledName: String {
            _stdlib_demangleName(mangledName)
        }
                
        init?(symbol: LoadedSymbol) {
            guard symbol.metadata.kind == .definedInSection,
                  symbol.metadata.name.rawValue.hasPrefix("_$s"),
                  let address: DynamicLibraryLoader.SymbolAddress = symbol.address
            else {
                return nil
            }
                    
            self.base = symbol
            self.address = address
        }
    }
    
    public var swiftSymbols: [SwiftSymbol] {
        get throws {
            try symbols.compactMap(SwiftSymbol.init)
        }
    }
}

// MARK: - Conformances

extension DynamicLinkEditor.Image.SwiftSymbol: CustomStringConvertible {
    public var description: String {
        demangledName
    }
}
