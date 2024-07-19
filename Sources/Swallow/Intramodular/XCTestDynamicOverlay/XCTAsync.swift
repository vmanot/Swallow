//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@_transparent
public func XCTAssertNoThrowAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        XCTFail(message() ?? String(describing: error))
    }
}

@_transparent
public func XCTAssertNoThrowAsync<T>(
    _ operation: () async throws -> T,
    _ message: @autoclosure () -> String? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    await XCTAssertNoThrowAsync(try await operation(), message(), file: file, line: line)
}

@_transparent
public func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "Failed to throw an error.",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        
        XCTFail()
    } catch {
        errorHandler(error)
    }
}

@_transparent
public func XCTAssertThrowsErrorAsync<T>(
    _ operation: () async throws -> T,
    _ message: @autoclosure () -> String = "Failed to throw an error.",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    await XCTAssertThrowsErrorAsync(try await operation(), message(), file: file, line: line)
}

/*@inlinable
 public func XCTAssertEqualAsync<T>(
 _ expression1: @autoclosure () async throws -> T,
 _ expression2: @autoclosure () async throws -> T,
 _ message: @autoclosure () -> String = "",
 file: StaticString = #filePath,
 line: UInt = #line
 ) async where T: Equatable {
 let expression1 = await expand(expression1)
 let expression2 = await expand(expression2)
 try? { XCTAssertEqual(try expression1(), try expression2(), message(), file: file, line: line) }()
 }
 
 @inlinable
 public func XCTAssertEqualAsync<T>(
 _ lhs: @autoclosure () async throws -> T,
 _ rhs: () async throws -> T,
 _ message: @autoclosure () -> String = "",
 file: StaticString = #filePath,
 line: UInt = #line
 ) async where T: Equatable {
 let expression1 = await expand(lhs)
 let expression2 = await expand(rhs)
 
 XCTAssertEqual(try expression1(), try expression2(), message(), file: file, line: line)
 }
 
 @inlinable
 public func XCTAssertEqualAsync<T>(
 _ expression1: @autoclosure () async throws -> T,
 _ expression2: @autoclosure () async throws -> T,
 accuracy: T,
 _ message: @autoclosure () -> String = "",
 file: StaticString = #filePath,
 line: UInt = #line
 ) async where T : FloatingPoint {
 let expression1 = await expand(expression1)
 let expression2 = await expand(expression2)
 try? { XCTAssertEqual(try expression1(), try expression2(), accuracy: accuracy, message(), file: file, line: line) }()
 }
 */
