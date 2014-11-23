// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>

@interface BTNSURLConnectionDelegateWrapper : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) id <NSURLConnectionDelegate, NSURLConnectionDataDelegate> delegate;

- (id)initWithDelegate:(id <NSURLConnectionDelegate>)delegate;

@end
