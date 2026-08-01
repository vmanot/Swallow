//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

private enum DocumentImportDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.documents.import")
  enum Codes: String {
    case unsupportedFileType = "document.unsupported_file_type"
    case invalidRecord = "document.invalid_record"
    case invalidDocument = "document.invalid"
  }

  enum Context {
    static let filePath = ErrorContext.Key<String>("file.path", privacy: .private)

    static let fileExtension = ErrorContext.Key<String>("file.extension", privacy: .public)

    static let rowNumber = ErrorContext.Key<Int>("row.number", privacy: .public)

    static let fieldName = ErrorContext.Key<String>("field.name", privacy: .public)

    static let rawFieldValue = ErrorContext.Key<String>("field.raw_value", privacy: .sensitive)
  }

  @ErrorModel
  enum ImportError {
    @ErrorCode(
      Codes.unsupportedFileType,
      message: "Document type is not supported",
      failureReason: "The importer only accepts CSV documents."
    )
    @ErrorRecoveryOption("Export the document as CSV and try again.")
    @ErrorContext(Context.filePath)
    @ErrorContext(Context.fileExtension)
    case unsupportedFileType(filePath: String, fileExtension: String)

    @ErrorCode(
      Codes.invalidRecord,
      message: "Imported document contains an invalid record",
      failureReason: "One row could not be decoded into the expected schema."
    )
    @ErrorRecoveryOption("Fix the highlighted row and retry the import.")
    @ErrorContext(Context.rowNumber)
    @ErrorContext(Context.fieldName)
    @ErrorContext(Context.rawFieldValue, from: "rawValue")
    case invalidRecord(rowNumber: Int, fieldName: String, rawValue: String)
  }

  @ErrorModel
  enum ImportFailure {
    @ErrorCode(
      Codes.invalidDocument,
      message: "Document import failed",
      failureReason: "The document contained one or more invalid records."
    )
    @ErrorContext(Context.filePath)
    @ErrorRelation(.concurrent, errors: "rowErrors")
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
    let context = ErrorReport(error).context

    #expect(ErrorIdentity(error)?.domain == "com.example.documents.import")
    #expect(ErrorIdentity(error)?.code == "document.unsupported_file_type")
    #expect(context.map(\.key.name) == ["file.path", "file.extension"])
    #expect(
      context.map(\.value) == [
        .string("/Users/example/Customers/private-export.xls"), .string("xls"),
      ])
    #expect(context.map(\.privacy) == [.private, .public])
    #expect(
      DocumentImportDiagnostics.Codes.allCases.map(\.identifier) == [
        "document.unsupported_file_type",
        "document.invalid_record",
        "document.invalid",
      ])
  }

  @Test
  func invalidDocumentPreservesConcurrentRowFailuresAndPrivacy() throws {
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
                "email": "not-an-email",
              ]
            ),
            .init(
              number: 7,
              fields: [
                "name": "",
                "email": "valid@example.com",
              ]
            ),
          ]
        )
      )
    }
    let report = ErrorReport(error)

    #expect(report.primaryIdentity?.code == "document.invalid")
    #expect(report.presentation?.message == "Document import failed")
    #expect(
      report.identities.map(\.code) == [
        "document.invalid",
        "document.invalid_record",
        "document.invalid_record",
      ])
    #expect(
      report.identities(relatedBy: .concurrent).map(\.code) == [
        "document.invalid_record",
        "document.invalid_record",
      ])
    #expect(
      report.context[DocumentImportDiagnostics.Context.filePath]
        == "/Users/example/Customers/export.csv")
    #expect(report.context.values(for: DocumentImportDiagnostics.Context.rowNumber) == [4, 7])
    #expect(report.context.projected()[DocumentImportDiagnostics.Context.filePath] == nil)
    #expect(report.context.projected()[DocumentImportDiagnostics.Context.rawFieldValue] == nil)
    #expect(
      report.context.projected(using: .diagnostic).contains {
        $0.key.name == "field.raw_value"
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
