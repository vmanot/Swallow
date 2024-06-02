//
// Copyright (c) Vatsal Manot
//

import Swift

extension _StaticSwift {
    /// A namespace that statically represents Swift modules.
    public enum SwiftModule: _StaticSwift.Namespace {
        /// A namespace that statically represents Swift module names.
        public enum Name: _StaticSwift.Namespace {
            
        }
    }
    
    public protocol module: Hashable {
        
    }
}

extension _StaticSwift.SwiftModule.Name {
    public enum SwiftUI: Hashable {
        
    }
}
