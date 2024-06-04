//
// Copyright (c) Vatsal Manot
//

#import "Swallow_module_init.h"

@implementation NSObject(_SwallowMacros_module_init)

+ (void)load {
    static _SwallowMacros_module *singleton;
    
    singleton = [[NSClassFromString(@"_SwallowMacros_module") alloc] init];
}

@end
