//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow


@freestanding(declaration)
public macro scope<Scope: _StaticSwift.DeclarationScopeType, Void>(
    _ scope: Scope,
    _: () -> Void
) = #externalMacro(
    module: "SwallowMacros",
    type: "DeclarationScopeMacro"
)


/*struct MyViewContainer {
    var behaviors: some SetOfRuntimeBehaviors {
        ActiveCondition {
            SomeProjection(FileStorageOptions.self).commitStrategy != .immediate
        }
    }
}

// module A
struct MyViewA: View {
    @ConceptuallyIsolatedButRuntimeAwareOfProvenanceBinding var keyPathOfFileStorageBackedThing: Foo
    
    var body: some View {
        TextField($keyPathOfFileStorageBackedThing.someTextProperty)
    }
    
    @Required var foo: MyListOfThings
    
    var behaviors: some SetOfRuntimeBehaviors {
        Active {
            Conditions {
                SomeProjection(FileStorageOptions.self).commitStrategy == .immediate
            }
            
            Mutations {
                Mutate {
                    if $0.someArray.isEmpty {
                        $0.someArray.append(PlaceholderElement())
                    }
                }
                Where(MyListOfThings.someArray.isEmpty) {
                    
                    
                    Mutate {
                        Append(MyListOfThings.someArray, PlaceholderElement())
                    }
                }
            }
        }
    }
}

// mobule B
struct MyViewB: View {
    @ConceptuallyIsolatedButRuntimeAwareOfProvenanceBinding var keyPathOfFileStorageBackedThing: Foo
    
    var body: some View {
        TextField($keyPathOfFileStorageBackedThing.someTextProperty)
        
        Placeholder {
            TitleSubtitleCellData(title: , subittle: )
        }
    }
    
    static var behaviors: some SetOfRuntimeBehaviors {
        ActiveCondition {
            NetworkAPIOptions.$someOption
            #Project<NetworkAPIOptions>.someOption == .someOtherOption
        }
    }
}

macro Project<T>() = #externalMacro(module: "A", type: "B")



extension FileStorage {
    struct RuntimeConfigurableSettingsOrFlags: Projectable {
        @Entry var autocommitStrategy: AutocommitStrategy
    }
}


dothing1()
dothing2()
dothing3()


undothign1()
undothing2()
undothing3()


struct RefreshXcodeAutomation: TaskGraph {
    var body: some TaskGraph {
        While {
            ...
        } ensure: {
            Where {
                Process.name == "com.apple.dt.Xcode.SourceControlSevice"
            } {
                Process.isSuspended == true
            }
        }
    }
}

struct ProcessIsSuspendedEnforcement {
    @Subject var aProcess: Process
    
    var body: some Thing {
        For($aProcess.isSuspended) {
            Take($aProcess) {
                Enter {
                    aProcess.suspend()
                }
                
                Exit {
                    aProcess.unsuspend()
                }
            }
        }
    }
}
*/
/*#scope(.SwiftUI) {
    struct Foo {
        
    }
}

#unscoped {
    struct BuildIntent {
        @Parameter foo: Bool = false
    }
}

#scope(.Xcode) {
    @refine(BuildIntent.self)
    // @dynamicMemberLookup
    struct Intent {
        func run() {
            if self.foo {
                
            }
        }
        
        // subscript(dynamicMember:) { get
    }
}
/// expands to
extension DeclarationScoped where Scope == .Xcode {
    typealias BuildIntent = uniquename.Intent
}

extension DeclarationScoped where Scope: ConjunctionScope, Scope.LHS == .Xcode {
    typealias BuildIntent = uniquename.Intent
}

extension DeclarationScoped where Scope: ConjunctionScope, Scope.RHS == .Xcode {
    typealias BuildIntent = uniquename.Intent
}

#scope(.SwiftUI --> .Xcode) {
    
}

#usescope(.SwiftUI -> .Xcode)
class SwiftUIAndXcodeConcernedThing {
    typealias
}

extension _StaticSwift.DeclarationScopeType where Self == _StaticSwift.DeclarationScopeOf<_StaticSwift.SwiftModule.Name.SwiftUI> {
    public static var SwiftUI: Self {
        Self()
    }
}

extension _StaticSwift.DeclarationScopeType where Self == _StaticSwift.DeclarationScopeOf<_StaticSwift.SwiftModule.Name.Xcode> {
    public static var Xcode: Self {
        Self()
    }
}
*/

/*@contextual({
 Disallow {
 WithinTypeConformingTo(View.self)
 }
 })
 struct ShouldNotBeUsedInUICode: Hashable {
 @_contextualchecking // expanded from @contextual
 init(context: SourceContext = #sourceContextDefaultArgMacro) {
 _context_validate(context)
 }
 }
 
 @contextual struct MyView: View {
 @_contextualchecking // expanded from @contextual
 var body: some View {
 Text("fuck you")
 .id(ShouldNotBeUsedInUICode())
 }
 }
 
 
 
 @context(SomeCodableStructure) {
 struct AdditionalParameters {
 let foo: Int
 let bar: Int
 }
 }
 
 @contextual func HelloWorld(x: Int) {
 
 }
 
 @context(.HelloWorld) struct KabirsLaptop {
 static let somePasswordStoredAsAStringLiteral = ""
 
 var pattern: some Pattern {
 Subject(WorkspaceDirectory()) {
 ContainsFile {
 Name("password.txt")
 Equality {
 FileContents()
 Literal(self.somePasswordStoredAsAStringLiteral))
 }
 }
 }
 }
 
 func callAsFunction(_ args: [Any]) {
 print("Hello world, I'm running on Kabir's computer")
 }
 }
 
 @context struct VatsalsLaptop {
 
 }
 
 Where(.paragraph) {
 ContainedIn("yapping about Supercharge") {
 PrecededBy("Vatsal being a bitch") {
 
 }
 
 Scope(.sentence) {
 Conjunction {
 Repeating(minCount: 5) {
 Tone("Bragging")
 }
 
 Tone("Humility")
 }
 }
 }
 }
 
 
 
 struct CellPattern: View {
 var body: some ViewPattern {
 DesignSystem("HIG") {
 ContainedIn(TabView.self) {
 Where {
 StateContains {
 Declaration {
 VariableNamePattern("title", *)
 }
 
 Declaration {
 VariableNamePattern("subtitle", *)
 }
 }
 }
 
 Adjacent {
 
 }
 }
 }
 }
 }
 
 @FileDocument
 struct SomeExpensiveFileDocument {
 var title: String = ""
 var extremelyExpensiveDictionary: [String: Data] = [:]
 }
 
 @SomeOverseeingMacro
 class Foo {
 //@SomeMacro
 func foo(_ x: SomeExpensiveFileDocument) async throws {
 bar(x)
 baz(x)
 }
 
 func $_foo_incremental(@InputPW x: SomeExpensiveFileDocument) async throws {
 
 }
 
 // ..
 
 //@SomeMacro
 func bar(_ x: String) -> Int {
 
 }
 
 func $_bar_incremental(@InputPW x: String) -> Incremental<Int> {
 
 }
 
 //@SomeMacro
 func baz(_ y: Data) -> Int {
 
 }
 
 
 func $_baz_incremental(@InputPW x: Data) -> Incremental<Int> {
 
 }
 }*/
