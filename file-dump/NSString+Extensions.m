//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSString+Extensions.h"
#import "B64Transcoder.h"
#import "NSArray+NSDictionary+Extensions.h"
#import "NSBundle+Extensions.h"

@implementation NSString (NSStringFunctions)

-(BOOL) hasSubStringWithPattern:(NSString*) regEx
{
	NSRange r = [self rangeOfString:regEx options:NSRegularExpressionSearch];
    return (r.location != NSNotFound);
}

- (BOOL) hasSubString:(NSString *) str
{
	return [self length] != 0 && [self rangeOfString:str].location != NSNotFound;
}

- (BOOL)isAnyOf:(NSString *)Strings 
{
	return ([[Strings componentsSeparatedByString:@","] indexOfCaseInsensitiveString:self]!=NSNotFound);
}

- (BOOL)containsAnyOf:(NSString *)Strings 
{
	for(NSString *str in [Strings componentsSeparatedByString:@","])
	{
		if([self containsString:str])
			return YES;
	}
	return NO;
}

- (BOOL)equalsAnyOf:(NSString *)Strings 
{
	for(NSString *str in [Strings componentsSeparatedByString:@","])
	{
		if([self isEqualToString:str])
			return YES;
	}
	return NO;
}

-(NSString*)NullToBlank
{
	if((self==nil)||[self isEqual:[NSNull null]]||[self isEqualToString:@"<null>"])
		return @"";
	else
	{
		return self;
	}
}

-(NSString*) quotedString
{
	return self;
	//return [NSString stringWithFormat:@"%@%@%@",@"\"",self,@"\""];
}

/*
-(NSString*) localizedString // get localized string content
{	
	//return self;
	
 	//- load localized string once
	NSLog(@"%@ -%@",[[NSLocale preferredLanguages] objectAtIndex:0],[[[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"] objectAtIndex:0]);
	if (nil == localizingStringDict || ![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:[[[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"] objectAtIndex:0]]){
		NSString *path = [[NSBundle mainBundle] localizedPathForResource:@"Localizable" ofType:@"strings"];
		localizingStringDict = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
		//P/S: Static object is released by Obj-C when the app terminated.
	}
	
	
	//- load localized string from dict ( should be useless as this is already the NSLocalizedString behavior )
	//- but will stick to it right now to avoid too much side effects
	NSString* candidate = [localizingStringDict objectForKey:self];
	
	if (!candidate) {
		//- if candidate value is not avialable, try to find lowercase version
		candidate = [localizingStringDict objectForKey:[self lowercaseString]];
	}
		//NSLog(@"%@",localizingStringDict);
	//- otherwise use default localization process
	return (candidate) ? candidate
	: NSLocalizedString(self,@"");
	
}*/

-(BOOL) containsString:(NSString *)str
{
	NSRange textRange =[self rangeOfString:str options:NSCaseInsensitiveSearch];
	return (textRange.location != NSNotFound);
}

-(NSString *) truncateTrails:(NSInteger)length
{
	//Returns a String trails with ... after selected length ( ex - [@"AO" truncateTrails:2] gives "WI.." )
	if([self length]>length)
	{
		return [[self substringToIndex:length-3] stringByAppendingString:@".."];
	}
	return self;
}

-(NSString *)ImplementWording:(NSInteger)length
{
	NSMutableArray *characters =[[[NSMutableArray alloc] initWithCapacity:[self length]] autorelease];
	for (int i=0; i < [self length]; i++) 
	{
		NSString *ichar  =[NSString stringWithFormat:@"%c", [self characterAtIndex:i]];
		if(i%length==0)
		{
			[characters addObject:@" "];
		}
		[characters addObject:ichar];
	}
	return [characters componentsJoinedByString:@""];
}

-(NSString *) ImplementBreaking:(NSInteger)length
{
	//To convert a single lined string to a multi lines paragraph - for view purpose
	NSMutableString *st=[NSMutableString stringWithString:self];
	int c=length;
	int ind=0;
	int inc=0;
	for (c=length; c<[self length]; c+=length) 
	{
		ind+=2;
		inc++;
		@try {
			[st insertString:@"\n" atIndex:(length*inc)+ind];
		}
		@catch (NSException * e) {
			return st ;
		}
	}
	
	return st;
}

