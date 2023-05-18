//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension String {
    public subscript(range: NSRange) -> Substring {
        guard let range = Range(range, in: self) else {
            fatalError("Invalid range \(range)")
        }
        
        return self[range]
    }
}
