//
//  ptrauth_util.h
//  
//
//  Created by p-x9 on 2024/05/31
//  
//

#ifndef ptrauth_util_h
#define ptrauth_util_h

#if __has_include(<ptrauth.h>) & defined(__arm64e__)
#include <ptrauth.h>

const void *__ptrauth_strip_function_pointer(const void *ptr) {
  return ptrauth_strip(ptr, ptrauth_key_function_pointer);
}

#endif

#endif /* ptrauth_util_h */
