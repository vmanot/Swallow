//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

/// A memoized value that refreshes based on a tracked value.
public final class _KeyPathTrackingMemoizedValue<EnclosingSelf: AnyObject, TrackedValue, Value> {
    @usableFromInline
    let trackedKeyPath: KeyPath<EnclosingSelf, TrackedValue>
    @usableFromInline
    let computeValue: (EnclosingSelf) -> Value
    
    @usableFromInline
    let makeSubscription: ((_KeyPathTrackingMemoizedValue, TrackedValue) -> AnyCancellable)?

    @usableFromInline
    var trackedValueSubscription: AnyCancellable?
    @usableFromInline
    var computedValue: Value?
    
    public init(
        tracking keyPath: KeyPath<EnclosingSelf, TrackedValue>,
        value: @escaping (EnclosingSelf) -> Value
    ) where TrackedValue: ObservableObject {
        self.trackedKeyPath = keyPath
        self.computeValue = value
        self.makeSubscription = { _self, value in
            value.objectWillChange.sink { [weak _self] _ in
                _self?.invalidate()
            }
        }
    }
    
    @inlinable
    @inline(__always)
    public func computeValue(
        enclosingInstance: EnclosingSelf
    ) -> Value {
        willComputeValue(enclosingInstance: enclosingInstance)
        
        if let computedValue {
            return computedValue
        } else {
            let value = computeValue(enclosingInstance)
            
            self.computedValue = value
            
            return value
        }
    }
    
    @usableFromInline
    func willComputeValue(enclosingInstance: EnclosingSelf) {
        if trackedValueSubscription == nil, let makeSubscription {
            let trackedValue = enclosingInstance[keyPath: trackedKeyPath]
            
            self.trackedValueSubscription = makeSubscription(self, trackedValue)
        }
    }
    
    @usableFromInline
    func invalidate() {
        computedValue = nil
    }
}

// MARK: - Conformances

extension _KeyPathTrackingMemoizedValue: Equatable {
    public static func == (lhs: _KeyPathTrackingMemoizedValue, rhs: _KeyPathTrackingMemoizedValue) -> Bool {
        return true
    }
}

extension _KeyPathTrackingMemoizedValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
}

extension ObservableObject {
    public typealias _SelfParametrizedKeyPathTrackingMemoizedValue<TrackedValue, Value> = _KeyPathTrackingMemoizedValue<Self, TrackedValue, Value>
}
