//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public enum _MaxOrRange<Bound: Comparable> {
    case maximum(Bound)
    case range(Bound)
}
