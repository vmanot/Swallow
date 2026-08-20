import Darwin
import Dispatch
import Foundation
import POSIX
import Testing

@Suite(.serialized)
struct POSIXTests {
    private enum ExpectedError: Error {
        case bodyFailed
    }

    @Test
    func advisoryLockExcludesAnotherThread() throws {
        let fixture = try LockFixture()
        defer { fixture.remove() }

        let firstEntered = DispatchSemaphore(value: 0)
        let releaseFirst = DispatchSemaphore(value: 0)
        let secondStarted = DispatchSemaphore(value: 0)
        let secondEntered = DispatchSemaphore(value: 0)
        let finished = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            defer { finished.signal() }
            _ = try? fixture.lock.withExclusiveLock {
                firstEntered.signal()
                releaseFirst.wait()
            }
        }

        #expect(firstEntered.wait(timeout: .now() + 2) == .success)

        DispatchQueue.global().async {
            defer { finished.signal() }
            secondStarted.signal()
            _ = try? fixture.lock.withExclusiveLock {
                secondEntered.signal()
            }
        }

        #expect(secondStarted.wait(timeout: .now() + 2) == .success)
        #expect(secondEntered.wait(timeout: .now() + 0.1) == .timedOut)
        releaseFirst.signal()
        #expect(secondEntered.wait(timeout: .now() + 2) == .success)
        #expect(finished.wait(timeout: .now() + 2) == .success)
        #expect(finished.wait(timeout: .now() + 2) == .success)
    }

    @Test
    func advisorySharedLocksCanOverlapAndExcludeAnExclusiveLock() throws {
        let fixture = try LockFixture()
        defer { fixture.remove() }

        let firstSharedEntered = DispatchSemaphore(value: 0)
        let releaseFirstShared = DispatchSemaphore(value: 0)
        let secondSharedEntered = DispatchSemaphore(value: 0)
        let releaseSecondShared = DispatchSemaphore(value: 0)
        let exclusiveStarted = DispatchSemaphore(value: 0)
        let exclusiveEntered = DispatchSemaphore(value: 0)
        let finished = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            defer { finished.signal() }
            _ = try? fixture.lock.withSharedLock {
                firstSharedEntered.signal()
                releaseFirstShared.wait()
            }
        }
        #expect(firstSharedEntered.wait(timeout: .now() + 2) == .success)

        DispatchQueue.global().async {
            defer { finished.signal() }
            _ = try? fixture.lock.withSharedLock {
                secondSharedEntered.signal()
                releaseSecondShared.wait()
            }
        }
        #expect(secondSharedEntered.wait(timeout: .now() + 2) == .success)

        DispatchQueue.global().async {
            defer { finished.signal() }
            exclusiveStarted.signal()
            _ = try? fixture.lock.withExclusiveLock {
                exclusiveEntered.signal()
            }
        }
        #expect(exclusiveStarted.wait(timeout: .now() + 2) == .success)
        #expect(exclusiveEntered.wait(timeout: .now() + 0.1) == .timedOut)

        releaseFirstShared.signal()
        releaseSecondShared.signal()
        #expect(exclusiveEntered.wait(timeout: .now() + 2) == .success)
        #expect(finished.wait(timeout: .now() + 2) == .success)
        #expect(finished.wait(timeout: .now() + 2) == .success)
        #expect(finished.wait(timeout: .now() + 2) == .success)
    }

    @Test
    func advisoryLockExcludesAnotherProcess() throws {
        let fixture = try LockFixture()
        defer { fixture.remove() }

        try fixture.lock.withExclusiveLock {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/ruby")
            process.arguments = [
                "-e",
                "file = File.open(ARGV[0], 'r+'); exit(file.flock(File::LOCK_EX | File::LOCK_NB) ? 3 : 0)",
                fixture.path,
            ]
            try process.run()
            process.waitUntilExit()
            #expect(process.terminationReason == .exit)
            #expect(process.terminationStatus == 0)
        }
    }

    @Test
    func advisoryLockIsReleasedWhenBodyThrows() throws {
        let fixture = try LockFixture()
        defer { fixture.remove() }

        #expect(throws: ExpectedError.bodyFailed) {
            try fixture.lock.withExclusiveLock {
                throw ExpectedError.bodyFailed
            }
        }

        let descriptor = Darwin.open(fixture.path, O_RDWR)
        #expect(descriptor >= 0)
        defer { _ = Darwin.close(descriptor) }

        #expect(flock(descriptor, LOCK_EX | LOCK_NB) == 0)
        #expect(flock(descriptor, LOCK_UN) == 0)
    }

    @Test
    func memoryMapFailureThrows() {
        #expect(throws: POSIXError.self) {
            _ = try POSIXMemoryMap(
                length: Int(getpagesize()),
                protection: .read,
                accessControl: .shared,
                descriptor: .init(rawValue: -1)
            )
        }
    }

    @Test
    func descriptorResolvesItsFilePath() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let file = directory.appendingPathComponent("file")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        #expect(FileManager.default.createFile(atPath: file.path, contents: Data()))
        defer { try? FileManager.default.removeItem(at: directory) }

        let rawDescriptor = Darwin.open(file.path, O_RDONLY)
        #expect(rawDescriptor >= 0)
        defer { _ = Darwin.close(rawDescriptor) }

        let descriptor = POSIXIOResourceDescriptor(rawValue: rawDescriptor)
        let resolvedPath = try descriptor.resolveFilePath()
        let expectedCStringResult: UnsafeMutablePointer<CChar>? = Darwin.realpath(file.path, nil)
        let expectedCString = try #require(expectedCStringResult)
        defer { Darwin.free(expectedCString) }
        let expectedPath = String(cString: expectedCString)
        #expect(resolvedPath == expectedPath)
    }

    @Test
    func invalidSignalActionsThrow() {
        #expect(throws: POSIXError.self) {
            _ = try POSIXSignal.kill.ignore()
        }
        #expect(throws: POSIXError.self) {
            _ = try POSIXSignal.kill.restore()
        }
    }

    @Test
    func pthreadMutexCanBeReconstructedAfterDestruction() throws {
        let mutex = POSIXThreadMutex()

        try mutex.construct()
        try mutex.destruct()
        try mutex.construct()
        defer { try? mutex.destruct() }

        try mutex.acquireOrBlock()
        try mutex.relinquish()
    }
}

private final class LockFixture: @unchecked Sendable {
    let directory: URL
    let path: String
    let lock: POSIXAdvisoryFileLock

    init() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        path = directory.appendingPathComponent("state.lock").path
        lock = POSIXAdvisoryFileLock(path: path)
    }

    func remove() {
        try? FileManager.default.removeItem(at: directory)
    }
}
