//
// Copyright (c) Vatsal Manot
//

import MachO
import Swift

extension DynamicLinkEditor.Image {
    public struct SwiftSymbol: Hashable, Sendable {
        public let symbol: Symbol
        public let address: DynamicLinkEditor.SymbolAddress

        public var mangledName: String {
            symbol.machOSymbol.name.rawValue
        }

        public var demangledName: String {
            _stdlib_demangleName(mangledName)
        }

        init?(_ symbol: Symbol) {
            guard symbol.machOSymbol.kind == .definedInSection,
                  symbol.machOSymbol.name.rawValue.hasPrefix("_$s"),
                  let address: DynamicLinkEditor.SymbolAddress = symbol.address
            else {
                return nil
            }

            self.symbol = symbol
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
