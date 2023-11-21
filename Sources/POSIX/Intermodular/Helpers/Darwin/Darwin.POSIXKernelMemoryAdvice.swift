//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

@frozen
public enum POSIXKernelMemoryAdvice: Int32, Initiable {
    case normal
    case willBeAccessedRandomly
    case willBeAccessedSequentially
    case willNeed
    case doNotNeedCurrently
    case canBeFreed
    case zeroOutWiredPages
    case isReusableByAnyone
    case willBeReused
    case mayBeReused
    case pageOutNow
    
    @inlinable
    public init() {
        self = .normal
    }
}

extension POSIXKernelMemoryAdvice: Hashable {
    public typealias RawValue = Int32
    
    @inlinable
    public var rawValue: RawValue {
        switch self {
            case .normal:
                return MADV_NORMAL
            case .willBeAccessedRandomly:
                return MADV_RANDOM
            case .willBeAccessedSequentially:
                return MADV_SEQUENTIAL
            case .willNeed:
                return MADV_WILLNEED
            case .doNotNeedCurrently:
                return MADV_DONTNEED
            case .canBeFreed:
                return MADV_FREE
            case .zeroOutWiredPages:
                return MADV_ZERO_WIRED_PAGES
            case .isReusableByAnyone:
                return MADV_FREE_REUSABLE
            case .willBeReused:
                return MADV_FREE_REUSE
            case .mayBeReused:
                return MADV_CAN_REUSE
            case .pageOutNow:
                return MADV_PAGEOUT
        }
    }
    
    @inlinable
    public init?(rawValue: RawValue) {
        switch rawValue {
            case type(of: self).normal.rawValue:
                self = .normal
            case type(of: self).willBeAccessedRandomly.rawValue:
                self = .willBeAccessedRandomly
            case type(of: self).willBeAccessedSequentially.rawValue:
                self = .willBeAccessedSequentially
            case type(of: self).willNeed.rawValue:
                self = .willNeed
            case type(of: self).doNotNeedCurrently.rawValue:
                self = .doNotNeedCurrently
            case type(of: self).canBeFreed.rawValue:
                self = .canBeFreed
            case type(of: self).zeroOutWiredPages.rawValue:
                self = .zeroOutWiredPages
            case type(of: self).isReusableByAnyone.rawValue:
                self = .isReusableByAnyone
            case type(of: self).willBeReused.rawValue:
                self = .willBeReused
            case type(of: self).mayBeReused.rawValue:
                self = .mayBeReused
            case type(of: self).pageOutNow.rawValue:
                self = .pageOutNow
                
            default:
                return nil
        }
    }
}

extension BufferPointer {
    @inlinable
    public func input(kernelAdvice: POSIXKernelMemoryAdvice) {
        posix_madvise(_reinterpretCast(baseAddress), .init(count) * MemoryLayout<Element>.size, kernelAdvice.rawValue)
    }
}
