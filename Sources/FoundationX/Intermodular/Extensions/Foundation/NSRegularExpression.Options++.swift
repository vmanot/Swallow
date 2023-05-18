//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSRegularExpression.Options {
    public var modifiers: [Character] {
        var result: [Character] = []
        
        switch self {
            case .caseInsensitive:
                result.append("i")
            case .allowCommentsAndWhitespace:
                result.append("x")
            case .ignoreMetacharacters:
                result.append("U")
            case .dotMatchesLineSeparators:
                result.append("s")
            case .anchorsMatchLines:
                result.append("m")
            case .useUnixLineSeparators:
                result.append("d")
            case .useUnicodeWordBoundaries:
                result.append("u")
            default:
                break
        }
        
        return result
    }
    
    public init?(modeModifier: Character) {
        switch modeModifier {
            case "d":
                self = .useUnixLineSeparators
            case "i":
                self = .caseInsensitive
            case "x":
                self = .allowCommentsAndWhitespace
            case "m":
                self = .anchorsMatchLines
            case "s":
                self = .dotMatchesLineSeparators
            case "u":
                self = .useUnicodeWordBoundaries
            case "U":
                self = .ignoreMetacharacters
                
            default:
                return nil
        }
    }
}
