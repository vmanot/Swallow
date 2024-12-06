//
// Copyright (c) Vatsal Manot
//

import UniformTypeIdentifiers
import Swift

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension UTType {
    public static let dylib = UTType("com.apple.mach-o-dylib")!
    public static let webInternetLocation = UTType("com.apple.web-internet-location")!
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension UTType {
    public init?(from url: URL) {
        if
            FileManager.default.fileExists(atPath: url.path),
            let type = try? url.resourceValues(forKeys: [.typeIdentifierKey]).contentType
        {
            self = type
        } else if let type = UTType(filenameExtension: url.pathExtension) {
            self = type
        } else {
            return nil
        }
    }
}
