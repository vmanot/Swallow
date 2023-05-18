//
// Copyright (c) Vatsal Manot
//

import Swift

public enum PassthroughLoggerScope: Hashable {
    case root
    
    indirect case child(parent: Self, scope: AnyLogScope)
}
