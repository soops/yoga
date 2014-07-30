//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import <Foundation/Foundation.h>

@interface NSInvocation (MultiObjects)

+ (NSInvocation*)invocationWithSelector:(SEL)aSelector toTarget:(id)aTarget andArgument:(id)object otherArgs:(va_list)otherArgs;

+ (NSInvocation*)invocationWithSelector:(SEL)aSelector toTarget:(id)aTarget andArguments:(id)object,... NS_REQUIRES_NIL_TERMINATION;

@end