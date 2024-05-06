//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct _ApplicationInfoPlist {
    public struct UTI: Encodable {
        public enum CodingKeys: String, CodingKey {
            case identifier = "UTTypeIdentifier"
            case description = "UTTypeDescription"
            case conformsTo = "UTTypeConformsTo"
            case iconFile = "UTTypeIconFile"
            case iconFiles = "UTTypeIconFiles"
            case referenceURL = "UTTypeReferenceURL"
            case tagSpecification = "UTTypeTagSpecification"
        }
        
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
}
