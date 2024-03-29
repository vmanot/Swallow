//
// Copyright (c) Vatsal Manot
//

#import <Foundation/Foundation.h>

@interface _SwallowMacrosClient_module: NSObject
@end

@implementation NSObject(_SwallowMacrosClient_module_init)

/// This will be called as soon as the package is loaded into memory.
+ (void)load {
    static _SwallowMacrosClient_module *singleton;
    singleton = [[NSClassFromString(@"_SwallowMacrosClient_module") alloc] init];
}

@end
