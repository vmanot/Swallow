import _MachOPrivate
import MachOSwift

@_extern(c, "swift_demangle")
fileprivate func _stdlib_demangleImpl(
  mangledName: UnsafePointer<CChar>?,
  mangledNameLength: UInt,
  outputBuffer: UnsafeMutablePointer<CChar>?,
  outputBufferSize: UnsafeMutablePointer<UInt>?,
  flags: UInt32
) -> UnsafeMutablePointer<CChar>?

/*
 https://github.com/swiftlang/swift/blob/8b4740f0ccf6218a70389d46c213d2b4365b8322/lib/Demangling/Demangler.cpp#L186
 */
fileprivate let swiftSymbolPrefixes = [
    /*Swift 4*/   "_T0",
    /*Swift 4.x*/ "$S", "_$S",
    /*Swift 5+*/  "$s", "_$s",
    /*Swift 5+ Embedded Swift*/  "$e", "_$e",
    /*Swift 5+ for filenames*/ "@__swiftmacro_",
]

public struct Symbol: Sendable, Equatable {
//    public let offset: UInt
    public let name: String?
    
    public var demangledName: String? {
        guard let name else { return nil }
        
        return name.withCString { namePointer in
            guard let mangledNamePointer = _stdlib_demangleImpl(mangledName: namePointer, mangledNameLength: UInt(name.count), outputBuffer: nil, outputBufferSize: nil, flags: 0) else {
                return nil
                
            }
            
            let mangledName = String(cString: mangledNamePointer)
            mangledNamePointer.deallocate()
            return mangledName
        }
    }
    
    public var isSwiftSymbol: Bool {
        guard let name else { return false }
        
        for prefix in swiftSymbolPrefixes {
            if name.hasPrefix(prefix) {
                return true
            }
        }
        
        return false
    }
}

extension Symbol {
    @discardableResult
    static func forEachImportedSymbol(
        machHeader: UnsafePointer<mach_header>,
        mappedSize: Int,
        body: (_ symbolName: String?, _ libraryPath: String?, _ weakImport: Bool) -> Bool
    ) -> CInt {
        withoutActuallyEscaping(body) { escapingClosure in
            macho_for_each_imported_symbol(machHeader, mappedSize) { symbolName, libraryPath, weakImport, stop in
                stop.pointee = !escapingClosure(String(cString: symbolName, encoding: .utf8), String(cString: libraryPath, encoding: .utf8), weakImport)
            }
        }
    }
    
    @discardableResult
    static func forEachExportedSymbol(
        machHeader: UnsafePointer<mach_header>,
        mappedSize: Int,
        _ body: (_ symbolName: String?, _ attributes: String?) -> Bool
    ) -> CInt {
        withoutActuallyEscaping(body) { escapingClosure in
            macho_for_each_exported_symbol(machHeader, mappedSize) { symbolName, attributes, stop in
                stop.pointee = !escapingClosure(String(cString: symbolName, encoding: .utf8), String(cString: attributes, encoding: .utf8))
            }
        }
    }
}

extension MachOSwift.MachOFile {
    public var importedSymbols: [Symbol] {
        withMachHeaderPointer { pointer in
            var results: [Symbol] = []
            let result = Symbol
                .forEachImportedSymbol(
                    machHeader: pointer,
                    mappedSize: Int(mappedSize)
                ) { symbolName, libraryPath, weakImport in
                    results.append(Symbol(name: symbolName ?? "redacted"))
                    return true
                }
            assert(result == 0)
            
            return results
        }
    }
    
    public var exportedSymbols: [Symbol] {
        withMachHeaderPointer { pointer in
            var results: [Symbol] = []
            let result = Symbol
                .forEachExportedSymbol(
                    machHeader: pointer,
                    mappedSize: Int(mappedSize)
                ) { symbolName, attributes in
                    results.append(Symbol(name: symbolName ?? "redacted"))
                    return true
                }
            assert(result == 0)
            
            return results
        }
    }
}

extension MachOSwift.Header {
    public func importedSymbols(sliceSize: UInt64) -> [Symbol] {
        withHeaderPointer { pointer in
            var results: [Symbol] = []
            let result = Symbol
                .forEachImportedSymbol(
                    machHeader: pointer,
                    mappedSize: Int(sliceSize)
                ) { symbolName, libraryPath, weakImport in
                    results.append(Symbol(name: symbolName ?? "redacted"))
                    return true
                }
            assert(result == 0)
            
            return results
        }
    }
    
    public func exportedSymbols(sliceSize: UInt64) -> [Symbol] {
        withHeaderPointer { pointer in
            var results: [Symbol] = []
            let result = Symbol
                .forEachExportedSymbol(
                    machHeader: pointer,
                    mappedSize: Int(sliceSize)
                ) { symbolName, attributes in
                    results.append(Symbol(name: symbolName ?? "redacted"))
                    return true
                }
            assert(result == 0)
            
            return results
        }
    }
}
