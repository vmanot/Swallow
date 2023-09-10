//
// Copyright (c) Vatsal Manot
//

import Swift

extension Result {
    public func compact<T>() -> Result<T, Failure>? where Success == T? {
        switch self {
            case .success(let value):
                return value.map(Result<T, Failure>.success)
            case .failure(let error):
                return .failure(error)
        }
    }
    
    public func flatMap<T>(_ transform: ((Success) throws -> T?)) rethrows -> Result<T, Failure>? {
        switch self {
            case .success(let value):
                return try transform(value).map({ .success($0) })
            case .failure(let value):
                return .failure(value)
        }
    }
    
    public func map<T>(_ transform: ((Success) throws -> T)) rethrows -> Result<T, Failure> {
        return try mapSuccess(transform)
    }
    
    public func mapSuccess<T>(_ transform: ((Success) throws -> T)) rethrows -> Result<T, Failure> {
        return .init(try eitherValue.map(transform, id))
    }
    
    public func mapFailure<T>(_ transform: ((Failure) throws -> T)) rethrows -> Result<Success, T> {
        return .init(try eitherValue.map(id, transform))
    }
    
    public func get() -> Success where Failure == Never {
        switch self {
            case .success(let value):
                return value
            case .failure:
                fatalError()
        }
    }
    
    public func get() -> Success.WrappedValue where Success: PropertyWrapper, Failure == Never {
        switch self {
            case .success(let value):
                return value.wrappedValue
            case .failure:
                fatalError()
        }
    }
}

extension Result where Failure == Error {
    public init(catching body: () async throws -> Success) async {
        do {
            let success = try await body()
            
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
    
    public init?(catching body: () async throws -> Success?) async {
        do {
            guard let success = try await body() else {
                return nil
            }
            
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
    
    public init(_ value: @autoclosure () throws -> Success) {
        self.init(catching: value)
    }
    
    public init(
        _ value: @autoclosure () throws -> Success,
        or otherValue: @autoclosure () throws -> Success
    ) {
        do {
            self = .success(try value())
        } catch {
            self.init(catching: otherValue)
        }
    }
    
    public static func fromEither(
        _ first: () throws -> Success,
        or second: () throws -> Success
    ) throws -> Self {
        do {
            return Self.success(try first())
        } catch {
            return Self(catching: { try second() })
        }
    }
    
    public static func from(
        _ first: () throws -> Success,
        or second: () throws -> Success,
        or third: () throws -> Success
    ) throws -> Self {
        do {
            return Self.success(try first())
        } catch {
            do {
                return Self.success(try second())
            } catch {
                return Self(catching: { try third() })
            }
        }
    }
    
    public static func from(
        _ first: () throws -> Success,
        or second: () throws -> Success,
        or third: () throws -> Success,
        or fourth: () throws -> Success
    ) throws -> Self {
        do {
            return Self.success(try first())
        } catch {
            do {
                return Self.success(try second())
            } catch {
                do {
                    return Self.success(try third())
                } catch {
                    return Self(catching: { try fourth() })
                }
            }
        }
    }
    
    public static func from(
        _ first: () throws -> Success,
        or second: () throws -> Success,
        or third: () throws -> Success,
        or fourth: () throws -> Success,
        or fifth: () throws -> Success
    ) throws -> Self {
        do {
            return Self.success(try first())
        } catch {
            do {
                return Self.success(try second())
            } catch {
                do {
                    return Self.success(try third())
                } catch {
                    do {
                        return Self.success(try fourth())
                    } catch {
                        return Self(catching: { try fifth() })
                    }
                }
            }
        }
    }
    
    public init?(_ value: @autoclosure () throws -> Success?) {
        do {
            if let value = try value() {
                self = .success(value)
            } else {
                return nil
            }
        } catch {
            self = .failure(error)
        }
    }
    
    public init(_ value: Success, error: Error?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(value)
        }
    }
    
    public init?(_ value: Success?, error: Error?) {
        if let error = error {
            self = .failure(error)
        } else if let value = value {
            self = .success(value)
        } else {
            return nil
        }
    }
}

extension Result where Failure == Error {
    public func compactFlatMap<T>(_ transform: ((Success) throws -> Result<T, Error>?)) rethrows -> Result<T, Error>? {
        switch self {
            case .success(let value):
                return try transform(value)
            case .failure(let error):
                return .failure(error)
        }
    }
    
    public func compactMap<T>(_ transform: ((Success) throws -> T?)) -> Result<T, Error>? {
        switch self {
            case .success(let value):
                do {
                    if let transformed = try transform(value) {
                        return .success(transformed)
                    } else {
                        return nil
                    }
                } catch {
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
        }
    }
    
    public func filter(_ predicate: ((Success) throws -> Bool)) -> Result? {
        switch self {
            case .success(let value):
                do {
                    return try predicate(value) ? self : nil
                } catch {
                    return .failure(error)
                }
            case .failure:
                return self
        }
    }
    
    public mutating func mutate(_ mutate: ((inout Success) throws -> Void)) {
        switch self {
            case .success(var value):
                do {
                    try mutate(&value)
                    self = .success(value)
                } catch {
                    self = .failure(error)
                }
            case .failure:
                break
        }
    }
}

extension Result {
    public static func == (lhs: Self, rhs: _ResultComparison) -> Bool {
        switch (lhs, rhs) {
            case (.success, .success):
                return true
            case (.failure, .failure):
                return true
            default:
                return false
        }
    }
    
    public static func != (lhs: Self, rhs: _ResultComparison) -> Bool {
        !(lhs == rhs)
    }
}

extension Optional {
    public static func == <T, U>(
        lhs: Self, rhs: _ResultComparison
    ) -> Bool where Wrapped == Result<T, U> {
        guard let lhs else {
            return false
        }
        
        switch (lhs, rhs) {
            case (.success, .success):
                return true
            case (.failure, .failure):
                return true
            default:
                return false
        }
    }
}

// MARK: - Auxiliary

public enum _ResultComparison {
    case success
    case failure
}
