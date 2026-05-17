//
// Copyright (c) Vatsal Manot
//

import Testing
@testable import _ErrorXModule

@ErrorDomain("com.example.documents.import")
private enum DocumentImportDiagnostics {
    @ErrorCodeCatalog
    enum Codes: String {
        case unsupportedFileType = "document.unsupported_file_type"
        case invalidRecord = "document.invalid_record"
        case invalidDocument = "document.invalid"
    }

    enum Context {
        @ErrorContextKey("file.path", privacy: .private)
        static var filePath: _TypedErrorContextKey<String>

        @ErrorContextKey("file.extension", privacy: .public)
        static var fileExtension: _TypedErrorContextKey<String>

        @ErrorContextKey("row.number", privacy: .public)
        static var rowNumber: _TypedErrorContextKey<Int>

        @ErrorContextKey("field.name", privacy: .public)
        static var fieldName: _TypedErrorContextKey<String>

        @ErrorContextKey("field.raw_value", privacy: .sensitive)
        static var rawFieldValue: _TypedErrorContextKey<String>
    }

    @ErrorModel(domain: DocumentImportDiagnostics.self)
    enum ImportError {
        @ErrorCase(
            Codes.unsupportedFileType,
            summary: "Document type is not supported",
            reason: "The importer only accepts CSV documents."
        )
        @ErrorRecovery("Export the document as CSV and try again.")
        @ErrorContext(Context.filePath)
        @ErrorContext(Context.fileExtension)
        case unsupportedFileType(filePath: String, fileExtension: String)

        @ErrorCase(
            Codes.invalidRecord,
            summary: "Imported document contains an invalid record",
            reason: "One row could not be decoded into the expected schema."
        )
        @ErrorRecovery("Fix the highlighted row and retry the import.")
        @ErrorContext(Context.rowNumber)
        @ErrorContext(Context.fieldName)
        @ErrorContext(Context.rawFieldValue, parameter: "rawValue")
        case invalidRecord(rowNumber: Int, fieldName: String, rawValue: String)
    }

    @ErrorModel(domain: DocumentImportDiagnostics.self)
    enum ImportFailure {
        @ErrorCase(
            Codes.invalidDocument,
            summary: "Document import failed",
            reason: "The document contained one or more invalid records."
        )
        @ErrorContext(Context.filePath)
        @ErrorParallelEach(parameter: "rowErrors")
        case invalidDocument(filePath: String, rowErrors: [ImportError])
    }
}

private struct CustomerImporter {
    private let headerValidator = CustomerImportHeaderValidator()
    private let store = CustomerStore()

    func importCustomers(
        from file: ImportFile
    ) throws -> ImportSummary {
        guard file.fileExtension == "csv" else {
            throw DocumentImportDiagnostics.ImportError.unsupportedFileType(
                filePath: file.path,
                fileExtension: file.fileExtension
            )
        }

        try headerValidator.validate(file.headers)

        var customers: [Customer] = []
        var rowErrors: [DocumentImportDiagnostics.ImportError] = []

        for row in file.rows {
            do {
                customers.append(try importCustomer(from: row))
            } catch let error as DocumentImportDiagnostics.ImportError {
                rowErrors.append(error)
            }
        }

        guard rowErrors.isEmpty else {
            throw DocumentImportDiagnostics.ImportFailure.invalidDocument(
                filePath: file.path,
                rowErrors: rowErrors
            )
        }

        store.save(customers)

        return ImportSummary(
            fileName: file.name,
            importedCount: customers.count,
            skippedCount: 0
        )
    }

    private func importCustomer(
        from row: ImportRow
    ) throws -> Customer {
        let email = row.fields["email", default: ""]

        guard email.contains("@") else {
            throw DocumentImportDiagnostics.ImportError.invalidRecord(
                rowNumber: row.number,
                fieldName: "email",
                rawValue: email
            )
        }

        let name = row.fields["name", default: ""]

        guard !name.isEmpty else {
            throw DocumentImportDiagnostics.ImportError.invalidRecord(
                rowNumber: row.number,
                fieldName: "name",
                rawValue: name
            )
        }

        return Customer(name: name, email: email)
    }
}

private struct ImportFile: Hashable {
    var path: String
    var name: String
    var fileExtension: String
    var headers: [String]
    var rows: [ImportRow]
}

