//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct Version: Sendable {
    public static var zero: Version {
        .init(major: 0, minor: nil, patch: nil, prerelease: nil, build: nil)
    }
    
    fileprivate static let strictParser = VersionParser(strict: true)
    fileprivate static let lenientParser = VersionParser(strict: false)
    
    /// The major component of the version.
    ///
    /// - Note:
    /// > Increment the MAJOR version when you make incompatible API changes.
    ///
    public var major: Int
    
    /// An optional minor component of the version.
    ///
    /// - Note:
    /// > Increment the MINOR version when you add functionality in a backwards-compatible manner.
    ///
    public var minor: Int?
    
    /// Canonicalized form of minor component of the version.
    ///
    public var canonicalMinor: Int {
        return self.minor ?? 0
    }
    
    /// An optional patch component of the version.
    ///
    /// - Note:
    /// > Increment the PATCH version when make backwards-compatible bug fixes.
    ///
    public var patch: Int?
    
    /// Canonicalized form of patch component of the version.
    ///
    public var canonicalPatch: Int {
        return self.patch ?? 0
    }
    
    /// An optional prerelease component of the version.
    ///
    /// - Note:
    /// > A pre-release version MAY be denoted by appending a hyphen and a series of dot separated
    /// > identifiers immediately following the patch version. Identifiers MUST comprise only ASCII
    /// > alphanumerics and hyphen [0-9A-Za-z-]. Identifiers MUST NOT be empty. Numeric identifiers
    /// > MUST NOT include leading zeroes. Pre-release versions have a lower precedence than the
    /// > associated normal version. A pre-release version indicates that the version is unstable
    /// > and might not satisfy the intended compatibility requirements as denoted by its associated
    /// > normal version.
    ///
    /// #### Examples:
    ///
    ///    * `1.0.0-alpha`
    ///    * `1.0.0-alpha.1`
    ///    * `1.0.0-0.3.7`
    ///    * `1.0.0-x.7.z.92`
    ///
    public var prerelease: String?
    
    /// An optional build component of the version.
    public var build: String?
    
    /// Initialize a version from its components.
    public init(
        major: Int = 0,
        minor: Int? = nil,
        patch: Int? = nil,
        prerelease: String? = nil,
        build: String? = nil
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
    }
    
    /// Initialize a version from its string representation.
    public init!(_ value: String) {
        do {
            let parser = VersionParser(strict: false)
            self = try parser.parse(string: value)
        } catch let error {
            debugPrint("Error: Failed to parse version number '\(value)': \(error)")
            
            return nil
        }
    }
    
    /// Canonicalize version by replacing nil components with their defaults
    public mutating func canonicalize() {
        self.minor = self.minor ?? 0
        self.patch = self.patch ?? 0
    }
    
    /// Create canonicalized copy
    public func canonicalized() -> Version {
        var copy = self
        copy.canonicalize()
        return copy
    }
    
    fileprivate static func compare<T: Comparable>(lhs: T, rhs: T) -> ComparisonResult {
        if lhs < rhs {
            return .orderedAscending
        } else if lhs > rhs {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
    
    fileprivate static func compareNumeric(lhs: String, rhs: String) -> ComparisonResult {
        let lhsComponents = lhs.components(separatedBy: ".")
        let rhsComponents = rhs.components(separatedBy: ".")
        let comparables = zip(lhsComponents, rhsComponents)
        let firstDifferentComponent = comparables.first { $0.0 != $0.1 }
        if let (l, r) = firstDifferentComponent {
            let regex = Version.lenientParser.numberRegex
            if l.matches(regex) && r.matches(regex) {
                return self.compare(lhs: Int(l) ?? 0, rhs: Int(r) ?? 0)
            } else {
                return self.compare(lhs: l, rhs: r)
            }
        }
        if lhsComponents.count != rhsComponents.count {
            return self.compare(lhs: lhsComponents.count, rhs: rhsComponents.count)
        }
        return .orderedSame
    }
}

extension Version {
    public static func valid(string: String, strict: Bool = false) -> Bool {
        return string.matches(Version.strictParser.versionRegex)
    }
}

// MARK: - Conformances

extension Version: Codable {
    
}

extension Version: Comparable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        let majorComparison = Version.compare(lhs: lhs.major, rhs: rhs.major)
        let minorComparison = Version.compare(lhs: lhs.canonicalMinor, rhs: rhs.canonicalMinor)
        let patchComparison = Version.compare(lhs: lhs.canonicalPatch, rhs: rhs.canonicalPatch)
        
        if majorComparison != .orderedSame {
            return majorComparison == .orderedAscending
        }
        
        if minorComparison != .orderedSame {
            return minorComparison == .orderedAscending
        }
        
        if patchComparison != .orderedSame {
            return patchComparison == .orderedAscending
        }
        
        switch (lhs.prerelease, rhs.prerelease) {
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return false
            case (.some(let lpre), .some(let rpre)):
                return Version.compareNumeric(lhs: lpre, rhs: rpre) == .orderedAscending
        }
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        let components = [
            "\(major)",
            minor != nil ? ".\(minor!)" : "",
            patch != nil ? ".\(patch!)" : "",
            prerelease != nil ? "-\(prerelease!)" : "",
            build != nil ? "+\(build!)" : ""
        ]
        
        return components.joined(separator: "")
    }
}

extension Version: Equatable {
    public static func == (lhs: Version, rhs: Version) -> Bool {
        let equalMajor = lhs.major == rhs.major
        let equalMinor = lhs.canonicalMinor == rhs.canonicalMinor
        let equalPatch = lhs.canonicalPatch == rhs.canonicalPatch
        let equalPrerelease = lhs.prerelease == rhs.prerelease
        
        return equalMajor && equalMinor && equalPatch && equalPrerelease
    }
    
    public static func === (lhs: Version, rhs: Version) -> Bool {
        return (lhs == rhs) && (lhs.build == rhs.build)
    }
    
    public static func !== (lhs: Version, rhs: Version) -> Bool {
        return !(lhs === rhs)
    }
}

extension Version: ExpressibleByStringLiteral {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension Version: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(canonicalMinor)
        hasher.combine(canonicalPatch)
        hasher.combine(prerelease?.hashValue ?? 0)
    }
}

// MARK: - Supplementary

extension Bundle {
    /// The marketing version number of the bundle.
    public var version: Version? {
        #if os(Linux)
        return nil
        #else
        return try? parseVersion(forInfoDictionaryKey: String(kCFBundleVersionKey))
        #endif
    }
    
    /// The short version number of the bundle.
    public var shortVersion: Version? {
        try? parseVersion(forInfoDictionaryKey: "CFBundleShortVersionString")
    }
    
    private func parseVersion(forInfoDictionaryKey key: String) throws -> Version? {
        guard let bundleVersion = infoDictionary?[key] as? String else {
            return nil
        }
        
        return try Version.lenientParser.parse(string: bundleVersion)
    }
}

extension ProcessInfo {
    /// The version of the operating system on which the process is executing.
    public var operationSystemVersion: Version {
        return Version(
            major: operatingSystemVersion.majorVersion,
            minor: operatingSystemVersion.minorVersion,
            patch: operatingSystemVersion.patchVersion
        )
    }
}
