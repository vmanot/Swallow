//
// Copyright (c) Vatsal Manot
//

import FoundationX
import MachO
import ObjectiveC
import Swallow

#if !os(watchOS)
public typealias _mach_header_type = mach_header_64
#else
public typealias _mach_header_type = mach_header_64
#endif

extension DynamicLinkEditor {
    public static var _totalImageCount: UInt32 {
        return _dyld_image_count()
    }

    @frozen
    public struct Image: Hashable, Identifiable, @unchecked Sendable, URLInitiable {
        public static var _allAddedCases = IdentifierIndexingArrayOf<Self>()
        
        public var isValid: Bool {
            index < DynamicLinkEditor._totalImageCount
        }

        public let index: UInt32
        public let name: String
        public let header: UnsafePointer<mach_header>
        public let slide: Int
        
        public struct ID: Hashable, Sendable {
            let rawValue: String
        }
        
        public var id: ID {
            .init(rawValue: name)
        }
        
        public init(
            index: UInt32,
            slide: Int? = nil,
            name: String? = nil,
            header: UnsafePointer<mach_header>?
        ) {
            self.index = index
            self.name = name ?? String(cString: _dyld_get_image_name(index))
            self.header = header ?? _dyld_get_image_header(index)
            self.slide = slide ?? _dyld_get_image_vmaddr_slide(index)
            
            Self._allAddedCases.update(self)
            
            assert(isValid)
        }
        
        @_transparent
        public init<T: BinaryInteger>(
            index: T
        ) {
            self.init(index: numericCast(index), slide: nil, name: nil, header: nil)
        }
        
        public init?(url: URL) {
            guard let image = Self.allCases.first(where: { $0.name == url.path }) else {
                return nil
            }
            
            self = image
        }
    }
}

extension DynamicLinkEditor.Image {
    @usableFromInline
    static var _imagesByName: [String: DynamicLinkEditor.Image] = {
        Self.allCases.groupFirstOnly(by: \.name)
    }()
    
    @_transparent
    public init?(name: String) {
        guard let image = Self._imagesByName[name] ?? Self.allCases.first(where: { $0.name == name }) else {
            return nil
        }
        
        self = image
    }
}

// MARK: - Conformances

extension DynamicLinkEditor.Image: CaseIterable {
    public static let allCases: [Self] = {
        DynamicLinkEditor.Image._allCases()
    }()
    
    public static func _allCases() -> [DynamicLinkEditor.Image] {
        let images: UInt32 = _dyld_image_count()
        var result: [DynamicLinkEditor.Image] = []
        
        for index in 0..<images {
            let name = String(cString: _dyld_get_image_name(index))
            let header = _dyld_get_image_header(index)!
            
            let image = DynamicLinkEditor.Image(
                index: index,
                name: name,
                header: header
            )
            
            result.append(image)
        }
        
        return result
    }
}

extension DynamicLinkEditor.Image: CustomStringConvertible {
    public var description: String {
        name
    }
}

// MARK: - Auxiliary

extension DynamicLinkEditor.Image {
    public enum _ImagePathFilter: String, CaseIterable {
        private static var matchesByName: [Hashable2ple<Self, String>: Bool] = [:]
        
        static let appleFramework: Set<_ImagePathFilter> = [
            .coreSimulator,
            .xcode,
            .developerApplications,
            .developerFrameworks,
            .developerPrivateFrameworks,
            .developerPlatforms,
            .developerTools,
            .preboot,
            .systemFrameworks,
            .systemPrivateFrameworks,
            .systemCoreServices,
            .systemApplications,
            .systemExtensions,
            .systemLibraries,
            .userLibraries,
            .xcode
        ]
        
        case coreSimulator = "/Library/Developer/CoreSimulator"
        case xcode = "/Applications/Xcode.app"
        case developerApplications = "/Developer/Applications"
        case developerFrameworks = "/Developer/Library/Frameworks"
        case developerPrivateFrameworks = "/Developer/Library/PrivateFrameworks"
        case developerPlatforms = "/Developer/Platforms"
        case developerTools = "/Developer/Tools"

        case preboot = "/private/preboot"

        case systemFrameworks = "/System/Library/Frameworks"
        case systemPrivateFrameworks = "/System/Library/PrivateFrameworks"
        case systemCoreServices = "/System/Library/CoreServices"
        case systemApplications = "/System/Applications"
        case systemExtensions = "/System/Library/Extensions"
        case systemLibraries = "/System/Library/Libraries"
        case systemKernelExtensions = "/System/Library/Extensions/Kernels"

        case userLibraries = "/usr/lib"
        case userLocalBin = "/usr/local/bin"
        case userLocalLib = "/usr/local/lib"
        case userBin = "/usr/bin"
        case userSbin = "/usr/sbin"

        func matches(_ image: DynamicLinkEditor.Image) -> Bool {
            Self.matchesByName[Hashable2ple((self, image.name))].unwrapOrInitializeInPlace { () -> Bool in
                return image.name.hasPrefix(self.rawValue)
            }
        }
    }
}

