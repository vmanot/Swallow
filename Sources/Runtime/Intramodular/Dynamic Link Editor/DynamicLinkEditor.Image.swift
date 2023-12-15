//
// Copyright (c) Vatsal Manot
//

import MachO
import Swift

extension DynamicLinkEditor {
    @frozen
    public struct Image: Hashable, Identifiable, Sendable {
        public let name: String
        public let header: UnsafePointer<mach_header>
        
        @_transparent
        public init(
            name: String,
            header: UnsafePointer<mach_header>
        ) {
            self.name = name
            self.header = header
        }
        
        public var id: some Hashable {
            name
        }
    }
}

extension DynamicLinkEditor.Image: CustomStringConvertible {
    public var description: String {
        name
    }
}

extension DynamicLinkEditor.Image {
    public enum _ImagePathFilter: String, CaseIterable {
        case preboot = "/private/preboot"
        case systemCoreServices = "/System/Library/CoreServices"
        case systemFrameworks = "/System/Library/Frameworks"
        case systemPrivateFrameworks = "/System/Library/PrivateFrameworks"
        case userLibraries = "/usr/lib"
        case xcode = "/Applications/Xcode.app"
    }
    
    @_transparent
    public static func allCases(
        ignoring filter: Set<_ImagePathFilter> = [
            .preboot,
            .systemFrameworks,
            .systemPrivateFrameworks,
            .userLibraries,
            .xcode
        ]
    ) -> [DynamicLinkEditor.Image] {
        let images = _dyld_image_count()
        
        var result: [DynamicLinkEditor.Image] = []
        
        for i in 0..<images {
            let name = String(cString: _dyld_get_image_name(i))
            
            guard !filter.contains(where: { name.hasPrefix($0.rawValue) }) else {
                continue
            }
            
            let header = _dyld_get_image_header(i)!
            
            let image = DynamicLinkEditor.Image(
                name: name,
                header: header
            )
            
            result.append(image)
        }
        
        return result
    }
}
