//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

private enum VersionParserError: Error {
    case missingMinorComponent
    case missingPatchComponent
    case invalidComponents
    case invalidMajorComponent
    case invalidMinorComponent
    case invalidPatchComponent
}

public struct VersionParser {
    static func versionPattern(strict: Bool, anchored: Bool) -> RegularExpression {
        let number = VersionParser.numberPatternString(strict: strict)
        let version: String
        if strict {
            version = "(\(number))\\.(\(number))\\.(\(number))"
        } else {
            version = "(\(number))(?:\\.(\(number)))?(?:\\.(\(number)))?"
        }
        let prerelease = "(?:-([0-9A-Za-z-.]+))?(?:\\+([0-9A-Za-z-]+))?"
        let pattern: String
        if anchored {
            pattern = "\\A\(version + prerelease)?\\z"
        } else {
            pattern = version + prerelease
        }
        return RegularExpression(pattern: pattern)
    }
    
    private static func numberPatternString(strict: Bool) -> String {
        if strict {
            return "0|[1-9][0-9]*"
        } else {
            return "[0-9]+"
        }
    }
    
    static func numberPattern(strict: Bool, anchored: Bool) -> RegularExpression {
        let numberPattern = VersionParser.numberPatternString(strict: strict)
        let pattern: String
        if anchored {
            pattern = "\\A\(numberPattern)?\\z"
        } else {
            pattern = numberPattern
        }
        return RegularExpression(pattern: pattern)
    }
    
    let strict: Bool
    let versionRegex: RegularExpression
    let numberRegex: RegularExpression
    
    public init(strict: Bool = true) {
        self.strict = strict
        self.versionRegex = VersionParser.versionPattern(strict: self.strict, anchored: true)
        self.numberRegex = VersionParser.numberPattern(strict: self.strict, anchored: true)
    }
    
    public func parse(string: String) throws -> Version {
        try parse(components: string.strings(firstCapturedBy: versionRegex))
    }
    
    public func parse(components: [String?]) throws -> Version {
        var version = Version()
        
        if components.count != 6 {
            throw VersionParserError.invalidComponents
        }
        
        if self.strict {
            if components[2] == nil {
                throw VersionParserError.missingMinorComponent
            } else if components[3] == nil {
                throw VersionParserError.missingPatchComponent
            }
        }
        
        let majorComponent = components[1]
        let minorComponent = components[2]
        let patchComponent = components[3]
        
        if let major = majorComponent.flatMap({ Int($0) }) {
            version.major = major
        } else {
            throw VersionParserError.invalidMajorComponent
        }
        
        if let minor = minorComponent.flatMap({ Int($0) }) {
            version.minor = minor
        } else if minorComponent != nil {
            throw VersionParserError.invalidMinorComponent
        }
        
        if let patch = patchComponent.flatMap({ Int($0) }) {
            version.patch = patch
        } else if patchComponent != nil {
            throw VersionParserError.invalidPatchComponent
        }
        
        version.prerelease = components[4]
        version.build = components[5]
        
        return version
    }
}
