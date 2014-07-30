//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSDate+Extensions.h"

@implementation NSDate (NSDateForNSString)

+(NSDate *)convertNSStringDateToNSDate:(NSString *)string 
{
	//- check parameter validity
	if( string == nil )
		return nil;
	
	//- process request
	NSString *dateString = string;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	// this is imporant - we set our input date format to match our input string
	// if format doesn't match you'll get nil from your string, so be careful
	[dateFormatter setDateFormat:stringUTCDateTimeFormat];
	NSDate *convertedDate = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
	return convertedDate;
}

+(NSString*)convertNSDateToNSString:(NSDate*)date
{
	//- check parameter validity
	if( date == nil )
		return nil;
	
	//- process request
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:stringUTCDateTimeFormat];
	NSString *strDate = [dateFormatter stringFromDate:date/*[NSDate date]*/];
	[dateFormatter release];
	return strDate;
}


+(int)numberOfDaysFromDate:(NSDate*)fromDate ToDate:(NSDate*)toDate
{
    //dates needed to be reset to represent only yyyy-mm-dd to get correct number of days between two days.
    unsigned int unitFlags = NSDayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:fromDate  toDate:toDate options:0];
    int days = [comps day];
	
    [gregorian release];
    return days;
}

-(BOOL)isLaterTo:(NSDate*)laterDate
{
	if([self compare:laterDate]==NSOrderedDescending)
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

-(BOOL)isLaterThanOrEqualTo:(NSDate*)date
{
    return !([self compare:date] == NSOrderedAscending);
}

-(BOOL)isEarlierThanOrEqualTo:(NSDate*)date
{
    return !([self compare:date] == NSOrderedDescending);
}

-(BOOL)isLaterThan:(NSDate*)date
{
    return ([self compare:date] == NSOrderedDescending);
    
}

-(BOOL)isEarlierThan:(NSDate*)date
{
    return ([self compare:date] == NSOrderedAscending);
}

+(NSString*)generalDateFromUTCDate:(NSString*)utcDate
{
	NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
	[formatter setDateFormat:stringUTCDateFormat];
	NSDate *date=[formatter dateFromString:utcDate];
	[formatter setDateFormat:stringGeneralFullDateFormat];	
	NSString *resultDate=[formatter stringFromDate:date];	
	[formatter release];	
	return resultDate;
}

+(NSString*)UTCDateFromGeneralDate:(NSString*)generalDate
{
	NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
	[formatter setDateFormat:stringGeneralFullDateFormat];
	NSDate *date=[formatter dateFromString:generalDate];
	NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[formatter setLocale:usLocale];
	[formatter setDateFormat:stringUTCDateFormat];	
	NSString *resultDate=[formatter stringFromDate:date];	
	[formatter release];
	
	return resultDate;
}

+(NSString*)currentStandardUTCTime
{
	NSDate *date=[NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:stringUTCDateTimeFormat];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
	NSString *strDate = [formatter stringFromDate:date];
	[formatter release];
	return strDate;
}

+(NSString*)currentLocalUTCTime
{
	NSDate *date=[NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:stringUTCDateTimeFormat];
	NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[formatter setLocale:usLocale];
	NSString *strDate = [formatter stringFromDate:date];
	[formatter release];
	return strDate;
}

+(NSString *) gmttoLocalUTCTime:(NSString *)gmtTime
{
    /*
    //2013-07-28 18:30:00 GMT-3
    
    // NSDate *gmtDate  = <<your gmt date>>
    
    NSInteger hoursFromGMT      = [strDate intValue]; //gmg string
    NSInteger secondsFromGMT    = (hoursFromGMT * 60 * 60);
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
    
    NSDateFormatter *dateFormatterGMTAware = [[NSDateFormatter alloc] init];
    [dateFormatterGMTAware setTimeZone:timeZone];
    [dateFormatterGMTAware setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *dateGMT = [dateFormatterGMTAware dateFromString:strDate];
    
    //2013-07-28 18:30:00 GMT-3
    //29-07-2013 04:30:00
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSString *theDate = [dateFormat stringFromDate:dateGMT]; //GMT - local
     */
    
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:stringUTCDateTimeFormatZ];
    NSDate *date=[formatter dateFromString:gmtTime];
	NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	[formatter setLocale:usLocale];
    [formatter setDateFormat:stringUTCDateTimeFormat];
	NSString *strDate = [formatter stringFromDate:date];
	[formatter release];
	return strDate;
}

