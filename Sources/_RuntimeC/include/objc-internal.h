//
//  objc-internal.h
//
//
//  Created by p-x9 on 2024/05/30
//  
//

#ifndef objc_internal_h
#define objc_internal_h

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <objc/runtime.h>

/// https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc-internal.h#L568C1-L575C7
#if __arm64__
// ARM64 uses a new tagged pointer scheme where normal tags are in
// the low bits, extended tags are in the high bits, and half of the
// extended tag space is reserved for unobfuscated payloads.
#   define OBJC_SPLIT_TAGGED_POINTERS 1
#else
#   define OBJC_SPLIT_TAGGED_POINTERS 0
#endif

/// https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc-internal.h#L601C1-L637C7
#if OBJC_SPLIT_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1UL<<63)
#elif OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1UL<<63)
#else
#   define _OBJC_TAG_MASK 1UL
#endif

/// https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc-internal.h#L758
static bool
_objc_isTaggedPointer(const void * _Nullable ptr)
{
    return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}

/// https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/isa.h#L57
# if __arm64__
#   if TARGET_OS_EXCLAVEKIT
#     define ISA_MASK        0xfffffffffffffff8ULL
#     define ISA_MAGIC_MASK  0x0000000000000001ULL
#     define ISA_MAGIC_VALUE 0x0000000000000001ULL
#   elif __has_feature(ptrauth_calls) || TARGET_OS_SIMULATOR
#     define ISA_MASK        0x007ffffffffffff8ULL
#     define ISA_MAGIC_MASK  0x0000000000000001ULL
#     define ISA_MAGIC_VALUE 0x0000000000000001ULL
#   else
#     define ISA_MASK        0x0000000ffffffff8ULL
#     define ISA_MAGIC_MASK  0x000003f000000001ULL
#     define ISA_MAGIC_VALUE 0x000001a000000001ULL
#   endif
# elif __x86_64__
#   define ISA_MASK        0x00007ffffffffff8ULL
#   define ISA_MAGIC_MASK  0x001f800000000001ULL
#   define ISA_MAGIC_VALUE 0x001d800000000001ULL
# endif


// https://github.com/apple-oss-distributions/objc4/blob/01edf1705fbc3ff78a423cd21e03dfc21eb4d780/runtime/objc-vm.h#L43
#if __has_include(<mach/vm_param.h>)
#  include <mach/vm_param.h>

#  define OBJC_VM_MAX_ADDRESS    MACH_VM_MAX_ADDRESS
#elif __arm64__
#if TARGET_OS_EXCLAVEKIT
#  define OBJC_VM_MAX_ADDRESS  0x0000001ffffffff8ULL
#else
#  define OBJC_VM_MAX_ADDRESS  0x00007ffffffffff8ULL
#endif
#else
#  error Unknown platform - please define PAGE_SIZE et al.
#endif


#define COVERING_MASK(type, n) ({                   \
    type mask = 0;                                  \
    while (mask != ~((type)0)) {                    \
        mask = (mask << 1) | 1;                     \
        if ((n & mask) == n) {                      \
            break;                                  \
        }                                           \
    }                                               \
    mask;                                           \
})

#if TARGET_OS_EXCLAVEKIT
// Initialize to value that might hopefully produce recognizable failures if used before properly initialized.
static uintptr_t objc_debug_isa_class_mask() {
    return 0xffff;
}
#else
static const uintptr_t objc_debug_isa_class_mask() {
    return ISA_MASK & COVERING_MASK(uintptr_t, OBJC_VM_MAX_ADDRESS - 1);
}
#endif

static uintptr_t
_objc_cls(const void * _Nullable ptr)
{
    uintptr_t isa = (*(uintptr_t *)ptr);

    if ((isa & ~ISA_MASK) == 0) {
        return isa;
    } else {
        if ((isa & ISA_MAGIC_MASK) == ISA_MAGIC_VALUE) {
            return (isa & ISA_MASK);
        } else {
            return isa;
        }
    }
    return 0;
}

static uintptr_t
_objc_super(Class _Nonnull cls)
{
    Class superCls = class_getSuperclass(cls);
    return (uintptr_t)superCls;
}

#endif /* objc_internal_h */
