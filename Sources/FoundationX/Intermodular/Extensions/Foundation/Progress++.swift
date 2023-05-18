//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

#if canImport(Combine)

import Combine

extension Progress {
    public var fractionCompletePublisher: AnyPublisher<Double, Never> {
        publisher(for: \.fractionCompleted)
            .eraseToAnyPublisher()
    }
    
    public var isFinishedPublisher: AnyPublisher<Void, Never> {
        publisher(for: \.isFinished)
            .filter({ $0 })
            .map({ _ in () })
            .eraseToAnyPublisher()
    }
}

#endif
