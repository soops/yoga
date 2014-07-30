//
// Date: 2013-03-26 16:32:59 +0700 (Tue, 26 Mar 2013)
// Revision: 3506
// Author: UNKNOWN
// ID: NSArray+NSDictionary+Extensions.h 3506 2013-03-26 09:32:59Z
//

#import "NSBundle+Extensions.h"

@implementation NSBundle (Localized)
-(NSString *)localizedPathForResource:(NSString *)name ofType:(NSString *)ext
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	NSString *currentLocalizedFolder=[currentLanguage stringByAppendingString:@".lproj"];
	
	if([self pathForResource:name ofType:ext inDirectory:currentLocalizedFolder]==nil)
	{
		currentLocalizedFolder=@"eng.lproj";
	}
	return [self pathForResource:name ofType:ext inDirectory:currentLocalizedFolder];
}
@end

