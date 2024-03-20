//
// Copyright (c) Vatsal Manot
//

import Swift

private var _instancesBySourceLocation: [SourceCodeLocation: WeakObjectPointer<AnyObject>] = [:]

public func _printForOneInstanceOnly<T: AnyObject>(
    instance: T,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line,
    column: UInt = #column,
    operation: (T) throws -> Void
) rethrows {
    let location = SourceCodeLocation(file: file, function: function, line: line, column: column)
    
    if let existing = _instancesBySourceLocation[location]?.wrappedValue {
        if instance === existing {
            try operation(instance)
        }
    } else {
        _instancesBySourceLocation[location] = WeakObjectPointer(wrappedValue: instance)
        
        try operation(instance)
    }
}

/// A variant of `print` suitable for easy functional composition.
@_disfavoredOverload
public func print<T>(_ item: T) {
    Swift.print(item)
}

/// A variant of `print` suitable for easy functional composition.
public func printeval<T>(_ item: () -> T) {
    Swift.print(item())
}

/// A variant of `print` suitable for easy functional composition.
@_disfavoredOverload
public func printing<T>(_ item: T) -> T {
    Swift.print(item)
    
    return item
}

public func printEach<T>(
    @_SpecializedArrayBuilder<T> elements: () throws -> [T]
) rethrows {
    let elements = try elements()
    
    for element in elements {
        print(element)
    }
}

public func printEach<T>(
    @_SpecializedArrayBuilder<T> elements: () async throws -> [T]
) async rethrows {
    let elements = try await elements()
    
    for element in elements {
        print(element)
    }
}

public func _printEachOrError<T>(
    @_SpecializedArrayBuilder<T> elements: () async throws -> [T]
) async {
    do {
        let elements = try await elements()
        
        for element in elements {
            print(element)
        }
    } catch {
        print(error)
    }
}
