//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension ObjCBool: ObjCTypeEncodable {
    public static let objCTypeEncoding = ObjCTypeEncoding("B")
}

extension Selector: ObjCTypeEncodable {
    public static let objCTypeEncoding = ObjCTypeEncoding(":")
}
