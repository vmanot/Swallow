//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Darwin
import MachO
import Swallow

public struct MachArchitecture: MutableWrapper, Trivial {
    public typealias Value = NXArchInfo
    
    public var value: Value

    public init(_ value: Value) {
        self.value = value
    }
}

extension MachArchitecture {
    public static var current: MachArchitecture {
        return .init(NXGetLocalArchInfo().pointee)
    }
}

// MARK: - Conformances

extension MachArchitecture: CaseIterable {
    public static var allCases: UnsafeBufferPointer<MachArchitecture> {
        var count: Int = 0
        
        guard var start = NXGetAllArchInfos() else {
            return .init(start: nil, count: 0)
        }
        
        while start.pointee != NXArchInfo.null && start.pointee.name != nil {
            count += 1
            start += 1
        }
        
        return .init(start: NXGetAllArchInfos().assumingMemoryBound(to: MachArchitecture.self), count: count)
    }
}

extension MachArchitecture: CustomStringConvertible {
    public var description: String {
        return .init(utf8String: value.description)
    }
}

extension MachArchitecture: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(MachCPU(self))
    }
}

extension MachArchitecture: Named {
    public var name: String {
        return .init(utf8String: value.name)
    }
}

#endif
