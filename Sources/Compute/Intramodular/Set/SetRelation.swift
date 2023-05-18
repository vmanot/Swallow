//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol SetRelation {
    
}

public protocol Injective: SetRelation {
    
}

public protocol NonInjective: SetRelation {
    
}

public protocol Surjective: SetRelation {
    
}

public protocol NonSurjective: SetRelation {
    
}

/// A perfect one-to-one correspondence.
public protocol Bijective: Injective, Surjective {
    
}

public protocol InjectiveOnly: Injective, NonSurjective {
    
}
