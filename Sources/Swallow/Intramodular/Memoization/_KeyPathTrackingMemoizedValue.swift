//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

/// A memoized value that refreshes based on a tracked value.
public final class _KeyPathTrackingMemoizedValue<EnclosingSelf, TrackedValue, Value> {
    private let trackedKeyPath: KeyPath<EnclosingSelf, TrackedValue>
    private let computeValue: (EnclosingSelf) -> Value
    private let makeSubscription: ((_KeyPathTrackingMemoizedValue, TrackedValue) -> AnyCancellable)?

    private var trackedValueSubscription: AnyCancellable?
    private var computedValue: Value?
    
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
    
    public func computeValue(
        enclosingInstance: EnclosingSelf
    ) -> Value {
        if trackedValueSubscription == nil, let makeSubscription {
            let trackedValue = enclosingInstance[keyPath: trackedKeyPath]
            
            self.trackedValueSubscription = makeSubscription(self, trackedValue)
        }
        
        if let computedValue {
            return computedValue
        } else {
            let value = computeValue(enclosingInstance)
            
            self.computedValue = value
            
            return value
        }
    }
    
    private func invalidate() {
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
