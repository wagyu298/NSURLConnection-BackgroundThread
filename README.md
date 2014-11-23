NSURLConnection (BackgroundThread)
==================================

A small helper collection for background threaded NSURLConnection.

Usage
=====

Clone this repository and copy `*.h` and `*.m` files to your XCode project.

Lincense
========

Public domain ([unlicense](http://unlicense.org)).

Collection Methods
==================

### NSURLConnection connectionWithRequest:delegate:background:

Returns NSURLConnection object and bind NSOperationQueue to the connection if background argument is `YES`, otherwise this method is same as [`NSURLConnection connectionWithRequest:delegate:`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/index.html#//apple_ref/occ/clm/NSURLConnection/connectionWithRequest:delegate:).

#### Prototype

```objc
+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request
                                  delegate:(id)delegate
                                background:(BOOL)background
```

### NSURLConnection initWithRequest:delegate:background:

Returns initialized NSURLConnection object and bind NSOperationQueue to the connection if background argument is `YES`, otherwise this method is same as [`NSURLConnection initWithRequest:delegate:`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/index.html#//apple_ref/occ/instm/NSURLConnection/initWithRequest:delegate:).

#### Prototype

```objc
- (instancetype)initWithRequest:(NSURLRequest *)request
                       delegate:(id)delegate
                     background:(BOOL)background
```

### NSURLConnection initWithRequest:delegate:startImmediately:background:

Returns initialized NSURLConnection object and bind NSOperationQueue to the connection if background argument is `YES`, otherwise this method is same as [`NSURLConnection initWithRequest:delegate:startImmediately:`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/index.html#//apple_ref/occ/instm/NSURLConnection/initWithRequest:delegate:startImmediately:).

#### Prototype

```objc
- (instancetype)initWithRequest:(NSURLRequest *)request
                       delegate:(id)delegate
               startImmediately:(BOOL)startImmediately
                     background:(BOOL)background
```

### NSURLConnection sendAsynchronousRequest:completionHandler:

Loads the data for a URL request and executes a handler block in backgrond thread. See [`NSURLConnection sendAsynchronousRequest:queue:handler:`](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/index.html#//apple_ref/occ/clm/NSURLConnection/sendAsynchronousRequest:queue:completionHandler:) for more details.

#### Prototype

```objc
+ (void)sendAsynchronousRequest:(NSURLRequest *)request
              completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))handler
```

### NSURLConnection operationQueueForBackgroundThread

Returns NSOperationQueue for this collection.

#### Prototype

```objc
+ (NSOperationQueue *)operationQueueForBackgroundThread
```

### NSURLConnection waitUntilAllBackgroundThreadConnectionsAreFinished

Blocks the current thread until all of the background thraded NSURLConnections finish executing.

#### Prototype

```objc
+ (void)operationQueueForBackgroundThread
```

#### Usage

Add the following codes to AppDelegate to wait until all background threaded connections are finsished at the Applicate enter to the background.

```objc
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSURLConnection waitUntilAllBackgroundThreadConnectionsAreFinished];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
```
