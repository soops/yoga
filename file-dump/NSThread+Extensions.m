//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSThread+Extensions.h"
#import "NSInvocation+Extensions.h"

@implementation NSThread (MultiObjects)

+ (void)detachNewThreadSelector:(SEL)aSelector toTarget:(id)aTarget withObjects:(id)object,... 
{
	NSInvocation *invocation;
	va_list args;
    va_start(args, object);
	invocation=[NSInvocation invocationWithSelector:aSelector toTarget:aTarget andArgument:object otherArgs:args];
	va_end(args);
	
	[self detachNewThreadSelector:@selector(invoke) toTarget:invocation withObject:nil];
}

@end