//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import UniformTypeIdentifiers

/// A uniform type identifier (UTI) for media assets.
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
        
    /// Determines the type of media based on the given data.
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
            
            return zip(numbers.indices, numbers).allSatisfy { (index: Int, number: UInt8?) in
                guard let number = number else {
                    return true
                }
                
                guard (index + offset) < data.count else {
                    return false
                }
                
                return data[index + offset] == number
            }
        }

        // Image formats
        if _match([0xFF, 0xD8, 0xFF]) { return .jpeg }
        if _match([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) { return .png }
        if _match([0x47, 0x49, 0x46]) { return .gif }
        if _match([0x52, 0x49, 0x46, 0x46, nil, nil, nil, nil, 0x57, 0x45, 0x42, 0x50]) { return .webp }
        if _match([0x49, 0x49, 0x2A, 0x00]) || _match([0x4D, 0x4D, 0x00, 0x2A]) { return .tiff }
        if _match([0x42, 0x4D]) { return .bmp }
        if _match([0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20]) { return .jpeg2000 }
        
        // Video formats
        if _match([0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D], offset: 4) { return .mp4 }
        if _match([0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32], offset: 4) ||
            _match([0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x56, 0x20], offset: 4) { return .m4v }
        if _match([0x66, 0x74, 0x79, 0x70, 0x71, 0x74, 0x20, 0x20], offset: 4) { return .mov }
        
        // Audio formats
        if _match([0x49, 0x44, 0x33]) { return .mp3 } // ID3v2 tag
        if _match([0xFF, 0xFB]) { return .mp3 } // MPEG frame sync
        if _match([0x4D, 0x34, 0x41]) { return .m4a }
        if _match([0x52, 0x49, 0x46, 0x46]) && _match([0x57, 0x41, 0x56, 0x45], offset: 8) { return .wav }
        if _match([0x4F, 0x67, 0x67, 0x53]) { return .ogg }
        if _match([0x66, 0x4C, 0x61, 0x43]) { return .flac }
        
        return nil
    }
        
    private static func fromMIMEType(
        _ mimeType: String
    ) -> Self? {
        switch mimeType {
                // Image types
            case "image/png": return .png
            case "image/jpeg": return .jpeg
            case "image/gif": return .gif
            case "image/heic": return .heic
            case "image/webp": return .webp
            case "image/tiff": return .tiff
            case "image/bmp": return .bmp
            case "image/jp2": return .jpeg2000
                
                // Video types
            case "video/mp4": return .mp4
            case "video/x-m4v": return .m4v
            case "video/quicktime": return .mov
            case "video/avi": return .avi
            case "video/mpeg": return .mpeg
            case "video/x-matroska": return .mkv
                
                // Audio types
            case "audio/mpeg": return .mp3
            case "audio/mp4", "audio/x-m4a": return .m4a
            case "audio/wav": return .wav
            case "audio/ogg": return .ogg
            case "audio/flac": return .flac
            case "audio/aac": return .aac
                
            default: return nil
        }
    }
    
    private static func fromUTI(_ uti: String) -> Self {
        switch uti {
                // Generic
            case "public.data": return .generic
                
                // Image types
            case "public.png": return .png
            case "public.jpeg": return .jpeg
            case "com.compuserve.gif": return .gif
            case "public.heic": return .heic
            case "public.webp": return .webp
            case "public.tiff": return .tiff
            case "com.microsoft.bmp": return .bmp
            case "public.jpeg-2000": return .jpeg2000
                
                // Video types
            case "public.mpeg4": return .mp4
            case "public.m4v": return .m4v
            case "public.mov": return .mov
            case "public.avi": return .avi
            case "public.mpeg": return .mpeg
            case "org.matroska.mkv": return .mkv
                
                // Audio types
            case "public.mp3": return .mp3
            case "public.m4a-audio": return .m4a
            case "com.microsoft.waveform-audio": return .wav
            case "org.xiph.ogg": return .ogg
            case "org.xiph.flac": return .flac
            case "public.aac-audio": return .aac
                
            default:
                if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *),
                   let utType = UTType(uti) {
                    return Self(uti: uti, mimeType: utType.preferredMIMEType ?? "application/octet-stream")
                }
                return Self(uti: uti, mimeType: "application/octet-stream")
        }
    }
}

extension _MediaAssetFileType {
    public static let generic = Self(uti: "public.data", mimeType: "application/octet-stream")
    
    // Image types
    public static let png = Self(uti: "public.png", mimeType: "image/png")
    public static let jpeg = Self(uti: "public.jpeg", mimeType: "image/jpeg")
    public static let gif = Self(uti: "com.compuserve.gif", mimeType: "image/gif")
    public static let heic = Self(uti: "public.heic", mimeType: "image/heic")
    public static let webp = Self(uti: "public.webp", mimeType: "image/webp")
    public static let tiff = Self(uti: "public.tiff", mimeType: "image/tiff")
    public static let bmp = Self(uti: "com.microsoft.bmp", mimeType: "image/bmp")
    public static let jpeg2000 = Self(uti: "public.jpeg-2000", mimeType: "image/jp2")
    
    // Video types
    public static let mp4 = Self(uti: "public.mpeg4", mimeType: "video/mp4")
    public static let m4v = Self(uti: "public.m4v", mimeType: "video/x-m4v")
    public static let mov = Self(uti: "public.mov", mimeType: "video/quicktime")
    public static let avi = Self(uti: "public.avi", mimeType: "video/avi")
    public static let mpeg = Self(uti: "public.mpeg", mimeType: "video/mpeg")
    public static let mkv = Self(uti: "org.matroska.mkv", mimeType: "video/x-matroska")
    
    // Audio types
    public static let mp3 = Self(uti: "public.mp3", mimeType: "audio/mpeg")
    public static let m4a = Self(uti: "public.m4a-audio", mimeType: "audio/mp4")
    public static let wav = Self(uti: "com.microsoft.waveform-audio", mimeType: "audio/wav")
    public static let ogg = Self(uti: "org.xiph.ogg", mimeType: "audio/ogg")
    public static let flac = Self(uti: "org.xiph.flac", mimeType: "audio/flac")
    public static let aac = Self(uti: "public.aac-audio", mimeType: "audio/aac")
}

// MARK: - Conformances

extension _MediaAssetFileType: CaseIterable {
    public static var allCases: [Self] {
        [
            // Image types
            .png, .jpeg, .gif, .heic, .webp, .tiff, .bmp, .jpeg2000,
            // Video types
            .mp4, .m4v, .mov, .avi, .mpeg, .mkv,
            // Audio types
            .mp3, .m4a, .wav, .ogg, .flac, .aac
        ]
    }
}

extension _MediaAssetFileType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

// MARK: - Auxiliary

extension _MediaAssetFileType {
    /// Returns true if this type represents an image format
    public var isImage: Bool {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            return utType.conforms(to: .image)
        }
        return mimeType.starts(with: "image/")
    }
    
    /// Returns true if this type represents a video format
    public var isVideo: Bool {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            return utType.conforms(to: .video)
        }
        return mimeType.starts(with: "video/")
    }
    
    /// Returns true if this type represents an audio format
    public var isAudio: Bool {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            return utType.conforms(to: .audio)
        }
        return mimeType.starts(with: "audio/")
    }
}
