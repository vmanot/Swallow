//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TreeProtocol {
    public func dumpTree(
        descriptionForValue: (Any) -> String = { (String(describing: $0)) }
    ) -> String {
        _dumpTree(descriptionForValue: descriptionForValue)
    }
    
    private func _dumpTree(
        descriptionForValue: (Any) -> String,
        indentation: String = "",
        isLastChild: Bool = true
    ) -> String {
        var result = ""
        let prefix: String
        
        result += "\(descriptionForValue(value))\n"
        
        if isLastChild {
            prefix = "\(indentation)└── "
        } else {
            prefix = "\(indentation)├── "
        }
        
        let childIndentation = isLastChild ? indentation + "    " : indentation + "│   "
        
        for (index, child) in children.enumerated() {
            let childDump = child._dumpTree(
                descriptionForValue: descriptionForValue,
                indentation: childIndentation,
                isLastChild: index == children.underestimatedCount - 1
            )
            
            result += "\(prefix)\(childDump)"
        }
        
        return result
    }
}
