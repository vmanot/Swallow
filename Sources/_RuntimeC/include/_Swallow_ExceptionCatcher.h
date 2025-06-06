@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface _Swallow_ExceptionCatcher: NSObject

+ (BOOL)catchException:(__attribute__((noescape)) void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

NS_ASSUME_NONNULL_END
