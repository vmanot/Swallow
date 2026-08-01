# ErrorX Macro Implementation Notes

These notes record Swift macro behavior observed while implementing the
`@ErrorModel` authoring surface. Keep this close to the implementation because
Swift macro expansion behavior is still underdocumented and easy to misread.

Observed toolchain:

- swift-driver version: 1.148.6
- Apple Swift version 6.3.1 (swiftlang-6.3.1.1.2 clang-2100.0.123.102)
- Target: arm64-apple-macosx15.0
- Xcode: 26.4.1
- Xcode build: 17E202
- SwiftSyntax binary release: 601.0.1 from `swift-precompiled/swift-syntax`

Package modes relevant to these observations:

- package tools version: 6.1
- package default language mode: Swift 5
- `ErrorX`: Swift 6
- `ErrorXMacros`: Swift 6
- `SwiftSyntaxUtilities`: Swift 5

`MemberMacro` Conformance-List Compatibility
--------------------------------------------

SwiftSyntax 601 invokes the `MemberMacro.expansion` overload carrying the
`conformingTo:` list advertised by an attached macro declaration. SwiftSyntax
600 used the earlier overload without that list. This is an API-version split,
not a Swift 5-versus-Swift 6 language-mode distinction.

`SwiftSyntaxUtilities._MemberMacroConformanceListCompatibility` centralizes
this adapter. Its `#if compiler(>=6.1)` intentionally mirrors the dependency
selection in `Package.swift`: this package selects the precompiled SwiftSyntax
601 release for a Swift 6.1-or-newer compiler and SwiftSyntax 600 otherwise.
Do not copy that compiler check into each macro implementation, and do not
infer the available callback from the target's `swiftLanguageMode`.

`ClosureCaptureSyntax` Construction Compatibility
-------------------------------------------------

SwiftSyntax 600 constructs a shorthand capture through an `expression:`
initializer. SwiftSyntax 601 exposes the capture's `name` and `initializer`
fields directly and no longer provides that source-compatible initializer.

`SwiftSyntaxUtilities.ClosureCaptureSyntax.init(capturing:)` is the stable
package-local spelling across both APIs. As with the member-macro adapter, its
compiler check mirrors the SwiftSyntax dependency selected by `Package.swift`;
it must not be guarded only at individual call sites.

Modifier Insertion And Trivia Ownership
---------------------------------------

In SwiftSyntax 601, declaration-leading trivia belongs to the first existing
modifier, or to the declaration keyword when no modifier exists. Inserting a
token into `DeclModifierListSyntax` alone does not transfer that trivia. A
modifierless declaration can therefore render as:

    public
    func callAsFunction() { ... }

`FunctionDeclSyntax.setExplicitAccessLevel(_:)` owns both the modifier list and
`func` token, so it transfers leading trivia when adding the first modifier and
preserves token separation when replacing malformed duplicate access modifiers.
When embedding a source declaration inside newly generated syntax, trim the
completed declaration before interpolation so its original outer indentation
does not become an extra blank line.

Attached Extension Ordering
---------------------------

`@ErrorModel` generates both members and an extension conformance. In this
toolchain, generated members are type-checked in a way that cannot rely on the
generated extension conformance already satisfying generic constraints.

This failed when the generated member used:

    static var _errorDescriptor: _ErrorDescriptor<Self>

and `_ErrorDescriptor` was declared as:

    public struct _ErrorDescriptor<Failure: Error> { ... }

for an enum that intentionally omitted `: Error` at the declaration site:

    @ErrorModel(domain: "com.example.notes")
    enum NoteError {
        @ErrorCode("note.empty_title")
        case emptyTitle
    }

Even though the macro also generated an extension that made `NoteError` conform
to `_ModeledError`/`Swift.Error`, the descriptor member still failed to type-check.

The current workaround is deliberate:

    public struct _ErrorDescriptor<Failure> { ... }

The public `_ModeledError` protocol still requires `Error`, so the semantic
model remains error-only. The descriptor storage itself avoids a generic
constraint because it is generated before the compiler can reliably use the
macro-generated conformance.

`Error` Versus `Swift.Error`
----------------------------

In nested contexts with generated extensions, checking whether an enum already
inherits `Error` needs to consider both spellings:

    enum A: Error { ... }
    enum B: Swift.Error { ... }

Macro-generated extensions should avoid adding `Swift.Error` when either
spelling is already present, otherwise Swift reports a redundant conformance.

Source Order For Peer Attributes
--------------------------------

Repeated `@ErrorRelation` attributes should preserve source order. Grouping
them by relation kind would reorder the
generated failure tree, which makes diagnostic output and tests feel arbitrary.
Parse the case's attribute list in source order instead.

Transitive Macro Dependency Invalidation
----------------------------------------

In this toolchain, changing only `SwiftSyntaxUtilities` rebuilt and relinked the
`ErrorXMacros` executable, but SwiftPM did not recompile unchanged source
files containing ErrorX macro applications. Their previously expanded source
remained in the incremental build. This was observable after changing escaped-
identifier normalization in `SwiftSyntaxUtilities`: direct utility tests used
the corrected value while an unchanged `@ErrorCodeCatalog` application retained
its old generated stable identifier.

Even a subsequent direct change to the macro implementation rebuilt the macro
executable without recompiling the unchanged client source. A clean package
build was required to force expansion again. When validating generated output,
do not treat an incremental test pass as sufficient after changing either a
macro implementation or one of its support-module dependencies.

This is an incremental-build observation, not a language semantic guarantee.
It was reproduced with the toolchain listed above in Swift 6 language mode for
`ErrorX` and `ErrorXMacros`; `SwiftSyntaxUtilities` itself is built
in Swift 5 language mode by this package manifest.
