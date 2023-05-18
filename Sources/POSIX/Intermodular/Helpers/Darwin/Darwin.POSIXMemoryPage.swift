//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXMemoryPage {
    public static var size: Int32 = getpagesize()
}

