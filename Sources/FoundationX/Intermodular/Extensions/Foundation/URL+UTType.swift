//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow
import System
import UniformTypeIdentifiers

extension URL {
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func _detectPreferredMIMEType() -> String? {
        guard let _fileExtension else {
            return "application/octet-stream"
        }
        
        if FileManager.default.fileExists(at: self) {
            if let fileType = _MediaAssetFileType.allCases.first(where: { $0.fileExtension == _fileExtension }) {
                do {
                    _ = fileType
                    
                    if let fileTypeFromData = try _MediaAssetFileType(Data(contentsOf: self)) {
                        return fileTypeFromData.mimeType
                    }
                } catch {
                    // ignore the error
                }
            }
        }
        
        if let uti = UTType(filenameExtension: pathExtension) {
            if let mimeType = uti.preferredMIMEType {
                return mimeType
            }
        }
        
        guard isFileURL else {
            guard let mimeType = UTType(filenameExtension: pathExtension.lowercased())?.preferredMIMEType else {
                return "application/octet-stream"
            }
            
            return mimeType
        }
        
        do {
            let resourceValues = try self.resourceValues(forKeys: [.typeIdentifierKey])
            if let typeIdentifier = resourceValues.typeIdentifier {
                if let uti = UTType(typeIdentifier) {
                    if let mimeType = uti.preferredMIMEType {
                        return mimeType
                    }
                }
            }
        } catch {
            print("Error retrieving MIME type: \(error)")
        }
        
        return nil
    }
}
