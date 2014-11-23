// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <objc/runtime.h>
#import "NSURLConnection+BackgroundThreadInternal.h"
#import "BTNSURLConnectionDelegateWrapper.h"

@implementation BTNSURLConnectionDelegateWrapper

- (id)initWithDelegate:(id <NSURLConnectionDelegate>)delegate
{
    self = [self init];
    if (self) {
        _delegate = (id <NSURLConnectionDelegate, NSURLConnectionDataDelegate>)delegate;
    }
    return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if ([_delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        NSURLRequest *req = [_delegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
        if (req) {
            [NSURLConnection incrementBackgroundThreadConnectionCount];
        }
        return req;
    } else {
        [NSURLConnection incrementBackgroundThreadConnectionCount];
        return request;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([_delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [_delegate connectionDidFinishLoading:connection];
    }
    [NSURLConnection decrementBackgroundThreadConnectionCount];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [_delegate connection:connection didFailWithError:error];
    }
    [NSURLConnection decrementBackgroundThreadConnectionCount];
}

#pragma mark - forwardInvocation

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (_delegate) {
        [invocation setTarget:_delegate];
        [invocation invoke];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *result;
    if (_delegate) {
        result = [(NSObject *)_delegate methodSignatureForSelector:sel];
    } else {
        result = [super methodSignatureForSelector:sel];
    }
    return result;
}

- (BOOL)protocol:(Protocol *)protocol hasSelector:(SEL)aSelector
{
    struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, aSelector, NO, YES);
    return (hasMethod.name != NULL);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    if ([self protocol:@protocol(NSURLConnectionDelegate) hasSelector:aSelector] ||
        [self protocol:@protocol(NSURLConnectionDataDelegate) hasSelector:aSelector]) {
        return [_delegate respondsToSelector:aSelector];
    }
    
    return NO;
}

@end
