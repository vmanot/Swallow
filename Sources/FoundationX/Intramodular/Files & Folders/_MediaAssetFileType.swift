//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift
import UniformTypeIdentifiers

/// A uniform type identifier (UTI).
struct _MediaAssetFileType: ExpressibleByStringLiteral, Hashable, Sendable {
    let rawValue: String
    let fileExtension: String?
    
    init(rawValue: String) {
        self.rawValue = rawValue
        
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            self.fileExtension = UTType(rawValue)?.preferredFilenameExtension
        } else {
            self.fileExtension = nil
        }
    }
    
    init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension _MediaAssetFileType {
    /// Determines a type of the image based on the given data.
    init?(_ data: Data) {
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
    static let png: Self = "public.png"
    static let jpeg: Self = "public.jpeg"
    static let gif: Self = "com.compuserve.gif"
    /// HEIF (High Efficiency Image Format) by Apple.
    static let heic: Self = "public.heic"
    
    /// WebP
    ///
    /// Native decoding support only available on the following platforms: macOS 11,
    /// iOS 14, watchOS 7, tvOS 14.
    static let webp: Self = "public.webp"
    
    static let mp4: Self = "public.mpeg4"
    
    /// The M4V file format is a video container format developed by Apple and
    /// is very similar to the MP4 format. The primary difference is that M4V
    /// files may optionally be protected by DRM copy protection.
    static let m4v: Self = "public.m4v"
    
    static let mov: Self = "public.mov"
    
    static var allCases: [Self] {
        [.png, .jpeg, .gif, .heic, .webp, .mp4, .m4v, .mov]
    }
}
