//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension LocalizedStringResource {
    public func _toNSLocalizedString() throws -> String {
        return NSLocalizedString(
            key,
            tableName: table,
            bundle: try _resolveBundle().unwrap(),
            comment: ""
        )
    }
    
    private func _resolveBundle() throws -> Bundle? {
        switch bundle {
            case .main:
                return Bundle.main
            case .forClass(let type):
                return Bundle(for: type)
            case .atURL(let url):
                return Bundle(url: url)
            @unknown default:
                assertionFailure()
                
                return nil
        }
    }
}
