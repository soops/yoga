//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import <Foundation/Foundation.h>


@interface NSData (JSONSerialization)
-(id)proxyForJson;
@end

@interface NSData (Base64Additions)

+(id)decodeBase64ForString:(NSString *)decodeString;
+(id)decodeWebSafeBase64ForString:(NSString *)decodeString;

- (NSString *)encodeBase64ForData;
- (NSString *)encodeWebSafeBase64ForData;
- (NSString *)encodeWrappedBase64ForData;

@end

@interface NSData (HEXSerialization)
/*
 * Returns hexadecimal representation for the NSData object in which the method is invoked
 */
- (NSString*) hexadecimalRepresentation;
@end