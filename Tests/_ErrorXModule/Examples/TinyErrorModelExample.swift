//
// Copyright (c) Vatsal Manot
//

import Testing
@testable import _ErrorXModule

@ErrorModel("com.example.notes")
private enum NoteError {
    @ErrorCase("note.empty_title", summary: "Note title is empty")
    case emptyTitle

    @ErrorCase("note.too_long", summary: "Note is too long")
    case tooLong(characterCount: Int)
}

private struct Notes {
    func save(
        title: String,
        body: String
    ) throws {
        guard !title.isEmpty else {
            throw NoteError.emptyTitle
        }

        guard body.count <= 280 else {
            throw NoteError.tooLong(characterCount: body.count)
        }

        // Persist the note.
    }
}

@Suite
struct TinyErrorModelExample {
    @Test
    func tinyErrorNeedsOnlyDomainAndCaseCodes() throws {
        let error = try catchNoteError {
            try Notes().save(title: "", body: "Draft")
        }
        let report = _ErrorReporting.report(error)
        let nsError = error._nsErrorExportRepresentation()

        #expect(report.identity?.domain.rawValue == "com.example.notes")
        #expect(report.identity?.code == "note.empty_title")
        #expect(nsError.code == 1)
        #expect(nsError.userInfo[_NSErrorExportRepresentation.errorCodeStringKey] as? String == "note.empty_title")
        #expect(nsError.userInfo[_NSErrorExportRepresentation.errorCodeIntegerKey] as? Int == 1)
        #expect(nsError.userInfo[_NSErrorExportRepresentation.errorCodeCatalogKey] as? [String] == [
            "note.empty_title",
            "note.too_long"
        ])
        #expect(NoteError.errorDescriptor.catalog.allErrorCodes.map(\.stableIdentifier) == [
            "note.empty_title",
            "note.too_long"
        ])
        #expect(error._errorDescriptorCase?.code.stableIdentifier == "note.empty_title")
        #expect(report.presentation?.summary == "Note title is empty")
        #expect(report.context.isEmpty)
    }

    @Test
    func macroGeneratedDescriptorHasStableMirrorShape() throws {
        let descriptorLabels = Mirror(reflecting: NoteError.errorDescriptor).children.compactMap(\.label)
        let caseDescriptor = try #require(NoteError.emptyTitle._errorDescriptorCase)
        let caseLabels = Mirror(reflecting: caseDescriptor).children.compactMap(\.label)

        #expect(descriptorLabels == ["catalog", "cases"])
        #expect(caseLabels == [
            "code",
            "context",
            "presentation",
            "recoverySuggestions",
            "underlyingError",
            "failureTree",
        ])
    }
}

private func catchNoteError(
    _ operation: () throws -> Void
) throws -> NoteError {
    do {
        try operation()
    } catch let error as NoteError {
        return error
    } catch {
        Issue.record("Unexpected error: \(error)")
    }

    throw TinyErrorModelExampleFailure.expectedNoteError
}

private enum TinyErrorModelExampleFailure: Error {
    case expectedNoteError
}
