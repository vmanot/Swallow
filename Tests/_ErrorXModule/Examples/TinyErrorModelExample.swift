//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

@ErrorModel(domain: "com.example.notes")
private enum NoteError {
  @ErrorCode("note.empty_title", message: "Note title is empty")
  case emptyTitle

  @ErrorCode("note.too_long", message: "Note is too long")
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

    #expect(ErrorIdentity(error)?.domain == "com.example.notes")
    #expect(ErrorIdentity(error)?.code == "note.empty_title")
    #expect(ErrorReport(error).presentation?.message == "Note title is empty")
    #expect(
      error.diagnosticDescription() == "[com.example.notes.note.empty_title] Note title is empty")
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
