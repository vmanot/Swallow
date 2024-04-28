//
// Copyright (c) Vatsal Manot
//

import Foundation

extension NSError {
    public static func genericApplicationError(
        description: String,
        recoverySuggestion: String? = nil,
        domainPostfix: String? = nil
    ) -> Self {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? ""
        ]
        return .init(
            domain: domainPostfix.map { "\(Bundle.main.bundleIdentifier!) - \($0)" } ?? Bundle.main.bundleIdentifier!,
            code: 1,
            userInfo: userInfo
        )
    }
}
