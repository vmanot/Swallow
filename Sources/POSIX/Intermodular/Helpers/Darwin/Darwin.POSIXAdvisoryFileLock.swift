//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

/// An advisory interprocess lock backed by a POSIX file descriptor.
///
/// The lock file is opened or created for each scoped acquisition and remains
/// locked only for the duration of the scope. The file itself is
/// intentionally not removed when the lock is released: removing a lock file
/// while another process has it open can allow two callers to lock different
/// inodes and bypass the advisory lock.
public final class POSIXAdvisoryFileLock {
    private enum Mode {
        case shared
        case exclusive

        var operation: Int32 {
            switch self {
            case .shared: LOCK_SH
            case .exclusive: LOCK_EX
            }
        }
    }

    private let path: String
    private let permissions: POSIXFilePermissions

    /// Creates a lock for the file at `path`.
    ///
    /// The parent directory must already exist. The default permissions keep
    /// the lock file private to its owner, matching the usual use of lock
    /// files for local build state.
    public init(
        path: String,
        permissions: POSIXFilePermissions = [.userReadable, .userWritable]
    ) {
        self.path = path
        self.permissions = permissions
    }

    /// Creates a lock for the file at `url`.
    public convenience init(
        at url: URL,
        permissions: POSIXFilePermissions = [.userReadable, .userWritable]
    ) {
        self.init(
            path: url.path,
            permissions: permissions
        )
    }

    /// Executes `body` while holding an exclusive advisory lock.
    ///
    /// Unlocking is attempted if `body` throws. If `body` succeeds, an
    /// unlocking failure is surfaced to the caller.
    public func withExclusiveLock<Result>(
        _ body: () throws -> Result
    ) throws -> Result {
        try withLock(.exclusive, body)
    }

    /// Executes `body` while holding a shared advisory lock.
    public func withSharedLock<Result>(
        _ body: () throws -> Result
    ) throws -> Result {
        try withLock(.shared, body)
    }

    private func withLock<Result>(
        _ mode: Mode,
        _ body: () throws -> Result
    ) throws -> Result {
        let descriptor: POSIXIOResourceDescriptor = try openDescriptor()
        defer { try? descriptor.close() }
        try perform(mode.operation, on: descriptor)

        let result: Result
        do {
            result = try body()
        } catch {
            try? perform(LOCK_UN, on: descriptor)
            throw error
        }

        try perform(LOCK_UN, on: descriptor)
        return result
    }

    private func perform(
        _ operation: Int32,
        on descriptor: POSIXIOResourceDescriptor
    ) throws {
        var result: Int32
        repeat {
            result = flock(descriptor.rawValue, operation)
        } while result == -1 && errno == EINTR
        guard result == 0 else {
            throw POSIXError(.init(rawValue: errno) ?? .EIO)
        }
    }

    private func openDescriptor() throws -> POSIXIOResourceDescriptor {
        var rawDescriptor: CInt

        repeat {
            rawDescriptor = Darwin.open(
                path,
                O_CREAT | O_RDWR | O_CLOEXEC,
                permissions.rawValue
            )
        } while rawDescriptor == -1 && errno == EINTR

        guard rawDescriptor >= 0 else {
            throw POSIXError(.init(rawValue: errno) ?? .EIO)
        }
        return POSIXIOResourceDescriptor(rawValue: rawDescriptor)
    }
}
