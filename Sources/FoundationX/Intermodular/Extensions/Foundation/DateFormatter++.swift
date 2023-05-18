//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension DateFormatter {
    public convenience init(dateFormat: String) {
        self.init()
        
        self.dateFormat = dateFormat
    }
    
    public convenience init(dateFormatTemplate: String) {
        self.init()
        
        self.setLocalizedDateFormatFromTemplate(dateFormatTemplate)
    }
}
