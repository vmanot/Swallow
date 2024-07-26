//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension MainActor {
    /// `assumeIsolated` backported to pre-Swift 5.9 runtimes.
    ///
    /// See [stdlib/public/Concurrency/MainActor.swift][1]
    ///
    /// [1]: https://github.com/apple/swift/blob/7afa4cfdc69317559ca6a1b5e0e52cb557ec959b/stdlib/public/Concurrency/MainActor.swift#L119
    @_unavailableFromAsync(message: "await the call to the @MainActor closure directly")
    public static func unsafeAssumeIsolated<T>(
        _ operation: @MainActor () throws -> T,
        file: StaticString = #fileID, line: UInt = #line
    ) rethrows -> T {
        typealias YesActor = @MainActor () throws -> T
        typealias NoActor = () throws -> T
        
        return try withoutActuallyEscaping(operation) { (_ fn: @escaping YesActor) throws -> T in
            let rawFn = unsafeBitCast(fn, to: NoActor.self)
            
            return try rawFn()
        }
    }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
extension MainActor {
    /// Invoke `body`, running synchronously if possible.
    ///
    /// This method is equivalent to `Task { @MainActor in <body> }`, except that
    /// the first thread hop is elided if the caller is already on the main thread.
    /// Thus if `<foo>` has no subsequent thread hops, it can run fully synchronously.
    @discardableResult
    public static func runAsap<Success>(
        priority: TaskPriority? = nil,
        body: @MainActor @Sendable @escaping () async -> Success
    ) -> Task<Success, Never> {
        if Thread.isMainThread {
            MainActor.unsafeAssumeIsolated {
                Task.startOnMainActor {
                    await body()
                }
            }
        } else {
            Task(priority: priority) { await body() }
        }
    }
    
    /// Invoke `body`, running synchronously if possible.
    ///
    /// This method is equivalent to `Task { @MainActor in <body> }`, except that
    /// the first thread hop is elided if the caller is already on the main thread.
    /// Thus if `<foo>` has no subsequent thread hops, it can run fully synchronously.
    @discardableResult
    public static func runAsap<Success>(
        priority: TaskPriority? = nil,
        body: @MainActor @Sendable @escaping () async throws -> Success
    ) -> Task<Success, Error> {
        if Thread.isMainThread {
            MainActor.unsafeAssumeIsolated {
                Task.startOnMainActor {
                    try await body()
                }
            }
        } else {
            Task(priority: priority) { try await body() }
        }
    }
}

// https://github.com/apple/swift/blob/98e65d015979c7b5a58a6ecf2d8598a6f7c85794/stdlib/public/Concurrency/Task.swift#L250-L294

extension Task where Failure == Never {
    @_silgen_name("$sScTss5NeverORs_rlE16startOnMainActor8priority_ScTyxABGScPSg_xyYaYbScMYccntFZ")
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    @MainActor
    @discardableResult
    fileprivate static func startOnMainActor(
priority: TaskPriority? = nil,
    @_inheritActorContext @_implicitSelfCapture _ work: consuming @Sendable @escaping @MainActor() async -> Success
    ) -> Task<Success, Never>
}

extension Task where Failure == Error {
    @_silgen_name("$sScTss5Error_pRs_rlE16startOnMainActor8priority_ScTyxsAA_pGScPSg_xyYaYbKScMYccntFZ")
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    @MainActor
    @discardableResult
    fileprivate static func startOnMainActor(
priority: TaskPriority? = nil,
    @_inheritActorContext @_implicitSelfCapture _ work: consuming @Sendable @escaping @MainActor() async throws -> Success
    ) -> Task<Success, Error>
}
