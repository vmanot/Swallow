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
    public var _preferredMIMEType: String? {
        if !_fileExtension.isEmpty, FileManager.default.fileExists(at: self) {
            if let fileType = _MediaAssetFileType.allCases.first(where: { $0.fileExtension == _fileExtension }) {
                do {
                    _ = fileType
                     
                    if let fileTypeFromData = try _MediaAssetFileType(Data(contentsOf: self)), UTType(fileTypeFromData.rawValue) != nil {
                        return fileTypeFromData.rawValue
                    }
                } catch {
                    // ignore the error
                }
            }
        }
        
        if let pathExtension = self.pathExtension.isEmpty ? nil : self.pathExtension {
            if let uti = UTType(filenameExtension: pathExtension) {
                if let mimeType = uti.preferredMIMEType {
                    return mimeType
                }
            }
        }
        
        guard isFileURL else {
            guard !pathExtension.isEmpty else {
                return "application/octet-stream"
            }
            
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
