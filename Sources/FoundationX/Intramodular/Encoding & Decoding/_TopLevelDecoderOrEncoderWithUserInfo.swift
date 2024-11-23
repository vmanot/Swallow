//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _TopLevelDecoderOrEncoderWithUserInfo {
    var userInfo: [CodingUserInfoKey: Any] { get set }
}

// MARK: - Conformees

extension JSONDecoder: _TopLevelDecoderOrEncoderWithUserInfo {
    
}

extension JSONEncoder: _TopLevelDecoderOrEncoderWithUserInfo {
    
}

extension PropertyListDecoder: _TopLevelDecoderOrEncoderWithUserInfo {
    
}

extension PropertyListEncoder: _TopLevelDecoderOrEncoderWithUserInfo {
    
}
