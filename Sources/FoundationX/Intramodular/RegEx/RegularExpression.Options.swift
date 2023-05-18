//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension RegularExpression {
    public typealias Options = NSRegularExpression.Options
}

// MARK: - API

extension RegularExpression {
    public func options(on onOptions: Options, off offOptions: Options) -> Self {
        guard !(onOptions.isEmpty && offOptions.isEmpty) else {
            return self
        }
        
        guard !offOptions.isEmpty else {
            return modifyPattern  {
                "(?\(onOptions.modifiers.map({ String($0) }).joined()))" + $0
            }
        }
        
        return modifyPattern {
            let onOptions = onOptions.modifiers.map({ String($0) }).joined()
            let offOptions = offOptions.modifiers.map({ String($0) }).joined()
            
            return "(?\(onOptions)-\(offOptions))" + $0
        }
        .nonCaptureGroup()
    }
    
    public func options(_ options: Options) -> Self {
        self.options(on: options, off: [])
    }
    
    public func disableOptions(_ options: Options) -> Self {
        self.options(on: [], off: options)
    }
}
