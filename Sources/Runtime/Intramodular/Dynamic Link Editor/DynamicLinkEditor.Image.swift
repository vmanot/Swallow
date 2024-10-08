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
            .preboot,
            .systemFrameworks,
            .systemPrivateFrameworks,
            .userLibraries,
            .xcode
        ]
        
        case coreSimulator = "/Library/Developer/CoreSimulator/"
        case preboot = "/private/preboot"
        case systemCoreServices = "/System/Library/CoreServices"
        case systemFrameworks = "/System/Library/Frameworks"
        case systemPrivateFrameworks = "/System/Library/PrivateFrameworks"
        case userLibraries = "/usr/lib"
        case xcode = "/Applications/Xcode.app"
        
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
