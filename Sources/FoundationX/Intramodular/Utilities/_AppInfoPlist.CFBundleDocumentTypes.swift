//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension _AppInfoPlist {
    public struct CFBundleDocumentTypes: Encodable {
        public var documentTypes: [DocumentType]
                        
        public struct DocumentType: Encodable, Hashable {
            public enum HandlerRank: String, Encodable, Hashable {
                case owner = "Owner"
                case alternate = "Alternate"
                case none = "None"
            }
            
            var contentTypes: [String]
            var extensions: [String]
            var role: String
            var handlerRank: HandlerRank
            var isPackage: Bool
            var iconFiles: [String]?
            
            enum CodingKeys: String, CodingKey {
                case contentTypes = "LSItemContentTypes"
                case extensions = "CFBundleTypeExtensions"
                case role = "CFBundleTypeRole"
                case handlerRank = "LSHandlerRank"
                case isPackage = "LSTypeIsPackage"
                case iconFiles = "CFBundleTypeIconFiles"
            }
        }
    }
}

extension _AppInfoPlist.CFBundleDocumentTypes {
    public enum CodingKeys: String, CodingKey {
        case documentTypes = "CFBundleDocumentTypes"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(documentTypes, forKey: .documentTypes)
    }
}
