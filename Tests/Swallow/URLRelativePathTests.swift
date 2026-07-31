import Foundation
import FoundationX
import Testing

@Suite
struct URLRelativePathTests {
    @Test
    func descendant() throws {
        let baseURL = URL(filePath: "/tmp/package", directoryHint: .isDirectory)
        let fileURL = baseURL.appending(path: "Sources/Library/File.swift")

        #expect(
            try fileURL.path(relativeTo: baseURL)
                == URL.RelativePath(path: "Sources/Library/File.swift")
        )
    }

    @Test
    func sibling() throws {
        let baseURL = URL(filePath: "/tmp/package/Sources", directoryHint: .isDirectory)
        let fileURL = URL(filePath: "/tmp/package/Headers/File.h")

        #expect(try fileURL.path(relativeTo: baseURL).path == "../Headers/File.h")
    }

    @Test
    func sharedStringPrefixIsNotAPathComponent() throws {
        let baseURL = URL(filePath: "/tmp/package", directoryHint: .isDirectory)
        let fileURL = URL(filePath: "/tmp/package-cache/File.swift")

        #expect(try fileURL.path(relativeTo: baseURL).path == "../package-cache/File.swift")
    }

    @Test
    func pathComponentHonorsExplicitFileAndDirectoryHints() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let existingDirectoryURL = rootURL.appendingPathComponent("Headers", isDirectory: true)
        try FileManager.default.createDirectory(at: existingDirectoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: rootURL) }

        #expect(!rootURL.appending(.file("Headers")).hasDirectoryPath)
        #expect(rootURL.appending(.directory("Headers")).hasDirectoryPath)

        var mutableURL: URL = rootURL
        mutableURL.append(.file("Headers"))
        #expect(!mutableURL.hasDirectoryPath)
    }
}
