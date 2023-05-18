//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

#if canImport(UIKit)

import UIKit

extension Collection where Element: Collection, Index == Int, Element.Index == Int {
    public subscript(_ indexPath: IndexPath) -> Element.Element {
        return self[indexPath.section][indexPath.row]
    }
}

extension MutableCollection where Element: MutableCollection, Index == Int, Element.Index == Int {
    public subscript(_ indexPath: IndexPath) -> Element.Element {
        get {
            return self[indexPath.section][indexPath.row]
        } set {
            self[indexPath.section][indexPath.row] = newValue
        }
    }
}

#endif
