#import <stdint.h>

void *_get_associated_object_key(void) {
    return __builtin_return_address(0);
}
