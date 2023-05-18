//
// Copyright (c) Vatsal Manot
//

#import "RuntimeShims.h"

NSException* __nullable catchExceptionOfKind(Class __nonnull type, void (^ NS_NOESCAPE __nonnull inBlock)(void)) {
	@try {
		inBlock();
	} @catch (NSException *exception) {
		if ([exception isKindOfClass:type]) {
			return exception;
		} else {
			@throw;
		}
	}
	return nil;
}
