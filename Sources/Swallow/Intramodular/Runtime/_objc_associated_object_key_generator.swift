//
// Copyright (c) Vatsal Manot
//

internal import _RuntimeC
import Swift

public final class _objc_associated_object_key_generator {
    public static func _generate_associated_object_key() -> UnsafeRawPointer {
        return UnsafeRawPointer(_RuntimeC._get_associated_object_key()!)
    }
}
