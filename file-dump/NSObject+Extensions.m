//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSObject+Extensions.h"
#import "NSInvocation+Extensions.h"

@implementation NSObject (KMExtensions)

- (id)performSelectorIfResponds:(SEL)aSelector
{
	//This is to prevent Unrecognized Selector sent when we are unaware of targetted class.
    if ( [self respondsToSelector:aSelector] ) 
	{
//        return [self performSelector:aSelector];
    }
    return NULL;
}

- (id)performSelectorIfResponds:(SEL)aSelector withObject:(id)anObject
{
	//This is to prevent Unrecognized Selector sent when we are unaware of targetted class.
    if ( [self respondsToSelector:aSelector] ) {
//        return [self performSelector:aSelector withObject:anObject];
    }
    return NULL;
}

-(id)ObjNullToBlank
{
	if((self==nil)||[self isEqual:[NSNull null]])
	{
		return @"";
	}
	else
	{
		return self;
	}
}
@end

@implementation NSObject(MultiObjects)

-(void)performSelectorOnMainThread:(SEL)aSelector withObjects:(id)object,...
{
	NSInvocation *invocation;
	va_list args;
    va_start(args, object);
	invocation=[NSInvocation invocationWithSelector:aSelector toTarget:self andArgument:object otherArgs:args];
	va_end(args);
	
	[invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
}

@end