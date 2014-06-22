/*
 
 Copyright (c) 2014 Apollo Computational Research Group
 Commits Made by Douglas Bumby.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 File: BonjourWebAppDelegate.m
 Version: 1.1
 
 */

#import "BonjourWebAppDelegate.h"
#import "BonjourBrowser.h"


#define kWebServiceType @"_http._tcp"
#define kInitialDomain  @"local"


@implementation BonjourWebAppDelegate

@synthesize window;
@synthesize browser;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Create the Bonjour Browser for Web services
	BonjourBrowser *aBrowser = [[BonjourBrowser alloc] initForType:kWebServiceType
														  inDomain:kInitialDomain
												  customDomains:nil
									   showDisclosureIndicators:NO
											   showCancelButton:NO];
	self.browser = aBrowser;
	[aBrowser release];

	self.browser.delegate = self;
    self.browser.searchingForServicesString = NSLocalizedString(@"Searching for web services", @"Searching for web services string");

	[self.window addSubview:[self.browser view]];
}


- (void)dealloc {
	[browser release];
	[window release];
	[super dealloc];
}


- (NSString *)copyStringFromTXTDict:(NSDictionary *)dict which:(NSString*)which {
	NSData* data = [dict objectForKey:which];
	NSString *resultString = nil;
	if (data) {
		resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return resultString;
}


- (void) bonjourBrowser:(BonjourBrowser*)browser didResolveInstance:(NSNetService*)service {
	NSDictionary* dict = [[NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]] retain];
	NSString *host = [service hostName];
	
	NSString* user = [self copyStringFromTXTDict:dict which:@"u"];
	NSString* pass = [self copyStringFromTXTDict:dict which:@"p"];
	
	NSString* portStr = @"";
	
	// [NSNetService port:] 
	NSInteger port = [service port];
	if (port != 0 && port != 80)
			portStr = [[NSString alloc] initWithFormat:@":%d",port];
	
	NSString* path = [self copyStringFromTXTDict:dict which:@"path"];
	if (!path || [path length]==0) {
			[path release];
			path = [[NSString alloc] initWithString:@"/"];
	} else if (![[path substringToIndex:1] isEqual:@"/"]) {
			NSString *tempPath = [[NSString alloc] initWithFormat:@"/%@",path];
			[path release];
			path = tempPath;
	}
	
	NSString* string = [[NSString alloc] initWithFormat:@"http://%@%@%@%@%@%@%@",
												user?user:@"",
												pass?@":":@"",
												pass?pass:@"",
												(user||pass)?@"@":@"",
												host,
												portStr,
												path];
	
	NSURL *url = [[NSURL alloc] initWithString:string];
	[[UIApplication sharedApplication] openURL:url];
	
	[url release];
	[string release];
	[portStr release];
	[pass release];
	[user release];
	[dict release];
	[path release];
}

@end
