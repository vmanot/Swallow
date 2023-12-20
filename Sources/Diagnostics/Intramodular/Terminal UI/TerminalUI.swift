//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Terminal UI.
public enum TerminalUI {
    public enum ASCII {
        
    }
}

extension TerminalUI.ASCII {
    public enum BoxContentAlignment {
        case left
        case center
        case right
    }
}

public func _printEnclosedInASCIIBox(
    _ input: String,
    terminalWidth: Int = 80,
    alignment: TerminalUI.ASCII.BoxContentAlignment = .left
) {
    let horizontalBorder = "+" + String(repeating: "-", count: terminalWidth - 2) + "+"
    let wordWrapWidth = terminalWidth - 4
    
    func wrap(_ text: String, width: Int) -> [String] {
        var lines: [String] = []
        var line = ""
        
        text
            .split(
                separator: " ",
                omittingEmptySubsequences: true
            )
            .forEach { (word: Substring) in
                if word.count > width {
                    // Split the long word itself if it's longer than the wrap width
                    let splitWordIndex = word.index(word.startIndex, offsetBy: width)
                    let firstPart = word[..<splitWordIndex]
                    let secondPart = word[splitWordIndex...]
                    if !line.isEmpty {
                        lines.append(String(line))
                        line = ""
                    }
                    lines.append(String(firstPart)) // Add the first part as a new line
                    line = String(secondPart) // Start with the second part on the next line
                } else if line.count + word.count + 1 > width {
                    lines.append(line)
                    line = String(word)
                } else {
                    line += (line.isEmpty ? "" : " ") + String(word)
                }
            }
        
        if !line.isEmpty {
            lines.append(line)
        }
        
        return lines
    }
    
    func printLine(_ line: String, alignment: TerminalUI.ASCII.BoxContentAlignment) {
        let padding = wordWrapWidth - line.count
        let paddingLeft: Int
        var paddingRight: Int
        
        switch alignment {
            case .left:
                paddingLeft = 0
                paddingRight = padding
            case .center:
                paddingLeft = padding / 2
                paddingRight = padding - paddingLeft
            case .right:
                paddingLeft = padding
                paddingRight = 0
        }
        
        if paddingRight < 0 {
            runtimeIssue(.unexpected)
            
            paddingRight = 0
        }
        
        var paddedLine = "| "
        
        paddedLine += String(repeating: " ", count: paddingLeft) 
        paddedLine += line
        paddedLine += String(repeating: " ", count: paddingRight)
        paddedLine += " |"
        
        print(paddedLine)
    }
    
    let lines = input
        .components(
            separatedBy: .newlines
        ).flatMap {
            wrap($0, width: wordWrapWidth)
        }
    
    print(horizontalBorder)
    
    lines.forEach {
        printLine($0, alignment: alignment)
    }
    
    print(horizontalBorder)
}
