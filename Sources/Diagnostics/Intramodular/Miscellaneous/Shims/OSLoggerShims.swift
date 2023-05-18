//
// Copyright (c) Vatsal Manot
//

#if canImport(os)
import os

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public typealias OSLogger = os.Logger
#endif
