//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _LogFormat: Hashable, Sendable {
    func _textualDump() throws -> _TextualLogDump
}
