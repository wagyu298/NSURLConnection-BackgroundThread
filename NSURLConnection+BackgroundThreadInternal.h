// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import "NSURLConnection+BackgroundThread.h"

@interface NSURLConnection (BackgroundThreadInternal)

+ (void)incrementBackgroundThreadConnectionCount;
+ (void)decrementBackgroundThreadConnectionCount;

@end