//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSInvocation+Extensions.h"

@implementation NSInvocation (MultiObjects)

+ (NSInvocation*)invocationWithSelector:(SEL)aSelector toTarget:(id)aTarget andArgument:(id)object otherArgs:(va_list)otherArgs
{
	NSMethodSignature *signature = [aTarget methodSignatureForSelector:aSelector];
    if (!signature) { return nil; }
	
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:aTarget];
    [invocation setSelector:aSelector];
	int index=2;
	[invocation setArgument:&object atIndex:index];
	
	id argument;
	while((argument = va_arg(otherArgs, id)))
	{
		index++;
		[invocation setArgument:&argument atIndex:index];
	}
	
	[invocation retainArguments];
	
	return invocation;
}

+ (NSInvocation*)invocationWithSelector:(SEL)aSelector toTarget:(id)aTarget andArguments:(id)object,...;
{
	NSInvocation *invocation;
	
	va_list argumentList;
	va_start(argumentList, object);
	invocation=[NSInvocation invocationWithSelector:aSelector toTarget:aTarget andArgument:object otherArgs:argumentList];
	va_end(argumentList);
	
	return invocation;
}

@end