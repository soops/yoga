//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSData+Extensions.h"
#import "NSString+Extensions.h"
#import "B64Transcoder.h"

@implementation NSData (JSONSerialization)

-(id)proxyForJson {
	return [@"data:image/png;base64," stringByAppendingString:[NSString base64StringFromData:self length:[self length]]];
}
@end

@implementation NSData (Base64Additions)

+(id)decodeBase64ForString:(NSString *)decodeString
{
    NSData *decodeBuffer = nil;
    // Must be 7-bit clean!
    NSData *tmpData = [decodeString dataUsingEncoding:NSASCIIStringEncoding];
    
    size_t estSize = EstimateB64DecodedDataSize([tmpData length]);
    uint8_t* outBuffer = calloc(estSize, sizeof(uint8_t));
    
    size_t outBufferLength = estSize;
    if (B64DecodeData([tmpData bytes], [tmpData length], outBuffer, &outBufferLength))
    {
        decodeBuffer = [NSData dataWithBytesNoCopy:outBuffer length:outBufferLength freeWhenDone:YES];
    }
    else
    {
        free(outBuffer);
        [NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to decode data!"];
    }
    
    return decodeBuffer;
}

+(id)decodeWebSafeBase64ForString:(NSString *)decodeString
{
    return [NSData decodeBase64ForString:[[decodeString stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"]];
}

- (NSString *)encodeBase64ForData
{
    NSString *encodedString = nil;
    
    // Make sure this is nul-terminated.
    size_t outBufferEstLength = EstimateB64EncodedDataSize([self length]) + 1;
    char *outBuffer = calloc(outBufferEstLength, sizeof(char));
    
    size_t outBufferLength = outBufferEstLength;
    if (B64EncodeDataWithWrapped([self bytes], [self length], outBuffer, &outBufferLength, FALSE))
    {
        encodedString = [NSString stringWithCString:outBuffer encoding:NSASCIIStringEncoding];
    }
    else
    {
        [NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to encode data!"];
    }
    
    free(outBuffer);
    
    return encodedString;
}

- (NSString *)encodeWebSafeBase64ForData
{
    return [[[self encodeBase64ForData] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

- (NSString *)encodeWrappedBase64ForData
{
    NSString *encodedString = nil;
	
    // Make sure this is nul-terminated.
    size_t outBufferEstLength = EstimateB64EncodedDataSize([self length]) + 1;
    char *outBuffer = calloc(outBufferEstLength, sizeof(char));
    
    size_t outBufferLength = outBufferEstLength;
    if (B64EncodeDataWithWrapped([self bytes], [self length], outBuffer, &outBufferLength, TRUE))
    {
        encodedString = [NSString stringWithCString:outBuffer encoding:NSASCIIStringEncoding];
    }
    else
    {
        [NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to encode data!"];
    }
    
    free(outBuffer);
    
    return encodedString;
}

@end

@implementation NSData (HEXSerialization)
/*
 * Returns hexadecimal representation for the NSData object in which the method is invoked
 */
- (NSString*) hexadecimalRepresentation
{
	NSMutableString *hexBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	const unsigned char *dataBuffer = [self bytes];
	for (int i = 0; i < [self length]; ++i)
	{
		[hexBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
	}
	NSString *hexString=[NSString stringWithString:hexBuffer];
	return hexString;
}
@end
