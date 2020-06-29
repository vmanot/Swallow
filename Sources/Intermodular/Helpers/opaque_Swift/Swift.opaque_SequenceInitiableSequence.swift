//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_SequenceInitiableSequence: opaque_Sequence {
    init(noSequence: ())

    static func opaque_SequenceInitiableSequence_init(_: Any) -> opaque_SequenceInitiableSequence?
}
