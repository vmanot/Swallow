//
// This file contains code originally derived from swift-case-paths
// https://github.com/pointfreeco/swift-case-paths/blob/main/LICENSE
//
// Partially rewritten and reimplemented for performance and functionality reasons
// where direct dependency was not feasible.
//
// Copyright (c) 2020 Point-Free, Inc.
// Copyright (c) 2025 Vatsal Manot
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Swift

extension CasePath where Root == Value {
    /// The identity case path for `Root`: a case path that always successfully extracts a root value.
    public static var `self`: CasePath {
        .init(
            embed: { $0 },
            extract: Optional.some
        )
    }
}

extension CasePath where Root: OptionalProtocol, Value == Root.Wrapped {
    /// The optional case path: a case path that unwraps an optional value.
    public static var some: CasePath {
        .init(
            embed: Root.init,
            extract: { Optional($0) }
        )
    }
}

extension CasePath where Root == Void {
    /// Returns a case path that always successfully extracts the given constant value.
    ///
    /// - Parameter value: A constant value.
    /// - Returns: A case path from `()` to `value`.
    public static func constant(_ value: Value) -> CasePath {
        .init(
            embed: { _ in () },
            extract: { .some(value) }
        )
    }
}

extension CasePath where Value == Never {
    /// The never case path for `Root`: a case path that always fails to extract the a value of the
    /// uninhabited `Never` type.
    public static var never: CasePath {
        func absurd<A>(_ never: Never) -> A {}
        return .init(
            embed: absurd,
            extract: { _ in nil }
        )
    }
}

extension CasePath where Value: RawRepresentable, Root == Value.RawValue {
    /// Returns a case path for `RawRepresentable` types: a case path that attempts to extract a value
    /// that can be represented by a raw value from a raw value.
    public static var rawValue: CasePath {
        .init(
            embed: { $0.rawValue },
            extract: Value.init(rawValue:)
        )
    }
}

extension CasePath where Value: LosslessStringConvertible, Root == String {
    /// Returns a case path for `LosslessStringConvertible` types: a case path that attempts to
    /// extract a value that can be represented by a lossless string from a string.
    public static var description: CasePath {
        .init(
            embed: { $0.description },
            extract: Value.init
        )
    }
}
