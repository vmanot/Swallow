//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSValue {
    public var objCTypeEncoding: ObjCTypeEncoding {
        return ObjCTypeEncoding(String(cString: objCType))
    }

    public convenience init(_ data: Data, encoding: ObjCTypeEncoding) {
        self.init(bytes: (data as NSData).bytes, objCType: encoding.value)
    }
}
