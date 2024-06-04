//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

open class Fopen: FILEStream, Sequence, IteratorProtocol {
    public enum FILEMode {
        public init(_ rawValue: String) {
            self = .other(rawValue)
        }
        
        static public let read = Self("r")
        static public let both = Self("r+")
        static public let write = Self("w")
        static public let append =  Self("a")
        static public let new = Self("wx")
        
        case other(_ mode: String)
        
        var mode: String {
            switch self {
                case .other(let mode):
                    return mode
            }
        }
    }
    
    public enum FILESeek {
        case absolute(_ offset: Int)
        case relative(_ offset: Int)
        case fromEnd(_ offset: Int)
        var args: (offset: Int, whence: CInt) {
            switch self {
                case .absolute(let offset):
                    return (offset, SEEK_SET)
                case .relative(let offset):
                    return (offset, SEEK_CUR)
                case .fromEnd(let offset):
                    return (offset, SEEK_END)
            }
        }
    }
    
    open var fileStream: UnsafeMutablePointer<FILE>
    
    public init?(stream: UnsafeMutablePointer<FILE>?) {
        guard let stream = stream else { return nil }
        fileStream = stream
        Popen.openFILEStreams += 1
    }
    
    public convenience init?(path: String, mode: FILEMode = .read) {
        self.init(stream: fopen(path, mode.mode))
    }
    
    public convenience init?(fd: CInt, mode: FILEMode = .read) {
        self.init(stream: fdopen(fd, mode.mode))
    }
    
    @available(OSX 10.13, iOS 11.0, *)
    public convenience init?(buffer: UnsafeMutableRawPointer,
                             count: Int, mode: FILEMode = .read) {
        self.init(stream: fmemopen(buffer, count, mode.mode))
    }
    
#if canImport(Darwin)
    public convenience init?(cookie: UnsafeRawPointer?,
                             reader: @escaping @convention(c) (
                                _ cookie: UnsafeMutableRawPointer?,
                                _ buffer: UnsafeMutablePointer<CChar>?,
                                _ count: CInt) -> CInt,
                             writer: @escaping @convention(c) (
                                _ cookie: UnsafeMutableRawPointer?,
                                _ buffer: UnsafePointer<CChar>?,
                                _ count: CInt) -> CInt,
                             seeker: @escaping @convention(c) (
                                _ cookie: UnsafeMutableRawPointer?,
                                _ position: fpos_t,
                                _ relative: CInt) -> fpos_t,
                             closer: @escaping @convention(c) (
                                _ cookie: UnsafeMutableRawPointer?) -> CInt) {
                                    self.init(stream: funopen(cookie, reader, writer, seeker, closer))
                                }
#endif
    
    open func seek(to position: FILESeek) -> CInt {
        let args = position.args
        return fseek(fileStream, args.offset, args.whence)
    }
    
    open func tell() -> Int {
        return ftell(fileStream)
    }
    
    deinit {
        _ = fclose(fileStream)
        Popen.openFILEStreams -= 1
    }
}
