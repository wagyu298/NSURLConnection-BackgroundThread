// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>

@interface NSURLConnection (BackgroundThread)

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate background:(BOOL)background;
- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate background:(BOOL)background;
- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately background:(BOOL)background;

+ (void)sendAsynchronousRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))handler;

+ (NSOperationQueue *)operationQueueForBackgroundThread;
+ (void)waitUntilAllBackgroundThreadConnectionsAreFinished;
+ (NSInteger)backgroundThreadConnectionCount;

@end
