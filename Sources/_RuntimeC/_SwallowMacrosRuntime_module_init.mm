//
// Copyright (c) Vatsal Manot
//

#import "_SwallowMacrosRuntime_module_init.h"

@implementation NSObject(_SwallowMacrosClient_module_init)

+ (void)load {
    static _SwallowMacrosClient_module *singleton;
    
    singleton = [[NSClassFromString(@"_SwallowMacrosClient_module") alloc] init];
}

@end
