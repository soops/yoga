//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import <Foundation/Foundation.h>

#pragma mark NSArray

@interface NSArray (NSArrayFunctions)
- (NSArray *) SortedAlphabeticArray;
- (NSArray*)sortedAlphabeticArrayUsing:(NSString *)descriptor;
- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString;
- (NSMutableArray *)removeObjectsContainingString:(NSString *)aString;
- (NSMutableArray*)removeObjectsWithoutString:(NSString *)aString ;
- (NSMutableArray*)removeObjectsStartsWithString:(NSString *)aString ;
-(NSArray*)arrayOfValuesForKey:(NSString*)key;
@end

@interface NSArray (Hash)

-(NSString*) hash;

/// @correction
/// - removing isEqual implementation in order to avoid issue related to #2497
/// - need further investigation
/// (BOOL) isEqual:(id)object;

@end