extension DynamicLinkEditor.Image {
    func _matches(_ filter: _ImagePathFilter) -> Bool {
        filter.matches(self)
    }
    
    @_transparent
    func _matches(_ filters: Set<_ImagePathFilter>) -> Bool {
        _memoize(uniquingWith: (self.name, filters)) {
            filters.contains(where: { $0.matches(self) })
        }
    }
}

// MARK: - Supplementary

extension DynamicLinkEditor.Image {
    public var allObjCTypes: [ObjCClass] {
        ObjCClass.allCases(in: self)
    }
}

extension ObjCClass {
    private static var _dyldImageNameCache: [ObjectIdentifier: String] = [:]
    
    public var _dyldImageName: String? {
        try? ObjCClass._dyldImageNameCache[ObjectIdentifier(self.base)].unwrapOrInitializeInPlace { () -> String? in
            guard let name = class_getImageName(value) else {
                return nil
            }
            
            return String(cString: name)
        }
    }
    
    @_transparent
    public var dyldImage: DynamicLinkEditor.Image? {
        _dyldImageName.map({ DynamicLinkEditor.Image(name: $0)! })
    }
}

extension ObjCClass {
    public static var _classesByImage: [DynamicLinkEditor.Image.ID: [ObjCClass]] = [:]
    
    public static func allCases(in image: DynamicLinkEditor.Image) -> [ObjCClass] {
        Self._classesByImage[image.id].unwrapOrInitializeInPlace {
            _allCases(in: image)
        }
    }
    
    private static func _allCases(in image: DynamicLinkEditor.Image) -> [ObjCClass] {
        var outCount: UInt32 = 0
        let classNames = objc_copyClassNamesForImage(image.name, &outCount)!
        
        var result: [ObjCClass] = Array(capacity: Int(outCount))
        
        for i in 0..<Int(outCount) {
            let className = classNames[i]
            let aClass: AnyClass = objc_getClass(className) as! AnyClass
            
            result.append(ObjCClass(aClass))
        }
        
        return result
    }
}

extension DynamicLinkEditor.Image {
    public struct Dependency {
        public let name: String
        public let compatibilityVersion: UInt32
        public let currentVersion: UInt32
        public let timestamp: UInt32
    }
    
    public var dependencies: [Dependency] {
        var deps: [Dependency] = []
        var curCmd = UnsafeMutablePointer<load_command>(OpaquePointer(header))
        
        // Move past the header to the first load command
        curCmd = UnsafeMutableRawPointer(mutating: header).advanced(by: MemoryLayout<mach_header_64>.size)
            .assumingMemoryBound(to: load_command.self)
        
        // Iterate through all load commands
        for _ in 0..<header.pointee.ncmds {
            if curCmd.pointee.cmd == LC_LOAD_DYLIB || curCmd.pointee.cmd == LC_LOAD_WEAK_DYLIB {
                let dylibCmd = UnsafeMutableRawPointer(curCmd)
                    .assumingMemoryBound(to: dylib_command.self)
                
                // Get the string offset from the dylib command
                let stringOffset = Int(dylibCmd.pointee.dylib.name.offset)
                
                // Calculate the address of the string
                let stringPtr = UnsafeMutableRawPointer(dylibCmd)
                    .advanced(by: stringOffset)
                    .assumingMemoryBound(to: CChar.self)
                
                let name = String(cString: stringPtr)
                let dependency = Dependency(
                    name: name,
                    compatibilityVersion: dylibCmd.pointee.dylib.compatibility_version,
                    currentVersion: dylibCmd.pointee.dylib.current_version,
                    timestamp: dylibCmd.pointee.dylib.timestamp
                )
                
                deps.append(dependency)
            }
            
            // Move to the next command
            curCmd = UnsafeMutableRawPointer(curCmd)
                .advanced(by: Int(curCmd.pointee.cmdsize))
                .assumingMemoryBound(to: load_command.self)
        }
        
        return deps
    }
    
    public func depends(on other: DynamicLinkEditor.Image) -> Bool {
        // Get the dependencies and check if any match the other image's name
        // Note: We compare the last path component since full paths might differ
        let otherName = (other.name as NSString).lastPathComponent
        return dependencies.contains { dependency in
            let depName = (dependency.name as NSString).lastPathComponent
            return depName == otherName
        }
    }
}

// Example usage:
extension DynamicLinkEditor.Image {
    public var allDependencies: Set<DynamicLinkEditor.Image> {
        var result: Set<DynamicLinkEditor.Image> = []
        
        for dependency in dependencies {
            let depName = (dependency.name as NSString).lastPathComponent
            if let depImage = DynamicLinkEditor.Image.allCases.first(where: {
                ($0.name as NSString).lastPathComponent == depName
            }) {
                result.insert(depImage)
            }
        }
        
        return result
    }
}