private struct ImportRow: Hashable {
    var number: Int
    var fields: [String: String]
}

private struct Customer: Hashable {
    var name: String
    var email: String
}

private struct ImportSummary: Hashable {
    var fileName: String
    var importedCount: Int
    var skippedCount: Int
}

private struct CustomerImportHeaderValidator {
    func validate(
        _ headers: [String]
    ) throws {
        // A real importer would check required headers before decoding rows.
    }
}

private struct CustomerStore {
    func save(
        _ customers: [Customer]
    ) {
        // Persist imported customers and emit a product analytics event.
    }
}

@Suite
struct DocumentImportErrorModelExample {
    @Test
    func unsupportedFileTypeCarriesPublicAndPrivateImportFacts() throws {
        let error = try catchImportError {
            _ = try CustomerImporter().importCustomers(
                from: .init(
                    path: "/Users/example/Customers/private-export.xls",
                    name: "private-export.xls",
                    fileExtension: "xls",
                    headers: [],
                    rows: []
                )
            )
        }
        let context = error.errorContextBindings

        #expect(error._errorIdentity?.domain.rawValue == "com.example.documents.import")
        #expect(error._errorIdentity?.code == "document.unsupported_file_type")
        #expect(context.map(\.key.rawValue) == ["file.path", "file.extension"])
        #expect(context.map(\.value) == [.string("/Users/example/Customers/private-export.xls"), .string("xls")])
        #expect(context.map(\.privacy) == [.private, .public])
        #expect(_AnyErrorCodeCatalog(DocumentImportDiagnostics.Codes.self).allErrorCodes.map(\.stableIdentifier) == [
            "document.unsupported_file_type",
            "document.invalid_record",
            "document.invalid"
        ])
    }

    @Test
    func invalidDocumentPreservesParallelRowFailuresAndPrivacy() throws {
        let error = try catchImportFailure {
            _ = try CustomerImporter().importCustomers(
                from: .init(
                    path: "/Users/example/Customers/export.csv",
                    name: "export.csv",
                    fileExtension: "csv",
                    headers: ["name", "email"],
                    rows: [
                        .init(
                            number: 4,
                            fields: [
                                "name": "Aditi",
                                "email": "not-an-email"
                            ]
                        ),
                        .init(
                            number: 7,
                            fields: [
                                "name": "",
                                "email": "valid@example.com"
                            ]
                        )
                    ]
                )
            )
        }
        let report = _ErrorReporting.report(error)

        #expect(report.headlineIdentity?.code == "document.invalid")
        #expect(report.presentation?.summary == "Document import failed")
        #expect(report.allIdentities.map(\.code) == [
            "document.invalid",
            "document.invalid_record",
            "document.invalid_record"
        ])
        #expect(report.identities(in: .parallel).map(\.code) == [
            "document.invalid_record",
            "document.invalid_record"
        ])
        #expect(report.contextValue(for: DocumentImportDiagnostics.Context.filePath) == .string("/Users/example/Customers/export.csv"))
        #expect(report.contextValues(for: DocumentImportDiagnostics.Context.rowNumber) == [.int(4), .int(7)])
        #expect(report.projectedContextValue(for: DocumentImportDiagnostics.Context.filePath) == nil)
        #expect(report.projectedContextValue(for: DocumentImportDiagnostics.Context.rawFieldValue) == nil)
        #expect(report.projectedContext(using: .allDiagnostic).contains {
            $0.key.rawValue == "field.raw_value"
        })
    }
}

private func catchImportError(
    _ operation: () throws -> Void
) throws -> DocumentImportDiagnostics.ImportError {
    do {
        try operation()
    } catch let error as DocumentImportDiagnostics.ImportError {
        return error
    } catch {
        Issue.record("Unexpected error: \(error)")
    }

    throw DocumentImportExampleFailure.expectedImportError
}

private func catchImportFailure(
    _ operation: () throws -> Void
) throws -> DocumentImportDiagnostics.ImportFailure {
    do {
        try operation()
    } catch let error as DocumentImportDiagnostics.ImportFailure {
        return error
    } catch {
        Issue.record("Unexpected error: \(error)")
    }

    throw DocumentImportExampleFailure.expectedImportFailure
}

private enum DocumentImportExampleFailure: Error {
    case expectedImportError
    case expectedImportFailure
}