-(NSInteger ) numberOfLinesInString //returns how many lines does targeted string has.
{
	return [[self componentsSeparatedByString:@"\n"] count];
}

-(NSString *) pad:(NSInteger)len
{
	NSString *paddedStr=self;
	for(int i=[self length];i<len;i++)
	{
		paddedStr=[paddedStr stringByAppendingString:@" "];
	}
	return paddedStr;
}

-(BOOL) isEmpty
{
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""];
}

+(NSString*)stringWithFloat:(float)value maxDecimal:(int)decimalLimit
{
	NSNumber *numVal=[NSNumber numberWithFloat:value];
	NSString *numString=[numVal stringValue];
	
	NSArray *comps=[numString componentsSeparatedByString:@"."];
	if(comps.count>1)
	{
		NSString *pre=[comps objectAtIndex:0];
		NSString *post=[comps objectAtIndex:1];
		if(post.length>decimalLimit)
		{
			post=[post substringToIndex:decimalLimit];
		}
		numString=[NSString stringWithFormat:@"%@.%@",pre,post];
	}
	
	return numString;
}
@end

@implementation NSString (JSONSerialization)

-(id)proxyForJson
{
	return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(id)readerForJson
{
	NSRange textRange =[[self lowercaseString] rangeOfString:[@"data:image/png;base64," lowercaseString]];
	BOOL has=(textRange.location != NSNotFound);
	if (has) 
	{
		self=[self stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
		NSData *data=(NSData*)[NSString decodeBase64StringToData:self];
		return data;
	}
	else
	{
		return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	return self;
}
@end

#pragma mark NSStringEncoding

static char base64EncodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation NSString (NSStringEncoding)

+(NSString *)base64StringFromData: (NSData *)data length: (int)length
{
	unsigned long ixtext, lentext;
	long ctremaining;
	unsigned char input[3], output[4];
	short i, charsonline = 0, ctcopy;
	const unsigned char *raw;
	NSMutableString *result;
	
	lentext = [data length]; 
	if (lentext < 1)
		return @"";
	result = [NSMutableString stringWithCapacity: lentext];
	raw = [data bytes];
	ixtext = 0; 
	
	while (true) {
		ctremaining = lentext - ixtext;
		if (ctremaining <= 0) 
			break;        
		for (i = 0; i < 3; i++) { 
			unsigned long ix = ixtext + i;
			if (ix < lentext)
				input[i] = raw[ix];
			else
				input[i] = 0;
		}
		output[0] = (input[0] & 0xFC) >> 2;
		output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
		output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
		output[3] = input[2] & 0x3F;
		ctcopy = 4;
		switch (ctremaining) {
			case 1: 
				ctcopy = 2; 
				break;
			case 2: 
				ctcopy = 3; 
				break;
		}
		
		for (i = 0; i < ctcopy; i++)
			[result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
		
		for (i = ctcopy; i < 4; i++)
			[result appendString: @"="];
		
		ixtext += 3;
		charsonline += 4;
		
		if ((length > 0) && (charsonline >= length))
			charsonline = 0;
		
	}
	return result;
	
}

+(NSString *)decodeBase64ForString:(NSString *)decodeString
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
    
    return [NSString stringWithFormat:@"%@",decodeBuffer];
}

+(NSData *)decodeBase64StringToData:(NSString *)decodeString
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

- (NSData*) getNSDataRepresentation // get current string NSData representation using UTF8 encoding
{
	NSData* data=[self dataUsingEncoding:NSUTF8StringEncoding];
	//- const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	//- NSData *data = [NSData dataWithBytes:cstr length:strlen(cstr)];
	//- NSData *data = [NSData dataWithBytes:[self UTF8String] length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]; 
	return data;
}

@end

#pragma mark -


