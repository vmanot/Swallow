//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct _TupleMetadataLayout: _SwiftRuntimeTypeMetadataLayout {
    public struct ElementLayout {
        public var type: Any.Type
        public var offset: Int
    }
    
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var numberOfElements: Int
    public var labelsString: UnsafeMutablePointer<CChar>
    public var elementVector: SwiftRuntimeUnsafeRelativeVector<ElementLayout>
}

extension _SwiftRuntimeTypeMetadata where MetadataLayout == _TupleMetadataLayout {
    func numberOfElements() -> Int {
        return metadata.pointee.numberOfElements
    }
    
    func labels() -> [String] {
        guard Int(bitPattern: metadata.pointee.labelsString) != 0 else {
            return (0..<numberOfElements()).map { a in
                ""
            }
        }
        
        var labels = String(cString: metadata.pointee.labelsString).components(separatedBy: " ")
        
        labels.removeLast()
        
        return labels
    }
    
    func elementLayouts() -> [_TupleMetadataLayout.ElementLayout] {
        let count: Int = numberOfElements()
        
        guard count > 0 else {
            return []
        }
        
        return metadata.mutableRepresentation.pointee.elementVector.vector(count: count)
    }
}
