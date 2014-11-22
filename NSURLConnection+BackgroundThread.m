// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import "NSURLConnection+BackgroundThread.h"

#ifndef NSURLCONNECTION_BACKGROUNDTHREAD_MAX_OPERATION_COUNT
#define NSURLCONNECTION_BACKGROUNDTHREAD_MAX_OPERATION_COUNT 6
#endif

@implementation NSURLConnection (BackgroundThread)

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate background:(BOOL)background
{
    return [[NSURLConnection alloc] initWithRequest:request delegate:delegate background:background];
}

- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate background:(BOOL)background
{
    return [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES background:background];
}

- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately background:(BOOL)background
{
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    if (conn) {
        NSOperationQueue *queue = [[self class] operationQueueForBackgroundThread];
        [conn setDelegateQueue:queue];
        if (startImmediately) {
            [conn start];
        }
    }
    return conn;
}

+ (void)sendAsynchronousRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))handler
{
    Class class = [self class];
    [class sendAsynchronousRequest:request queue:[class operationQueueForBackgroundThread] completionHandler:handler];
}

+ (NSOperationQueue *)operationQueueForBackgroundThread
{
    static NSOperationQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = NSURLCONNECTION_BACKGROUNDTHREAD_MAX_OPERATION_COUNT;
    });
    return queue;
}

@end
