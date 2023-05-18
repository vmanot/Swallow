//
// Copyright (c) Vatsal Manot
//

import Foundation

extension NSCoding {
    public func archiveUsingKeyedArchiver() throws -> Data {
        try NSKeyedArchiver.archivedData(
            withRootObject: self,
            requiringSecureCoding: (type(of: self) as? NSSecureCoding.Type)?.supportsSecureCoding ?? false
        )
    }
    
    public static func unarchiveUsingKeyedUnarchiver(from data: Data) throws -> Self {
        try self.init(coder: try NSKeyedUnarchiver(forReadingFrom: data)).unwrap()
    }
}
