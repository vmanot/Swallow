//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _DecomposableError: Error {
    func decomposeError() -> _ErrorDecomposition<Self>
}

public enum _ErrorDecomposition<Parent: Error> {
    case irreducible(Parent)
    case semantic(ElementGrouping<Error>)
    case catchAll(Error)
}
