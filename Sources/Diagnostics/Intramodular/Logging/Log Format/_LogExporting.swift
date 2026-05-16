//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A type that can produce an explicit log artifact.
///
/// App diagnostics need an artifact they own. OSLogStore is a platform aperture,
/// not an export contract.
public protocol _LogExporting {
    associatedtype Log: _LogExportArtifact
    
    func exportLog() async throws -> Log
}
