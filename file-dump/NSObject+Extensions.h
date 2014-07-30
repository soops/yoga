//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import <Foundation/Foundation.h>

@interface NSObject (KMExtensions)

- (id)performSelectorIfResponds:(SEL)aSelector;
- (id)performSelectorIfResponds:(SEL)aSelector withObject:(id)anObject;
- (id)ObjNullToBlank;

@end

@interface NSObject (MultiObjects)

-(void)performSelectorOnMainThread:(SEL)aSelector withObjects:(id)object,... NS_REQUIRES_NIL_TERMINATION;

@end