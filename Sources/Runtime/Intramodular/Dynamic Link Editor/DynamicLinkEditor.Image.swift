//
// Copyright (c) Vatsal Manot
//

import MachO
import ObjectiveC
import Swallow

#if !os(watchOS)
public typealias _mach_header_type = mach_header_64
#else
public typealias _mach_header_type = mach_header_64
#endif

extension DynamicLinkEditor {
    @frozen
    public struct Image: Hashable, Identifiable, @unchecked Sendable {
        public let index: UInt32
        public let name: String
        public let header: UnsafePointer<mach_header>
        
        @_transparent
        public init(
            index: UInt32,
            name: String,
            header: UnsafePointer<mach_header>
        ) {
            self.index = index
            self.name = name
            self.header = header
        }
        
        public var id: AnyHashable {
            name
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
        
        static var appleFramework: Set<_ImagePathFilter> {
            [
                .preboot,
                .systemFrameworks,
                .systemPrivateFrameworks,
                .userLibraries,
                .xcode
            ]
        }
        
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
        filters.contains(where: { $0.matches(self) })
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
