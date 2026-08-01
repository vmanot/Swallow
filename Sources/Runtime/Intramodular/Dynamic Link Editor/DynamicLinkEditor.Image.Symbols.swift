//
// Copyright (c) Vatsal Manot
//

import MachO

extension DynamicLinkEditor.Image {
    public struct Symbol: CustomStringConvertible, Hashable, Sendable {
        public let machOSymbol: MachOFormat.Symbol
        public let address: DynamicLinkEditor.SymbolAddress?

        /// The name accepted by `dlsym`, without Mach-O's leading C symbol underscore.
        public var dynamicLinkerName: String {
            let name = machOSymbol.name.rawValue
            return name.first == "_" ? String(name.dropFirst()) : name
        }

        public var description: String {
            machOSymbol.name.rawValue
        }

        init(_ machOSymbol: MachOFormat.Symbol, slide: MachOFormat.VirtualMemorySlide) {
            self.machOSymbol = machOSymbol

            let resolvedAddress: MachOFormat.VirtualMemoryAddress?
            if let virtualMemoryAddress = machOSymbol.virtualMemoryAddress {
                resolvedAddress = slide.applying(to: virtualMemoryAddress)
            } else if machOSymbol.kind == .absolute {
                resolvedAddress = MachOFormat.VirtualMemoryAddress(
                    rawValue: machOSymbol.value.rawValue
                )
            } else {
                resolvedAddress = nil
            }

            address = resolvedAddress
                .flatMap { UInt(exactly: $0.rawValue) }
                .flatMap(UnsafeRawPointer.init(bitPattern:))
                .map(DynamicLinkEditor.SymbolAddress.init)
        }
    }

    public var symbols: [Symbol] {
        get throws {
            guard header.magic == .machO64 else {
                throw MachOFormat.DecodingError.unsupportedMagic(header.magic)
            }

            let loadCommands = try loadCommands
            guard let symbolTable = try loadCommands.symbolTables.first else {
                return []
            }
            guard let linkEdit = try loadCommands.segments.first(where: { $0.name == .linkEdit }),
                  let linkEditEndOffset = linkEdit.fileRegion.endOffset,
                  let stringTableByteCount = Int(exactly: symbolTable.stringTableRegion.size.rawValue)
            else {
                throw MachOFormat.DecodingError.malformedSymbolTable
            }

            let (symbolTableByteCount, symbolTableSizeOverflow) = UInt64(symbolTable.symbolCount)
                .multipliedReportingOverflow(by: UInt64(MemoryLayout<nlist_64>.stride))
            let (symbolTableEndOffset, symbolTableEndOverflow) = symbolTable.symbolTableOffset.rawValue
                .addingReportingOverflow(symbolTableByteCount)
            guard let stringTableEndOffset = symbolTable.stringTableRegion.endOffset,
                  !symbolTableSizeOverflow,
                  !symbolTableEndOverflow,
                  let symbolTableStorageByteCount = Int(exactly: symbolTableByteCount),
                  symbolTable.symbolTableOffset >= linkEdit.fileRegion.offset,
                  symbolTable.stringTableRegion.offset >= linkEdit.fileRegion.offset,
                  symbolTableEndOffset <= linkEditEndOffset.rawValue,
                  stringTableEndOffset <= linkEditEndOffset,
                  let slidVirtualMemoryAddress = slide.applying(
                    to: linkEdit.virtualMemoryRegion.address
                  )
            else {
                throw MachOFormat.DecodingError.malformedSymbolTable
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
                throw MachOFormat.DecodingError.malformedSymbolTable
            }

            let stringTable = UnsafeRawBufferPointer(
                start: stringTablePointer,
                count: stringTableByteCount
            )
            let symbolTableStorage = UnsafeRawBufferPointer(
                start: symbolTablePointer,
                count: symbolTableStorageByteCount
            )

            return try (0..<symbolTable.symbolCount).compactMap { index in
                let entry = symbolTableStorage.loadUnaligned(
                    fromByteOffset: index * MemoryLayout<nlist_64>.stride,
                    as: nlist_64.self
                )
                guard let symbol = MachOFormat.Symbol(entry, stringTable: stringTable) else {
                    throw MachOFormat.DecodingError.malformedSymbol(index: index)
                }

                return symbol.isDebugging ? nil : Symbol(symbol, slide: slide)
            }
        }
    }
}
