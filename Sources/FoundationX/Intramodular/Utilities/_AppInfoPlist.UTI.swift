//
// Copyright (c) Vatsal Manot
//

import Swallow
import UniformTypeIdentifiers

extension _AppInfoPlist {
    public struct UTI {
        public var identifier: String
        public var description: String
        public var conformsTo: [String]
        public var iconFile: URL?
        public var iconFiles: [URL]?
        public var referenceURL: URL?
        public var extensions: [String]
        public var mimeTypes: [String]
        
        public init(
            identifier: String,
            description: String,
            conformsTo: [String],
            extensions: [String],
            mimeTypes: [String]
        ) {
            self.identifier = identifier
            self.description = description
            self.conformsTo = conformsTo
            self.extensions = extensions
            self.mimeTypes = mimeTypes
        }
        
        public init(
            identifier: String,
            description: String,
            conformsTo: [String],
            iconFile: URL?,
            iconFiles: [URL]?,
            referenceURL: URL?,
            extensions: [String],
            mimeTypes: [String]
        ) {
            self.identifier = identifier
            self.description = description
            self.conformsTo = conformsTo
            self.iconFile = iconFile
            self.iconFiles = iconFiles
            self.referenceURL = referenceURL
            self.extensions = extensions
            self.mimeTypes = mimeTypes
        }
    }
}

extension _AppInfoPlist.UTI: Encodable {
    public enum CodingKeys: String, CodingKey {
        case identifier = "UTTypeIdentifier"
        case description = "UTTypeDescription"
        case conformsTo = "UTTypeConformsTo"
        case iconFile = "UTTypeIconFile"
        case iconFiles = "UTTypeIconFiles"
        case referenceURL = "UTTypeReferenceURL"
        case tagSpecification = "UTTypeTagSpecification"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(description, forKey: .description)
        try container.encode(conformsTo, forKey: .conformsTo)
        
        if let iconFile = iconFile {
            try container.encode(iconFile.absoluteString, forKey: .iconFile)
        }
        
        if let iconFiles = iconFiles {
            try container.encode(iconFiles.map { $0.absoluteString }, forKey: .iconFiles)
        }
        
        if let referenceURL = referenceURL {
            try container.encode(referenceURL.absoluteString, forKey: .referenceURL)
        }
        
        var tagSpecification = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .tagSpecification)
        try tagSpecification.encode(extensions, forKey: AnyCodingKey(stringValue: "public.filename-extension"))
        try tagSpecification.encode(mimeTypes, forKey: AnyCodingKey(stringValue: "public.mime-type"))
    }
}

extension _AppInfoPlist.UTI {
    public static func fileType(
        identifierPrefix: String,
        fileExtension: String,
        mimeType: String
    ) -> Self {
        let identifierPrefix = identifierPrefix.dropSuffixIfPresent(".")
        let identifier = "\(identifierPrefix).\(fileExtension)"
        let description = "\(fileExtension.uppercased()) File"
        let conformsTo = ["public.data"]
        
        return Self(
            identifier: identifier,
            description: description,
            conformsTo: conformsTo,
            extensions: [fileExtension],
            mimeTypes: [mimeType]
        )
    }
    
    public static func folderType(
        identifierPrefix: String,
        fileExtension: String
    ) -> Self {
        let identifierPrefix = identifierPrefix.dropSuffixIfPresent(".")
        let identifier = "\(identifierPrefix).\(fileExtension).package"
        let description = "\(fileExtension.uppercased()) Package"
        let conformsTo: [String] = [
            "public.data",
            "public.folder",
            "com.apple.package"
        ]
        
        return Self(
            identifier: identifier,
            description: description,
            conformsTo: conformsTo,
            extensions: [fileExtension],
            mimeTypes: []
        )
    }
    
    public static func complexFileType(
        identifierPrefix: String,
        extensions: [String],
        mimeTypes: [String],
        description: String
    ) -> Self {
        let baseIdentifier = "\(identifierPrefix).\(description.replacingOccurrences(of: " ", with: "").lowercased())"
        let identifier = "\(baseIdentifier).\(extensions.first!)"
        let conformsTo = ["public.data"]
        
        return Self(
            identifier: identifier,
            description: "\(description) - \(extensions.first!.uppercased()) File",
            conformsTo: conformsTo,
            extensions: extensions,
            mimeTypes: mimeTypes
        )
    }
}

extension Array where Element == _AppInfoPlist.UTI {
    /// Generates a list of DocumentType entries from a list of UTIs, assuming the role of 'Editor' and a default handler rank.
    public func generateDocumentTypes(
        handlerRank: _AppInfoPlist.CFBundleDocumentTypes.DocumentType.HandlerRank = .owner
    ) -> [_AppInfoPlist.CFBundleDocumentTypes.DocumentType] {
        return self.map { uti in
            _AppInfoPlist.CFBundleDocumentTypes.DocumentType(
                contentTypes: [uti.identifier],
                extensions: uti.extensions,
                role: "Editor",
                handlerRank: .owner,
                isPackage: uti.conformsTo.contains("com.apple.package"),
                iconFiles: uti.iconFiles?.map { $0.absoluteString }
            )
        }
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension UTType {
    public init(from uti: _AppInfoPlist.UTI) throws {
        self = try Self(uti.identifier).unwrap()
    }
}
