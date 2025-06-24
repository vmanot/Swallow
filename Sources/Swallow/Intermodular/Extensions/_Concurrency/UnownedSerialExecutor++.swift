//
// Copyright (c) Vatsal Manot
//

extension _Concurrency.SerialExecutor {
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    public func asTaskExecutor() -> any _Concurrency.TaskExecutor {
        return Swallow.SerialToTaskExecutor(serialExecutor: self)
    }
}

extension _Concurrency.UnownedSerialExecutor {
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    public func asTaskExecutor() -> any _Concurrency.TaskExecutor {
#if swift(>=6.2)
        if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            return Swallow.SerialToTaskExecutor(serialExecutor: asSerialExecutor()!)
        } else {
            return Swallow.SerialToTaskExecutor(serialExecutor: unsafeBitCast(_executor, to: (any _Concurrency.SerialExecutor).self))
        }
#elseif swift(>=5.9)
        return Swallow.SerialToTaskExecutor(serialExecutor: unsafeBitCast(_executor, to: (any SerialExecutor).self))
#else
#error("Unsupported")
#endif
    }
}

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
fileprivate final class SerialToTaskExecutor: _Concurrency.TaskExecutor {
    private let serialExecutor: any _Concurrency.SerialExecutor
    
    init(serialExecutor: any _Concurrency.SerialExecutor) {
        self.serialExecutor = serialExecutor
    }
    
    func enqueue(_ job: consuming _Concurrency.ExecutorJob) {
        serialExecutor.enqueue(job)
    }
}
