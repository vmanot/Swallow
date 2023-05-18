//
// Copyright (c) Vatsal Manot
//

import Foundation

func * <T:StringProtocol> (str: T, n: Int) -> String {
    repeatElement(str, count: n > 0 ? n : 0).joined()
}

func * <T:StringProtocol> (n: Int, str: T) -> String {
    str * n
}

func * (str: String, n: Int) -> String {
    String(repeating: str, count: n > 0 ? n : 0)
}

func * (n: Int, str: String) -> String {
    str * n
}

func * (char: Character, n: Int) -> String {
    String(repeating: char, count: n > 0 ? n : 0)
}

func * (n: Int, char: Character) -> String {
    return char * n
}

func *= (str: inout String, n: Int) {
    str = str * n
}