- (NSString *)timeAgo {
    
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]) - 5*60 - 20;
    double deltaMinutes = deltaSeconds / 60.0f;
    
    if(deltaSeconds < 5) {
        return NSLocalizedString(@"Just now.", @"");
    } else if(deltaSeconds < 60) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d seconds ago.", @""), (int)deltaSeconds];
    } else if(deltaSeconds < 120) {
        return NSLocalizedString(@"A minute ago.", @"");
    } else if (deltaMinutes < 60) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago.", @""), (int)deltaMinutes];
    } else if (deltaMinutes < 120) {
        return NSLocalizedString(@"An hour ago.", @"");
    } else if (deltaMinutes < (24 * 60)) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d hours ago.", @""), (int)floor(deltaMinutes/60)];
    } else if (deltaMinutes < (24 * 60 * 2)) {
        return NSLocalizedString(@"Yesterday.", @"");
    } else if (deltaMinutes < (24 * 60 * 7)) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d days ago.", @""), (int)floor(deltaMinutes/(60 * 24))];
    } else if (deltaMinutes < (24 * 60 * 14)) {
        return NSLocalizedString(@"Last week.", @"");
    } else if (deltaMinutes < (24 * 60 * 31)) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d weeks ago.", @""), (int)floor(deltaMinutes/(60 * 24 * 7))];
    } else if (deltaMinutes < (24 * 60 * 61)) {
        return NSLocalizedString(@"Last month.", @"");
    } else if (deltaMinutes < (24 * 60 * 365.25)) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d months ago.", @""), (int)floor(deltaMinutes/(60 * 24 * 30))];
    } else if (deltaMinutes < (24 * 60 * 731)) {
        return NSLocalizedString(@"Last year.", @"");
    }
    return [NSString stringWithFormat:NSLocalizedString(@"%d years ago.", @""), (int)floor(deltaMinutes/(60 * 24 * 365))];
}

#pragma mark -
#pragma mark localization method

/*
 * To get localized data based on date type
 * There are three types of dates used in  ID
 * MM/dd/yyyy, MM/yyyy, yyyy
 */
+(NSString*)localizedDateForString:(NSString*)dateStr withDateFormat:(WKDateFormatType)dateFormateType
{
	NSString* localizedDate;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSDate *formatedDate;
	switch (dateFormateType) 
	{
		case WKDateFormatFull:
			//Settings date format(MM/dd/yyyy) as per existing implementation
			[formatter setDateFormat:stringGeneralFullDateFormat];
			//Getting date
			formatedDate = [formatter dateFromString:dateStr];
			
			NSString *dateComponents = @"yMMMMd";
			
			NSLocale* currentLocal = [NSLocale currentLocale];
			NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocal];
			
			[formatter setDateFormat:dateFormat];
			
			//Getting localized date from exisiting date
			localizedDate=[formatter stringFromDate:formatedDate];
			break;
			
		case WKDateFormatMonthYear:
			@try
			{
				[formatter setDateFormat:stringGeneralMonthYearDateFormat];
				formatedDate = [formatter dateFromString:dateStr];
				
				NSString *dateComponents = @"yMMMM";
				
				NSLocale* currentLocal = [NSLocale currentLocale];
				NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocal];
				 
				//Setting date format
				[formatter setDateFormat:dateFormat];
				
				//Getting localized date
				localizedDate=[formatter stringFromDate:formatedDate];
			}
			@catch (NSException * e)
			{
				localizedDate = dateStr;
			}
			break;
			
		case WKDateFormatYear:
			@try
			{
				/*
				 *In iOS there is no specific date format for Year only.
				 *Hence we need to remove "date" and "month" component from the date format
				 *for eg, "mmm dd, y"  we need to remove "mm dd," from the date format "mm ,y"			 
				 */
				[formatter setDateFormat:stringGeneralYearDateFormat];
				formatedDate = [formatter dateFromString:dateStr];
				
				NSString *dateComponents = @"yMMMMd";
				
				NSLocale* currentLocal = [NSLocale currentLocale];
				NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocal];
				
				[formatter setDateFormat:dateFormat];
								
				NSString* dateFormat1 = [formatter dateFormat];
				NSString* yearFormat=@"";
				
				//Getting year component
				for(int i=0; i<[dateFormat1 length]; i++)
				{
					NSString *firstChar=[dateFormat1 substringWithRange:NSMakeRange(i, 1)];
					if([firstChar isEqualToString:@"y"] || [firstChar isEqualToString:@"Y"])
					{
						yearFormat = [NSString stringWithFormat:@"%@%@",yearFormat,firstChar];
					}
				}
				
				//Setting date format
				[formatter setDateFormat:yearFormat];
				
				//Getting localized date
				localizedDate=[formatter stringFromDate:formatedDate];
			}
			@catch (NSException * e)
			{
				localizedDate=dateStr;
			}
			
			break;
		default:
			break;
	}
	[formatter release];
	return localizedDate;
}

@end