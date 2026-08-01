//
// Copyright (c) Vatsal Manot
//

import MachO

extension DynamicLinkEditor.Image {
    public struct LoadedSymbol: CustomDebugStringConvertible, Hashable, Sendable {
        public let metadata: MachOFormat.Symbol
        public let address: DynamicLibraryLoader.SymbolAddress?

        public var debugDescription: String {
            metadata.name.rawValue
        }

        init(metadata: MachOFormat.Symbol, slide: MachOFormat.VirtualMemorySlide) {
            self.metadata = metadata

            let resolvedAddress: MachOFormat.VirtualMemoryAddress?
            if let virtualMemoryAddress = metadata.virtualMemoryAddress {
                resolvedAddress = slide.applying(to: virtualMemoryAddress)
            } else if metadata.kind == .absolute {
                resolvedAddress = MachOFormat.VirtualMemoryAddress(rawValue: metadata.value.rawValue)
            } else {
                resolvedAddress = nil
            }

            address = resolvedAddress
                .flatMap { UInt(exactly: $0.rawValue) }
                .flatMap(UnsafeRawPointer.init(bitPattern:))
                .map(DynamicLibraryLoader.SymbolAddress.init)
        }
    }

    public struct SymbolIterator: Sequence, IteratorProtocol, Sendable {
        private let symbols: [LoadedSymbol]
        private var index = 0

        init?(image: DynamicLinkEditor.Image) throws {
            guard image.header.magic == .machO64 else {
                return nil
            }

            let loadCommands = try image.loadCommands
            guard let symbolTable = try loadCommands.symbolTables.first,
                  let linkEdit = try loadCommands.segments.first(where: { $0.name == .linkEdit }),
                  let linkEditEndOffset = linkEdit.fileRegion.endOffset,
                  let stringTableByteCount = Int(exactly: symbolTable.stringTableRegion.size.rawValue)
            else {
                return nil
            }

            let (symbolTableByteCount, symbolTableSizeOverflow) = UInt64(symbolTable.symbolCount)
                .multipliedReportingOverflow(
                    by: UInt64(MemoryLayout<nlist_64>.stride)
                )
            let (symbolTableEndOffset, symbolTableEndOverflow) = symbolTable.symbolTableOffset.rawValue
                .addingReportingOverflow(symbolTableByteCount)
            guard let stringTableEndOffset = symbolTable.stringTableRegion.endOffset else {
                return nil
            }
            guard !symbolTableSizeOverflow,
                  !symbolTableEndOverflow,
                  let symbolTableStorageByteCount = Int(exactly: symbolTableByteCount),
                  symbolTable.symbolTableOffset >= linkEdit.fileRegion.offset,
                  symbolTable.stringTableRegion.offset >= linkEdit.fileRegion.offset,
                  symbolTableEndOffset <= linkEditEndOffset.rawValue,
                  stringTableEndOffset <= linkEditEndOffset,
                  let slidVirtualMemoryAddress = image.slide.applying(
                    to: linkEdit.virtualMemoryRegion.address
                  )
            else {
                return nil
            }

            let (linkEditAddress, fileOffsetOverflow) = slidVirtualMemoryAddress.rawValue
                .subtractingReportingOverflow(linkEdit.fileRegion.offset.rawValue)
            let (symbolTableAddress, symbolTableOverflow) = linkEditAddress.addingReportingOverflow(
                symbolTable.symbolTableOffset.rawValue
            )
            let (stringTableAddress, stringTableOverflow) = linkEditAddress.addingReportingOverflow(
                symbolTable.stringTableRegion.offset.rawValue
            )
            guard !fileOffsetOverflow,
                  !symbolTableOverflow,
                  !stringTableOverflow,
                  let symbolTableBitPattern = UInt(exactly: symbolTableAddress),
                  let stringTableBitPattern = UInt(exactly: stringTableAddress),
                  let symbolTablePointer = UnsafeRawPointer(bitPattern: symbolTableBitPattern),
                  let stringTablePointer = UnsafeRawPointer(bitPattern: stringTableBitPattern)
            else {
                return nil
            }

            let stringTable = UnsafeRawBufferPointer(
                start: stringTablePointer,
                count: stringTableByteCount
            )
            let symbolTableStorage = UnsafeRawBufferPointer(
                start: symbolTablePointer,
                count: symbolTableStorageByteCount
            )
            self.symbols = try (0..<symbolTable.symbolCount).compactMap { index in
                let entry = symbolTableStorage.loadUnaligned(
                    fromByteOffset: index * MemoryLayout<nlist_64>.stride,
                    as: nlist_64.self
                )
                guard let symbol = MachOFormat.Symbol(entry, stringTable: stringTable) else {
                    throw MachOFormat.DecodingError.malformedSymbol(index: index)
                }
                guard !symbol.isDebugging else {
                    return nil
                }

                return LoadedSymbol(metadata: symbol, slide: image.slide)
            }
        }

        public mutating func next() -> LoadedSymbol? {
            guard index < symbols.endIndex else {
                return nil
            }

            defer { index += 1 }
            return symbols[index]
        }
    }

    public var symbols: [LoadedSymbol] {
        get throws {
            guard let iterator = try SymbolIterator(image: self) else {
                return []
            }

            return Array(iterator)
        }
    }
}
