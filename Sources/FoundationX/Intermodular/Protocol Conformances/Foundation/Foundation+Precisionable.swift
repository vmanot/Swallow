//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Date: Precisionable {
    public struct Precision: Initiable, Codable {
        public var components: [Calendar.Component] = []
        
        public init() {
            
        }
    }
}
