//
// Copyright (c) Vatsal Manot
//

#include <TargetConditionals.h>

__attribute__((swiftcall))
extern void *_get_associated_object_key(void) {
    return __builtin_return_address(0);
}
