//
// Copyright (c) Vatsal Manot
//

import Darwin
import Foundation
import Swallow

public enum POSIXSignal {
    case hup
    case int
    case quit
    case ill
    case trap
    case abrt
    case emt
    case fpe
    case kill
    case bus
    case segv
    case sys
    case pipe
    case alrm
    case term
    case urg
    case stop
    case tstp
    case cont
    case chld
    case ttin
    case ttou
    case io
    case xcpu
    case xfsz
    case vtalrm
    case prof
    case winch
    case info
    case usr1
    case usr2
    case user(Int)

    public var rawValue: Int32 {
        switch self {
        case .hup:
            return Int32(SIGHUP)
        case .int:
            return Int32(SIGINT)
        case .quit:
            return Int32(SIGQUIT)
        case .ill:
            return Int32(SIGILL)
        case .trap:
            return Int32(SIGTRAP)
        case .abrt:
            return Int32(SIGABRT)
        case .emt:
            return Int32(SIGEMT)
        case .fpe:
            return Int32(SIGFPE)
        case .kill:
            return Int32(SIGKILL)
        case .bus:
            return Int32(SIGBUS)
        case .segv:
            return Int32(SIGSEGV)
        case .sys:
            return Int32(SIGSYS)
        case .pipe:
            return Int32(SIGPIPE)
        case .alrm:
            return Int32(SIGALRM)
        case .term:
            return Int32(SIGTERM)
        case .urg:
            return Int32(SIGURG)
        case .stop:
            return Int32(SIGSTOP)
        case .tstp:
            return Int32(SIGTSTP)
        case .cont:
            return Int32(SIGCONT)
        case .chld:
            return Int32(SIGCHLD)
        case .ttin:
            return Int32(SIGTTIN)
        case .ttou:
            return Int32(SIGTTOU)
        case .io:
            return Int32(SIGIO)
        case .xcpu:
            return Int32(SIGXCPU)
        case .xfsz:
            return Int32(SIGXFSZ)
        case .vtalrm:
            return Int32(SIGVTALRM)
        case .prof:
            return Int32(SIGPROF)
        case .winch:
            return Int32(SIGWINCH)
        case .info:
            return Int32(SIGINFO)
        case .usr1:
            return Int32(SIGUSR1)
        case .usr2:
            return Int32(SIGUSR2)
        case .user(let value):
            return Int32(value)
        }
    }
}

extension POSIXSignal {
    public func handle(with action: (@convention(c) @escaping (Int32) -> ())) throws {
        var action = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)

        try withUnsafePointer(to: &action, { sigaction(rawValue, $0, nil) }).throwingAsPOSIXErrorIfNecessary()
    }

    public func nest() throws {
        try Darwin.raise(rawValue).throwingAsPOSIXErrorIfNecessary()
    }

    public func ignore() throws -> (@convention(c) (Int32) -> ()) {
        guard let result = Darwin.signal(rawValue, SIG_IGN) else {
            throw POSIXError.last
        }

        return result
    }

    public func restore() throws -> (@convention(c) (Int32) -> ()) {
        guard let result = Darwin.signal(rawValue, SIG_DFL) else {
            throw POSIXError.last
        }

        return result
    }
}
