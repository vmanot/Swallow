//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension NSItemProvider {
    public func hasItemConformingToTypeIdentifier(_ typeIdentifier: UTType) -> Bool {
        hasItemConformingToTypeIdentifier(typeIdentifier.identifier)
    }
    
    public func loadItem(
        for type: UTType,
        options: [AnyHashable: Any]? = nil
    ) async throws -> NSSecureCoding {
        try await withUnsafeThrowingContinuation { continuation in
            self.loadItem(forTypeIdentifier: type.identifier, options: options) { item, error in
                if let item = item {
                    continuation.resume(with: .success(item))
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public final func loadObject<T: _ObjectiveCBridgeable>(
        ofClass aClass: T.Type,
        completionHandler: @escaping (T?, Error?) -> Void
    ) -> Future<T, Error> {
        .init { attemptToFulfill in
            _ = self.loadObject(ofClass: T.self) { item, error in
                attemptToFulfill(Result(item, error: error)!)
            }
        }
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension NSItemProvider {
    public func loadURL(relativeTo url: URL?) async throws -> URL {
        let item = try await loadItem(for: .url)
        
        return try URL(dataRepresentation: cast(item, to: Data.self), relativeTo: url).unwrap()
    }
    
    public func loadURL() async throws -> URL {
        try await loadURL(relativeTo: nil)
    }
    
    public func loadFileURL(relativeTo url: URL?) async throws -> URL {
        let item = try await loadItem(for: .fileURL)
        
        return try URL(dataRepresentation: cast(item, to: Data.self), relativeTo: url).unwrap()
    }
    
    public func loadFileURL() async throws -> URL {
        try await loadFileURL(relativeTo: nil)
    }
    
    public func loadPlaintext() async throws -> String {
        if hasItemConformingToTypeIdentifier(UTType.plainText) {
            let item = try await loadItem(forTypeIdentifier: UTType.plainText.identifier)
            
            if let item = item as? Data {
                return try item.toString()
            } else {
                return try cast(item, to: String.self)
            }
        } else if hasItemConformingToTypeIdentifier(UTType.rtf.identifier) {
            #if os(macOS)
            let item = try! await cast(loadItem(forTypeIdentifier: UTType.rtf.identifier), to: Data.self)
            
            return try NSAttributedString(rtf: item, documentAttributes: nil).unwrap().string
            #else
            throw Never.Reason.unavailable
            #endif
        } else {
            throw Never.Reason.unavailable
        }
    }
    
    public func loadURLs(
        supportedSchemes: Set<String> = ["http", "https"]
    ) async throws -> [URL] {
        do {
            let url = try await loadURL()
            
            if let scheme = url.scheme, supportedSchemes.contains(scheme) {
                return [url]
            } else {
                return []
            }
        } catch {
            return try await [loadPlaintext()]
                .compactMap {
                    URL(string: $0)
                }
                .filter { (url: URL) in
                    guard let scheme = url.scheme else {
                        return false
                    }
                    
                    return supportedSchemes.contains(scheme)
                }
        }
    }
}

extension Foundation.NSItemProvider: @unchecked Swift.Sendable {
    
}
