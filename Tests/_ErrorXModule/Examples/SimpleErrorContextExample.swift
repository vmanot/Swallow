//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

@ErrorModel(domain: "com.example.avatar-upload")
private enum AvatarUploadError {
  @ErrorCode("avatar.unsupported_format", message: "Avatar file format is not supported")
  @ErrorContext("upload.file_extension", privacy: .public)
  case unsupportedFormat(fileExtension: String)
}

private struct AvatarUploader {
  func upload(
    fileName: String
  ) throws {
    let fileExtension = fileName.split(separator: ".").last.map(String.init) ?? ""

    guard ["png", "jpg", "jpeg"].contains(fileExtension.lowercased()) else {
      throw AvatarUploadError.unsupportedFormat(fileExtension: fileExtension)
    }

    // Upload the avatar.
  }
}

@Suite
struct SimpleErrorContextExample {
  @Test
  func simpleErrorCanAddLocalContextWithoutAKeyCatalog() throws {
    let error = try catchAvatarUploadError {
      try AvatarUploader().upload(fileName: "avatar.gif")
    }
    let diagnostic = error.diagnosticDescription(style: .detailed)

    #expect(ErrorIdentity(error)?.code == "avatar.unsupported_format")
    #expect(ErrorReport(error).presentation?.message == "Avatar file format is not supported")
    #expect(diagnostic.contains("upload.file_extension: gif"))
  }
}

private func catchAvatarUploadError(
  _ operation: () throws -> Void
) throws -> AvatarUploadError {
  do {
    try operation()
  } catch let error as AvatarUploadError {
    return error
  } catch {
    Issue.record("Unexpected error: \(error)")
  }

  throw SimpleErrorContextExampleFailure.expectedUploadError
}

private enum SimpleErrorContextExampleFailure: Error {
  case expectedUploadError
}
