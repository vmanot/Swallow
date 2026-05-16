//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _LogExportArtifact: Hashable, Sendable {
    func _textualDump() throws -> _TextualLogDump
}
