//
// Copyright (c) Vatsal Manot
//

import Swift

#if arch(arm64) || arch(i386) || arch(x86_64)
public let is32Bit = false
#else
public let is32Bit = true
#endif

public let is64Bit = !is32Bit
