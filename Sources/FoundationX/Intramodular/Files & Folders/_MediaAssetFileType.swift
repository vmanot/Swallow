//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import UniformTypeIdentifiers

/// A uniform type identifier (UTI).
public struct _MediaAssetFileType: Hashable, Sendable {
    public let uti: String
    public let mimeType: String
    public let fileExtension: String?
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public var utType: UTType {
        UTType(uti)!
    }
    
    package init(uti: String, mimeType: String) {
        self.uti = uti
        self.mimeType = mimeType
        
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            self.fileExtension = UTType(uti)?.preferredFilenameExtension
        } else {
            assertionFailure()
            
            self.fileExtension = nil
        }
    }
    
    public init?(rawValue: String) {
        assert(!rawValue.isEmpty)
        
        if rawValue.contains("/") {
            guard let type = Self.fromMIMEType(rawValue) else {
                return nil
            }
            
            self = type
        } else {
            self = Self.fromUTI(rawValue)
        }
    }
    
    private static func fromMIMEType(_ mimeType: String) -> Self? {
        switch mimeType {
            case "image/png":
                return .png
            case "image/jpeg":
                return .jpeg
            case "image/gif":
                return .gif
            case "image/heic":
                return .heic
            case "image/webp":
                return .webp
            case "image/tiff":
                return .tiff
            case "image/bmp":
                return .bmp
            case "image/jp2":
                return .jpeg2000
            case "video/mp4":
                return .mp4
            case "video/x-m4v":
                return .m4v
            case "video/quicktime":
                return .mov
            default:
                return nil
        }
    }
    
    private static func fromUTI(_ uti: String) -> Self {
        switch uti {
            case "public.data":
                return .generic
            case "public.png":
                return .png
            case "public.jpeg":
                return .jpeg
            case "com.compuserve.gif":
                return .gif
            case "public.heic":
                return .heic
            case "public.webp":
                return .webp
            case "public.tiff":
                return .tiff
            case "com.microsoft.bmp":
                return .bmp
            case "public.jpeg-2000":
                return .jpeg2000
            case "public.mpeg4":
                return .mp4
            case "public.m4v":
                return .m4v
            case "public.mov":
                return .mov
            default:
                if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
                    if let utType = UTType(uti) {
                        return Self(uti: uti, mimeType: utType.preferredMIMEType ?? "application/octet-stream")
                    }
                }
                return Self(uti: uti, mimeType: "application/octet-stream")
        }
    }
}

extension _MediaAssetFileType {
    public static var generic: Self {
        Self(uti: "public.data", mimeType: "application/octet-stream")
    }
    
    /// Determines a type of the image based on the given data.
    public init?(_ data: Data) {
        guard let type = _MediaAssetFileType.make(data) else {
            return nil
        }
        
        self = type
    }
    
    private static func make(_ data: Data) -> Self? {
        func _match(_ numbers: [UInt8?], offset: Int = 0) -> Bool {
            guard data.count >= numbers.count else {
                return false
            }
            
            return zip(numbers.indices, numbers).allSatisfy { index, number in
                guard let number = number else { return true }
                guard (index + offset) < data.count else { return false }
                return data[index + offset] == number
            }
        }
        
        // JPEG magic numbers https://en.wikipedia.org/wiki/JPEG
        if _match([0xFF, 0xD8, 0xFF]) { return .jpeg }
        
        // PNG Magic numbers https://en.wikipedia.org/wiki/Portable_Network_Graphics
        if _match([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) { return .png }
        
        // GIF magic numbers https://en.wikipedia.org/wiki/GIF
        if _match([0x47, 0x49, 0x46]) { return .gif }
        
        // WebP magic numbers https://en.wikipedia.org/wiki/List_of_file_signatures
        if _match([0x52, 0x49, 0x46, 0x46, nil, nil, nil, nil, 0x57, 0x45, 0x42, 0x50]) { return .webp }
        
        // TIFF magic numbers (little endian) https://en.wikipedia.org/wiki/TIFF
        if _match([0x49, 0x49, 0x2A, 0x00]) { return .tiff }
        
        // TIFF magic numbers (big endian) https://en.wikipedia.org/wiki/TIFF
        if _match([0x4D, 0x4D, 0x00, 0x2A]) { return .tiff }
        
        // BMP magic numbers https://en.wikipedia.org/wiki/BMP_file_format
        if _match([0x42, 0x4D]) { return .bmp }
        
        // JPEG 2000 magic numbers https://en.wikipedia.org/wiki/JPEG_2000
        if _match([0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20, 0x0D, 0x0A, 0x87, 0x0A]) { return .jpeg2000 }
        
        // see https://stackoverflow.com/questions/21879981/avfoundation-avplayer-supported-formats-no-vob-or-mpg-containers
        // https://en.wikipedia.org/wiki/List_of_file_signatures
        if _match([0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D], offset: 4) { return .mp4 }
        
        // https://www.garykessler.net/library/file_sigs.html
        if _match([0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32], offset: 4) { return .m4v }
        
        if _match([0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x56, 0x20], offset: 4) { return .m4v }
        
        // MOV magic numbers https://www.garykessler.net/library/file_sigs.html
        if _match([0x66, 0x74, 0x79, 0x70, 0x71, 0x74, 0x20, 0x20], offset: 4) { return .mov }
        
        // Either not enough data, or we just don't support this format.
        return nil
    }
}

// MARK: - Conformances

extension _MediaAssetFileType: CaseIterable {
    public static let png = Self(uti: "public.png", mimeType: "image/png")
    public static let jpeg = Self(uti: "public.jpeg", mimeType: "image/jpeg")
    public static let gif = Self(uti: "com.compuserve.gif", mimeType: "image/gif")
    public static let heic = Self(uti: "public.heic", mimeType: "image/heic")
    public static let webp = Self(uti: "public.webp", mimeType: "image/webp")
    public static let tiff = Self(uti: "public.tiff", mimeType: "image/tiff")
    public static let bmp = Self(uti: "com.microsoft.bmp", mimeType: "image/bmp")
    public static let jpeg2000 = Self(uti: "public.jpeg-2000", mimeType: "image/jp2")
    public static let mp4 = Self(uti: "public.mpeg4", mimeType: "video/mp4")
    public static let m4v = Self(uti: "public.m4v", mimeType: "video/x-m4v")
    public static let mov = Self(uti: "public.mov", mimeType: "video/quicktime")
    
    public static var allCases: [Self] {
        [.png, .jpeg, .gif, .heic, .webp, .tiff, .bmp, .jpeg2000, .mp4, .m4v, .mov]
    }
}

extension _MediaAssetFileType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}
