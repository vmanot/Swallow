//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import XCTest

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class SerialToTaskExecutorTests: XCTestCase {
    func test_fromExecutor() async {
        let executor = MySerialExecutor()
        
        let isCurrent = await Task(executorPreference: executor.asTaskExecutor()) {
            return executor.queue == OperationQueue.current
        }.value
        
        XCTAssertTrue(isCurrent)
    }
    
    func test_fromUnownedExecutor() async {
        let executor = MySerialExecutor()
        
        let isCurrent = await Task(executorPreference: executor.asUnownedSerialExecutor().asTaskExecutor()) {
            return executor.queue == OperationQueue.current
        }.value
        
        XCTAssertTrue(isCurrent)
    }
}

fileprivate final class MySerialExecutor: SerialExecutor {
    let queue: OperationQueue
    
    init() {
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
    }
    
    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        
        queue.addOperation {
            unownedJob.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }
    
    func isSameExclusiveExecutionContext(other: MySerialExecutor) -> Bool {
        queue == other.queue
    }
}
