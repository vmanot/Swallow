//
// Copyright (c) Vatsal Manot
//

import Testing

@testable import ErrorX

private enum DatabaseDiagnostics {
  @ErrorCodeCatalog(domain: "com.example.persistence")
  enum Codes: String {
    case uniqueConstraintViolation = "database.unique_constraint_violation"
    case rollbackFailed = "database.rollback_failed"
    case transactionFailed = "database.transaction_failed"
  }

  enum Context {
    static let table = ErrorContext.Key<String>("database.table", privacy: .public)

    static let constraint = ErrorContext.Key<String>("database.constraint", privacy: .public)

    static let rollbackPhase = ErrorContext.Key<String>("database.rollback_phase", privacy: .public)

    static let transactionID = ErrorContext.Key<String>(
      "database.transaction_id", privacy: .private)

    static let invoiceNumber = ErrorContext.Key<String>("invoice.number", privacy: .private)
  }

  @ErrorModel
  enum WriteError {
    @ErrorCode(
      Codes.uniqueConstraintViolation,
      message: "A database uniqueness constraint was violated"
    )
    @ErrorContext(Context.table)
    @ErrorContext(Context.constraint)
    @ErrorContext(Context.invoiceNumber)
    case uniqueConstraintViolation(table: String, constraint: String, invoiceNumber: String)
  }

  @ErrorModel
  enum RollbackError {
    @ErrorCode(Codes.rollbackFailed, message: "Database rollback failed")
    @ErrorContext(Context.rollbackPhase, from: "phase")
    case failed(phase: String)
  }

  @ErrorModel
  enum TransactionError {
    @ErrorCode(
      Codes.transactionFailed,
      message: "Database transaction failed",
      failureReason: "The write failed and the rollback also encountered an error."
    )
    @ErrorContext(Context.transactionID)
    @ErrorRelation(.cause, error: "write")
    @ErrorRelation(.cleanup, error: "rollback")
    @ErrorRecoveryOption("Retry the operation after checking database health.")
    case failed(
      transactionID: String,
      write: WriteError,
      rollback: RollbackError
    )
  }
}

private struct InvoiceRepository {
  func createInvoice(
    number: String
  ) throws {
    let transactionID = "transaction-8F29"

    // A real implementation would begin a transaction and attempt an INSERT.
    let write = DatabaseDiagnostics.WriteError.uniqueConstraintViolation(
      table: "invoices",
      constraint: "invoices_number_unique",
      invoiceNumber: number
    )

    // Rollback is retained as cleanup failure instead of replacing the write failure.
    throw DatabaseDiagnostics.TransactionError.failed(
      transactionID: transactionID,
      write: write,
      rollback: .failed(phase: "rollback")
    )
  }
}

@Suite
struct DatabaseTransactionErrorModelExample {
  @Test
  func cleanupFailureDoesNotReplaceThePrimaryDatabaseFailure() throws {
    let error = try catchTransactionError {
      try InvoiceRepository().createInvoice(number: "INV-2026-0042")
    }
    let report = ErrorReport(error)

    #expect(report.primaryIdentity?.code == "database.transaction_failed")
    #expect(
      report.identities.map(\.code) == [
        "database.transaction_failed",
        "database.unique_constraint_violation",
        "database.rollback_failed",
      ])
    #expect(
      report.identities(relatedBy: .cause).map(\.code) == [
        "database.unique_constraint_violation"
      ])
    #expect(
      report.identities(relatedBy: .cleanup).map(\.code) == [
        "database.rollback_failed"
      ])
    #expect(report.firstError(of: DatabaseDiagnostics.WriteError.self) != nil)
    #expect(report.firstError(of: DatabaseDiagnostics.RollbackError.self) != nil)

    #expect(report.context[DatabaseDiagnostics.Context.transactionID] == "transaction-8F29")
    #expect(report.context.projected()[DatabaseDiagnostics.Context.transactionID] == nil)
    #expect(report.context[DatabaseDiagnostics.Context.invoiceNumber] == "INV-2026-0042")
    #expect(report.context.projected()[DatabaseDiagnostics.Context.invoiceNumber] == nil)
    #expect(report.context.projected()[DatabaseDiagnostics.Context.table] == "invoices")
    #expect(
      report.recoveryOptions.map(\.title) == [
        "Retry the operation after checking database health."
      ])
  }
}

private func catchTransactionError(
  _ operation: () throws -> Void
) throws -> DatabaseDiagnostics.TransactionError {
  do {
    try operation()
  } catch let error as DatabaseDiagnostics.TransactionError {
    return error
  } catch {
    Issue.record("Unexpected error: \(error)")
  }

  throw DatabaseTransactionExampleFailure.expectedTransactionError
}

private enum DatabaseTransactionExampleFailure: Error {
  case expectedTransactionError
}
