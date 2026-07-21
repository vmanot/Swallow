//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwallowMacrosClient
import Testing

@AddCaseBoolean
enum MacroCompatibilityPayload {
    case value(Int)
    case empty
}

@Singleton
final class MacroCompatibilitySingleton {

}

@OptionSet<Int>
struct MacroCompatibilityOptions {
    enum Options: Int {
        case first
        case second
    }
}

@Hashable
struct MacroCompatibilityHashable {
    var value: Int
}

final class MacroCompatibilityAssociatedObject: NSObject {
    @AssociatedObject(.retain(.nonatomic))
    var value: String?
}

@Suite
struct ExistingMacroCompatibilityTests {
    @duplicate(as: "macroCompatibilityForwarded")
    static func macroCompatibilityOriginal(
        external local: Int,
        mutate value: inout Int
    ) {
        value += local
    }

    @Test
    func changedLegacyMacrosStillGenerateUsableSwift() {
        #expect(MacroCompatibilityPayload.value(1).isValue)
        #expect(!MacroCompatibilityPayload.empty.isValue)
        #expect(MacroCompatibilitySingleton.shared === MacroCompatibilitySingleton.shared)
        #expect(MacroCompatibilityOptions.first.rawValue == 1)
        #expect(MacroCompatibilityOptions.second.rawValue == 2)
        #expect(MacroCompatibilityHashable(value: 1) == MacroCompatibilityHashable(value: 1))

        let object = MacroCompatibilityAssociatedObject()
        #expect(object.value == nil)
        object.value = "value"
        #expect(object.value == "value")

        var value: Int = 2
        Self.macroCompatibilityForwarded(external: 3, mutate: &value)
        #expect(value == 5)
    }
}
