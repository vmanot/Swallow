# Swallow

A complement to the Swift standard library. This framework contains a suite of essential protocols and types that are missing from the standard library, and attempts to maintain API parity with the latest Swift evolution trends. 

Swallow is composed of the following modules:
- `Swallow`
- `Diagnostics`
- `FoundationX`
- `Compute`
- `POSIX`
- `Runtime`

Along with the miscellaneous modules:
- `_LoremIpsum`
- `SE0270_RangeSet`

## Usage

### `IdentifierIndexingArray`

`IdentifierIndexingArray` offers a more robust and efficient way to manage collections of elements where unique identifiers play a crucial role. It simplifies many common tasks and operations, providing both performance benefits and improved code maintainability.

To create an `Identifiable` object to include in the array, simply add `Identifiable` comformance with a unique `id` element to the object. 
```swift
public struct MyIdentifiableObject: Identifiable {
    public typealias ID = _TypeAssociatedID<Self, UUID>

    // a randomely generated UUID
    public var id: ID = .random()
    public var someText: String
    
    init(someText: String) {
        self.someText = someText
    }
}
```

`Identifiable` objects can now be stored in the `IdentifierIndexingArray` of specified objects:
```swift
var objects: IdentifierIndexingArrayOf<MyIdentifiableObject>
```
The full objects struct would look something like this
```swift
public struct MyObjects {
    let myObject1 = MyIdentifiableObject(someText: "1. Hello World!")
    let myObject2 = MyIdentifiableObject(someText: "2. Hello Earth!")
    let myObject3 = MyIdentifiableObject(someText: "3. Hello Planet!")
    
    var objects: IdentifierIndexingArrayOf<MyIdentifiableObject>
    
    init() {
        objects = [myObject1, myObject2, myObject3]
    }
}
```
Working with the the `IdentifierIndexingArray` of objects is simple and efficient: 

```swift
// get direct access to elements by their unique identifiers without having to find an element by iterating through an array
let myObjectByID = objects.contains(elementIdentifiedBy: myObject1.id)
        
// efficient insertion and deletion of elements by their identifier without the need to search through the entire collection.
let myObject4 = MyIdentifiableObject(someText: "4. Hello Life!")
objects.append(myObject4)
objects.remove(myObject3)

// Ensures that each identifier is unique within the collection, automatically handling duplicates if necessary.
objects.insert(myObject1) // the object will remain as is

// Provides custom subscripts and methods for accessing elements before or after a given element, simplifying navigation and manipulation.
let firstObject = objects[0]
let afterFirstObject = objects.element(after: myObject1)
let beforeLastObject = objects.element(before: myObject4)

// Facilitates easy mapping and sorting of elements while preserving the identifier indexing.
let sortedObjects = objects.sorted { left, right in
    left.someText.count < right.someText.count
}
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

### _printEnclosedInASCIIBox
Print out an error in an ASCIIBox for easier debugging: 

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

## Compilation

`swift-syntax` is the largest dependency of Swallow. At ~36000 LoC, it can add almost **twelve minutes** to release builds on Xcode Cloud.

To speed up builds (macOS only for now):
- Open Terminal and run `launchctl setenv FUCK_SWIFT_SYNTAX YES`.
- Relaunch Xcode (this is necessary for it to load the new launch environment variable).
- Update Swallow to the latest version.
- Clean your build folder (**Product** -> **Clean Build Folder...**)
- Build Swallow.
