//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import <Foundation/Foundation.h>

// Date format hints for parsing date from internet string
typedef enum {DateFormatHintNone, DateFormatHintRFC822, DateFormatHintRFC3339} DateFormatHint;

@interface NSDate (InternetDateTime)
+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString formatHint:(DateFormatHint)hint;
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;
+ (NSDate *)dateFromRFC822String:(NSString *)dateString;
@end

