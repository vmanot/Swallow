//
// Copyright (c) Vatsal Manot
//

import FoundationX
import MachO
import ObjectiveC
import Swallow

extension DynamicLinkEditor {
    static var _imageCount: UInt32 {
        _dyld_image_count()
    }

    public struct Image: Hashable, Identifiable, @unchecked Sendable, URLInitiable {
        public struct Index: RawRepresentable, Hashable, Comparable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.rawValue < rhs.rawValue
            }
        }

        public typealias ID = URL

        public var isValid: Bool {
            index.rawValue < DynamicLinkEditor._imageCount
                && _dyld_get_image_header(index.rawValue) == rawHeader
        }

        public let index: Index
        public let fileURL: URL
        public let header: MachOFormat.Header
        public let slide: MachOFormat.VirtualMemorySlide

        public var id: ID {
            fileURL
        }

        public init?(index: Index) {
            guard index.rawValue < DynamicLinkEditor._imageCount,
                  let imageName = _dyld_get_image_name(index.rawValue),
                  let rawHeader = _dyld_get_image_header(index.rawValue),
                  let header = try? MachOFormat.Header(rawHeader)
            else {
                return nil
            }

            self.index = index
            self.fileURL = URL(fileURLWithPath: String(cString: imageName))
            self.header = header
            self.slide = MachOFormat.VirtualMemorySlide(
                rawValue: _dyld_get_image_vmaddr_slide(index.rawValue)
            )
        }

        @_transparent
        public init?<Value: BinaryInteger>(index: Value) {
            guard let rawValue = UInt32(exactly: index) else {
                return nil
            }

            self.init(index: Index(rawValue: rawValue))
        }

        public init?(url: URL) {
            let resolvedURL = url.standardizedFileURL.resolvingSymlinksInPath()
            guard let image = Self.allCases.first(where: {
                $0.fileURL.standardizedFileURL.resolvingSymlinksInPath() == resolvedURL
            }) else {
                return nil
            }

            self = image
        }

        var rawHeader: UnsafePointer<mach_header> {
            header.baseAddress.assumingMemoryBound(to: mach_header.self)
        }
    }
}

extension DynamicLinkEditor.Image: CaseIterable {
    /// The images currently loaded in this process. This is intentionally not cached;
    /// dyld can add images after the first query.
    public static var allCases: [Self] {
        (0..<DynamicLinkEditor._imageCount).compactMap { index in
            Self(index: Index(rawValue: index))
        }
    }
}

extension DynamicLinkEditor.Image: CustomStringConvertible {
    public var description: String {
        fileURL.path
    }
}

// MARK: - Image filtering

extension DynamicLinkEditor.Image {
    public enum _ImagePathFilter: String, CaseIterable {
        static let appleFramework: Set<Self> = [
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
            URL(fileURLWithPath: rawValue, isDirectory: true).isAncestor(of: image.fileURL)
        }
    }

    func _matches(_ filter: _ImagePathFilter) -> Bool {
        filter.matches(self)
    }

    @_transparent
    func _matches(_ filters: Set<_ImagePathFilter>) -> Bool {
        filters.contains { $0.matches(self) }
    }
}

// MARK: - Objective-C images

extension DynamicLinkEditor.Image {
    public var allObjCTypes: [ObjCClass] {
        ObjCClass.allCases(in: self)
    }
}

extension ObjCClass {
    public var dyldImage: DynamicLinkEditor.Image? {
        guard let imageName = class_getImageName(value) else {
            return nil
        }

        return DynamicLinkEditor.Image(
            url: URL(fileURLWithPath: String(cString: imageName))
        )
    }
}

extension ObjCClass {
    @_OSUnfairLocked
    private static var classesByImage: [DynamicLinkEditor.Image.ID: [ObjCClass]] = [:]

    public static func allCases(in image: DynamicLinkEditor.Image) -> [ObjCClass] {
        Self.$classesByImage.withCriticalScope { classesByImage in
            if let classes = classesByImage[image.id] {
                return classes
            }

            let classes = _allCases(in: image)
            classesByImage[image.id] = classes
            return classes
        }
    }

    private static func _allCases(in image: DynamicLinkEditor.Image) -> [ObjCClass] {
        var count: UInt32 = 0
        guard let classNames = objc_copyClassNamesForImage(
            image.fileURL.path,
            &count
        ) else {
            return []
        }
        defer { free(classNames) }

        return (0..<Int(count)).compactMap { index in
            (objc_getClass(classNames[index]) as? AnyClass).map(ObjCClass.init)
        }
    }
}

// MARK: - Load commands

extension DynamicLinkEditor.Image {
    public var loadCommands: MachOFormat.LoadCommands {
        get throws {
            try header.loadCommands()
        }
    }

    public var dependencies: [MachOFormat.DynamicLibrary] {
        get throws {
            try loadCommands.dynamicLibraries.filter { !$0.isIdentifier }
        }
    }

    public var dynamicLibraryInstallName: MachOFormat.DynamicLibrary.InstallName? {
        get throws {
            try loadCommands.dynamicLibraries.first { $0.isIdentifier }?.installName
        }
    }

    public func isLoaded(as installName: MachOFormat.DynamicLibrary.InstallName) throws -> Bool {
        if try dynamicLibraryInstallName == installName {
            return true
        }

        guard case .absolute(let installURL) = installName.reference else {
            return false
        }

        return fileURL.standardizedFileURL.resolvingSymlinksInPath()
            == installURL.standardizedFileURL.resolvingSymlinksInPath()
    }

    public func depends(on other: Self) throws -> Bool {
        return try dependencies.contains { dependency in
            try other.isLoaded(as: dependency.installName)
        }
    }

    /// Direct dependencies that are currently loaded into this process.
    public var loadedDependencies: Set<Self> {
        get throws {
            let loadedImages = Self.allCases
            return Set(try dependencies.compactMap { dependency in
                try loadedImages.first { try $0.isLoaded(as: dependency.installName) }
            })
        }
    }
}
