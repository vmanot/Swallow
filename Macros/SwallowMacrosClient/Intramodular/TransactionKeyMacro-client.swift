//
//  File.swift
//  Swallow
//
//  Created by Yasir on 05/05/25.
//

import Foundation

@attached(accessor, names: named(get), named(set))
@attached(peer, names: arbitrary)
public macro TransactionKey() = #externalMacro(module: "SwallowMacros", type: "TransactionKeyMacro")
