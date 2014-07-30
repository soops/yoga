//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSArray+NSDictionary+Extensions.h"
#import "NSString+Extensions.h"
#import "WKSecurityHelper.h"

#pragma mark NSArray

@implementation NSArray (NSArrayFunctions)

-(NSArray*)SortedAlphabeticArray {
	//Sort all the Elements of the targeted array alphabetically.
	return [self sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

-(NSArray*)sortedAlphabeticArrayUsing:(NSString *)descriptor {
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:descriptor ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString {
    NSUInteger index = 0;
    for (NSString *object in self) {
        if ([object caseInsensitiveCompare:aString] == NSOrderedSame) {
            return index;
        }
        index++;
    }
    return NSNotFound;
} 

- (NSMutableArray*)removeObjectsContainingString:(NSString *)aString {
	NSMutableArray *newArray=[[[NSMutableArray alloc] init] autorelease];
	for (NSString *obj in self) 
	{
		if(![obj containsString:aString])
		{
			[newArray addObject:obj];
		}
		//[self removeObjectAtIndex:[self indexOfObject:obj]];
	}
	return newArray;
}

- (NSMutableArray*)removeObjectsWithoutString:(NSString *)aString  {
	NSMutableArray *newArray=[[[NSMutableArray alloc] init] autorelease];
	for (NSString *obj in self) 
	{
		if([obj containsString:aString])
		{
			[newArray addObject:obj];
		}
		//[self removeObjectAtIndex:[self indexOfObject:obj]];
	}
	return newArray;
}

- (NSMutableArray*)removeObjectsStartsWithString:(NSString *)aString  {
	NSMutableArray *newArray=[[[NSMutableArray alloc] init] autorelease];
	for (NSString *obj in self) 
	{
		obj=[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if(![obj hasPrefix:aString])
		{
			[newArray addObject:obj];
		}
		//[self removeObjectAtIndex:[self indexOfObject:obj]];
	}
	return newArray;
}

-(NSArray*)arrayOfValuesForKey:(NSString*)key {
	//creates new array with objects for passed key in all the elements of targetted array
	NSMutableArray *newArray=[[[NSMutableArray alloc] init] autorelease];
	for (NSDictionary *obj in self) 
	{
		[newArray addObject:[obj objectForKey:key]];
	}
	return newArray;
}

@end

@implementation NSArray (Hash)

-(NSString*) hash {
	
//	- consider using an MSMutableString as we can deal with a lot of concatenate 
//	- using auto-released pool will make memory allocation not to be freed until the end of the run loop ( that can be end of application )
	NSMutableString *stringData = [[NSMutableString alloc] initWithString:@""];
	
	for(NSObject *field in self) {
		if([field isKindOfClass:[NSString class]])
		{
			[stringData appendString:(NSString*)field];
		}
		else if([field isKindOfClass:[NSData class]])
		{
			//- too avoid storing too much data and also error while converting data format to NSString representation
			//- take hash for the NSData value directly
			[stringData appendString:[WKSecurityHelper SHA1digest:(NSData*)field]];
		}
		else if([field isKindOfClass:[NSNumber class]])
		{
			[stringData appendFormat:@"%@", (NSNumber*)field];
		}
	}
	
	//- compute SHA1 from provided data
	NSString* hash = [WKSecurityHelper SHA1digestString:stringData];
	
	//- release mutable string use to concatenate data
	[stringData release];
    stringData = nil;
	
	//- return computed hash
	return hash;
}

/*
 * Override isEqual method as required in order to match hash process check
 */
//- removing isEqual implementation in order to avoid issue related to #2497
//- need further investigation
/*
-(BOOL) isEqual:(id)object
{
	//- check if both objects are nil
	//- then if parameter object is an NSArray then compare hash with self hash
	return ((self == nil && object == nil) || ([object isKindOfClass:[NSArray class]] && [[self hash] isEqualToString:[(NSArray*)object hash]] ))
	? TRUE
	: FALSE;
	
}
*/

-(NSArray*)arrayOfValuesForKey:(NSString*)key
{
	NSMutableArray *newArray=[[[NSMutableArray alloc] init] autorelease];
	for (NSDictionary *obj in self)
	{
		[newArray addObject:[obj objectForKey:key]];
	}
	return newArray;
}

@end
#pragma mark -