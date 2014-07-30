//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import <Foundation/Foundation.h>
#import "WKConstants.h"

typedef enum {
	WKDateFormatFull        = 0,
	WKDateFormatMonthYear	= 1,
	WKDateFormatYear		= 2,
} WKDateFormatType;

@interface NSDate (NSDateForNSString)

+(NSDate *)convertNSStringDateToNSDate:(NSString *)string ;

+(NSString*) convertNSDateToNSString:(NSDate*)date;

+(int)numberOfDaysFromDate:(NSDate*)fromDate ToDate:(NSDate*)toDate;

-(BOOL)isLaterTo:(NSDate*)laterDate;

-(BOOL)isLaterThanOrEqualTo:(NSDate*)date;

-(BOOL)isEarlierThanOrEqualTo:(NSDate*)date;

-(BOOL)isLaterThan:(NSDate*)date;

-(BOOL)isEarlierThan:(NSDate*)date;

+(NSString*)generalDateFromUTCDate:(NSString*)utcDate;

+(NSString*)UTCDateFromGeneralDate:(NSString*)generalDate;

+(NSString*)currentStandardUTCTime;

+(NSString*)currentLocalUTCTime;

+(NSString *) gmttoLocalUTCTime:(NSString *)gmtTime;

- (NSString *)timeAgo;
/*
 * To get localized data based on date type
 * There are three types of dates used in  ID
 * MM/dd/yyyy, MM/yyyy, yyyy
 */
+(NSString*)localizedDateForString:(NSString*)dateStr withDateFormat:(WKDateFormatType)dateFormateType;

@end