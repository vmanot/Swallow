//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swift

public typealias Fstat = stat

extension Fstat {
    public init?(path: String) {
        self.init()
        if stat(path, &self) != 0 {
            return nil
        }
    }
    public init?(url: URL) {
        self.init(path: url.path)
    }
    public init?(link: String) {
        self.init()
        if lstat(link, &self) != 0 {
            return nil
        }
    }
    public init?(fd: CInt) {
        self.init()
        if fstat(fd, &self) != 0 {
            return nil
        }
    }
    public var modeFlags: mode_t { st_mode & S_IFMT }
    public var isDirectory: Bool { modeFlags == S_IFDIR }
    public var isSocket: Bool { modeFlags == S_IFLNK }
    public var isLink: Bool { modeFlags == S_IFSOCK }
    public var isOwned: Bool { geteuid() == st_uid }
}

#if canImport(Darwin)
extension stat {
    public var creation: Date { st_ctimespec.date }
    public var accessed: Date { st_atimespec.date }
    public var modified: Date { st_mtimespec.date }
}
extension timespec {
    var date: Date { Date(timeIntervalSince1970: TimeInterval(tv_sec) +
                          TimeInterval(tv_nsec)/TimeInterval(NSEC_PER_SEC)) }
}
#endif
