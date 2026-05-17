//
// Copyright (c) Vatsal Manot
//

/*
 `_ErrorXModule` Macro Implementation Notes
 =========================================

 These notes record Swift macro behavior observed while implementing the WIP
 `@ErrorModel` authoring surface. Keep this close to the implementation because
 Swift macro expansion behavior is still underdocumented and easy to misread.

 Observed toolchain:

 - swift-driver version: 1.148.6
 - Apple Swift version 6.3.1 (swiftlang-6.3.1.1.2 clang-2100.0.123.102)
 - Target: arm64-apple-macosx15.0
 - Xcode: 26.4.1
 - Xcode build: 17E202

 Attached Extension Ordering
 ---------------------------

 `@ErrorModel` generates both members and an extension conformance. In this
 toolchain, generated members are type-checked in a way that cannot rely on the
 generated extension conformance already satisfying generic constraints.

 This failed when the generated member used:

     static var errorDescriptor: _ErrorDescriptor<Self>

 and `_ErrorDescriptor` was declared as:

     public struct _ErrorDescriptor<Failure: Error> { ... }

 for an enum that intentionally omitted `: Error` at the declaration site:

     @ErrorModel("com.example.notes")
     enum NoteError {
         @ErrorCase("note.empty_title")
         case emptyTitle
     }

 Even though the macro also generated an extension that made `NoteError` conform
 to `_ErrorX`/`Swift.Error`, the descriptor member still failed to type-check.

 The current workaround is deliberate:

     public struct _ErrorDescriptor<Failure> { ... }
     public struct _ErrorCaseDescriptor<Failure> { ... }

 The public `_ErrorDescribed` protocol still requires `Error`, so the semantic
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

 Relation macros such as `@ErrorTranslatedFrom` and `@ErrorPrimary` should
 preserve source order. Collecting them by a fixed macro-name list reorders the
 generated failure tree, which makes diagnostic output and tests feel arbitrary.
 Parse the case's attribute list in source order instead.
 */
