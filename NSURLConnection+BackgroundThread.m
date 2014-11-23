// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import "NSURLConnection+BackgroundThreadInternal.h"
#import "BTNSURLConnectionDelegateWrapper.h"

#ifndef NSURLCONNECTION_BACKGROUNDTHREAD_MAX_OPERATION_COUNT
#define NSURLCONNECTION_BACKGROUNDTHREAD_MAX_OPERATION_COUNT 6
#endif

static int backgroundConnectionCount = 0;
static NSOperationQueue *queue = nil;
static dispatch_semaphore_t semaphore = NULL;

static void
init()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        semaphore = dispatch_semaphore_create(0);
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = NSURLCONNECTION_BACKGROUNDTHREAD_MAX_OPERATION_COUNT;
    });
}

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
    BTNSURLConnectionDelegateWrapper *wrappedDelegate = [[BTNSURLConnectionDelegateWrapper alloc] initWithDelegate:delegate];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:wrappedDelegate startImmediately:NO];
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
    [class incrementBackgroundThreadConnectionCount];
    [class sendAsynchronousRequest:request queue:[class operationQueueForBackgroundThread] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [class decrementBackgroundThreadConnectionCount];
        handler(response, data, connectionError);
    }];
}

+ (NSOperationQueue *)operationQueueForBackgroundThread
{
    init();
    return queue;
}

+ (void)waitUntilAllBackgroundThreadConnectionsAreFinished
{
    while ([NSURLConnection backgroundThreadConnectionCount] > 0) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)));
    }
}

+ (NSInteger)backgroundThreadConnectionCount
{
    NSOperationQueue *queue = [NSURLConnection operationQueueForBackgroundThread];
    @synchronized(queue) {
        return backgroundConnectionCount;
    }
}

@end

@implementation NSURLConnection (BackgroundThreadInternal)

+ (void)incrementBackgroundThreadConnectionCount
{
    NSOperationQueue *queue = [NSURLConnection operationQueueForBackgroundThread];
    @synchronized(queue) {
        backgroundConnectionCount++;
    }
}

+ (void)decrementBackgroundThreadConnectionCount
{
    NSOperationQueue *queue = [NSURLConnection operationQueueForBackgroundThread];
    @synchronized(queue) {
        backgroundConnectionCount--;
        dispatch_semaphore_signal(semaphore);
    }
}

@end
