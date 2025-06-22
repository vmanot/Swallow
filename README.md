# Swallow

A complement to the Swift standard library. This framework contains a suite of essential protocols and types that are missing from the standard library, and attempts to maintain API parity with the latest Swift evolution trends.

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| **Swallow** | Library | Core utilities, collections, and property wrappers |
| **SwallowMacros** | Macro | Swift macro implementations |
| **SwallowMacrosClient** | Library | Client-side macro interface and runtime support |
| **MacroBuilder** | Library | Utilities for building custom macros |
| **SwiftSyntaxUtilities** | Library | Extensions and helpers for SwiftSyntax |
| **FoundationX** | Library | Foundation extensions and file management |
| **Compute** | Library | Data structures (trees, graphs, collections) |
| **Runtime** | Library | Type introspection and runtime manipulation |
| **Diagnostics** | Library | Logging, error handling, and debugging |
| **CoreModel** | Library | Persistent model abstractions |
| **POSIX** | Library | POSIX system interfaces |
| **SE0270_RangeSet** | Library | RangeSet implementation from Swift Evolution |
| **LoremIpsum** | Library | Lorem ipsum text generation |
| **_SwiftRuntimeExports** | Library | Swift runtime symbol exports |
| **_RuntimeC** | Library | C runtime utilities |
| **_RuntimeKeyPath** | Library | KeyPath runtime utilities |
| **_SwallowSwiftOverlay** | Library | Swift standard library overlays |
| **_PythonString** | Library | Python-style string operations |

### Key Features

- **`IdentifierIndexingArray`** — O(1) identifier-based access with array semantics
- **Swift Macros** — `@Singleton`, `@DebugLog`, `@KeyPathIterable`, `@RuntimeDiscoverable`, `@Memoized`
- **Runtime Introspection** — `InstanceMirror`, type metadata, dynamic symbol loading
- **File Management** — Type-safe directory operations and security-scoped access
- **Data Structures** — Specialized trees, graphs, and collections

## Installation

Add Swallow to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/vmanot/Swallow.git", branch: "master")
]
```

Import the modules you need:

```swift
import Swallow
import SwallowMacrosClient
import FoundationX
```

## Usage

*Note: This usage section is incomplete and shows only a few examples of the available functionality.*

### `IdentifierIndexingArray`

`IdentifierIndexingArray` offers a more robust and efficient way to manage collections of elements where unique identifiers play a crucial role. It simplifies many common tasks and operations, providing both performance benefits and improved code maintainability.

```swift
struct User: Identifiable {
    let id = UUID()
    var name: String
}

var users: IdentifierIndexingArrayOf<User> = [
    User(name: "Alice"),
    User(name: "Bob"),
    User(name: "Charlie")
]

// O(1) access by identifier
let alice = users[id: aliceID]

// Efficient updates and navigation
users.upsert(updatedUser)
let nextUser = users.element(after: alice)

// Facilitates easy mapping and sorting of elements while preserving the identifier indexing
let sortedUsers = users.sorted { $0.name < $1.name }
```

### `@Singleton`

The `@Singleton` property wrapper simplifies the creation of a Singleton class in Swift by automatically managing the shared instance of the class. This wrapper ensures that only one instance of the class is created and shared throughout the application.

```swift
@Singleton
public final class DataStore: ObservableObject {
    public var id = UUID()
}

// The shared instance is automatically created and accessed using `DataStore.shared`
let idString = DataStore.shared.id.uuidString
```

### Runtime Introspection

```swift
let mirror = try InstanceMirror(reflecting: complexObject)

for (key, value) in mirror.allChildren {
    print("\(key): \(value)")
}

// Type-safe field access
mirror["propertyName"] = newValue
```

### Enhanced File Operations

```swift
let documentsDir = CanonicalFileDirectory.appDocuments
let configFile = try URL(directory: documentsDir, path: "config.json")

// Security-scoped access management
let bookmark = try configFile.createBookmark()
try configFile.withSecurityScopedAccess {
    // Perform file operations
}
```

### Debug Utilities

Print out an error in an ASCII box for easier debugging:

```swift
do {
    let decoder = JSONDecoder()._modular()
    let user = try decoder.decode(User.self, from: jsonData)
} catch {
    _printEnclosedInASCIIBox(String(describing: error))
}
```

```
+------------------------------------------------------------------------------+
| keyNotFound("wrongKey", context for User: (coding path: []),                 |
| Optional(["email": "john@example.com", "id": 1.0, "name": "John Doe"]))      |
+------------------------------------------------------------------------------+
```


## System Requirements

- **Swift** 6.1 or later
- **iOS** 13.0+ / **macOS** 11.0+ / **tvOS** 13.0+ / **watchOS** 6.0+
- **Xcode** 16.4+

## Compilation

`swift-syntax` is the largest dependency of Swallow. At ~36000 LoC, it can add almost **twelve minutes** to release builds on Xcode Cloud.

To speed up builds (macOS only for now):
- Open Terminal and run `launchctl setenv FUCK_SWIFT_SYNTAX YES`.
- Relaunch Xcode (this is necessary for it to load the new launch environment variable).
- Update Swallow to the latest version.
- Clean your build folder (**Product** -> **Clean Build Folder...**)
- Build Swallow.

## Acknowledgments

<details>
<summary>swift-case-paths by Point-Free</summary>

- **Link**: [swift-case-paths](https://github.com/pointfreeco/swift-case-paths)
- **License**: [MIT License](https://github.com/pointfreeco/swift-case-paths/blob/main/LICENSE)
- **Authors**: Point-Free, Inc.
- **Notes**:
     - Partially rewritten and reimplemented for performance and functionality reasons where direct dependency was not feasible.

</details>