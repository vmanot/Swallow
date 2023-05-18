//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension PersonNameComponents {
    public init(
        firstName: String,
        middleName: String?,
        lastName: String
    ) {
        self.init()
        
        self.givenName = firstName
        self.middleName = middleName
        self.familyName = lastName
    }
}
