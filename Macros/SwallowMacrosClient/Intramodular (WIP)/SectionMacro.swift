//
// Copyright (c) Vatsal Manot
//

@_exported import Swallow

@freestanding(declaration, names: arbitrary)
public macro codesection(_: () -> Void) = #externalMacro(
    module: "SwallowMacros",
    type: "SectionMacro"
)

/*public struct Foo {
    #codesection("section f") {
        let foo: Int
    }
    
    #codesection("some section") {
        #codesection("some section") {
            
        }
        
        struct Baz {
            let baz: Int
        }
    }
}
*/

/*func bar() {
    Foo(foo: 10)
    Foo.foo_Baz(baz: 0)
}
*/
