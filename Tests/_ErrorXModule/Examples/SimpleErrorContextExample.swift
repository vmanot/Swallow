//
// Copyright (c) Vatsal Manot
//

import Testing
@testable import _ErrorXModule

private enum UploadContext {
    @ErrorContextKey("upload.file_extension", privacy: .public)
    static var fileExtension: _TypedErrorContextKey<String>
}

@ErrorModel("com.example.avatar-upload")
private enum AvatarUploadError {
    @ErrorCase("avatar.unsupported_format", summary: "Avatar file format is not supported")
    @ErrorContext(UploadContext.fileExtension)
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
    func simpleErrorCanAddOneTypedContextValue() throws {
        let error = try catchAvatarUploadError {
            try AvatarUploader().upload(fileName: "avatar.gif")
        }
        let report = _ErrorReporting.report(error)

        #expect(report.identity?.domain.rawValue == "com.example.avatar-upload")
        #expect(report.identity?.code == "avatar.unsupported_format")
        #expect(error._errorDescriptorCase?.context.count == 1)
        #expect(report.context.count == 1)
        #expect(report.presentation?.summary == "Avatar file format is not supported")
        #expect(report.contextValue(for: UploadContext.fileExtension) == .string("gif"))
        #expect(report.projectedContextValue(for: UploadContext.fileExtension) == .string("gif"))
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
