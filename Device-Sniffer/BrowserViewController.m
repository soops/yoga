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
 
 File: BrowserViewController.m
 Version: 1.1
 
 */

#import "BrowserViewController.h"
#define kProgressIndicatorSize 20.0

@interface NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService*)aService;
@end

@implementation NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService*)aService {
	return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}
@end


@interface BrowserViewController() // Browser Initialization
@property (nonatomic, assign, readwrite) BOOL showDisclosureIndicators;
@property (nonatomic, retain, readwrite) NSMutableArray* services;
@property (nonatomic, retain, readwrite) NSNetServiceBrowser* netServiceBrowser;
@property (nonatomic, retain, readwrite) NSNetService* currentResolve;
@property (nonatomic, retain, readwrite) NSTimer* timer;
@property (nonatomic, assign, readwrite) BOOL needsActivityIndicator;
@property (nonatomic, assign, readwrite) BOOL initialWaitOver;

- (void)stopCurrentResolve;
- (void)initialWaitOver:(NSTimer*)timer;
@end

@implementation BrowserViewController

@synthesize delegate = _delegate;
@synthesize showDisclosureIndicators = _showDisclosureIndicators;
@synthesize currentResolve = _currentResolve;
@synthesize netServiceBrowser = _netServiceBrowser;
@synthesize services = _services;
@synthesize needsActivityIndicator = _needsActivityIndicator;
@dynamic timer;
@synthesize initialWaitOver = _initialWaitOver; // The Wait is Over!!

- (id)initWithTitle:(NSString*)title showDisclosureIndicators:(BOOL)show showCancelButton:(BOOL)showCancelButton {
	
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		self.title = title;
		_services = [[NSMutableArray alloc] init];
		self.showDisclosureIndicators = show;

		if (showCancelButton) {
			UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
										  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
			self.navigationItem.rightBarButtonItem = addButton;
			[addButton release];
		}

		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(initialWaitOver:) userInfo:nil repeats:NO];
	}

	return self;
}

- (NSString *)searchingForServicesString {
	return _searchingForServicesString;
}

- (void)setSearchingForServicesString:(NSString *)searchingForServicesString {
	if (_searchingForServicesString != searchingForServicesString) {
		[_searchingForServicesString release];
		_searchingForServicesString = [searchingForServicesString copy];

		if ([self.services count] == 0) {
			[self.tableView reloadData];
		}
	}
}

- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain {
	
	[self stopCurrentResolve];
	[self.netServiceBrowser stop];
	[self.services removeAllObjects];

	NSNetServiceBrowser *aNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if(!aNetServiceBrowser) {
        // The NSNetServiceBrowser could not be allocated and initialized.
		return NO; // Do Not Return!
	}

	aNetServiceBrowser.delegate = self;
	self.netServiceBrowser = aNetServiceBrowser;
	[aNetServiceBrowser release];
	[self.netServiceBrowser searchForServicesOfType:type inDomain:domain];

	[self.tableView reloadData];
	return YES;
}


- (NSTimer *)timer {
	return _timer;
}

- (void)setTimer:(NSTimer *)newTimer {
	[_timer invalidate];
	[newTimer retain];
	[_timer release];
	_timer = newTimer;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	NSUInteger count = [self.services count];
	if (count == 0 && self.searchingForServicesString && self.initialWaitOver)
		return 1;

	return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *tableCellIdentifier = @"UITableViewCell"; // Launch in a UITableViewCell
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier] autorelease];
	}
	
	NSUInteger count = [self.services count];
	if (count == 0 && self.searchingForServicesString) {
        cell.textLabel.text = self.searchingForServicesString;
		cell.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		cell.accessoryType = UITableViewCellAccessoryNone;
		if (cell.accessoryView)
			cell.accessoryView = nil;
		return cell;
	}
	
	NSNetService* service = [self.services objectAtIndex:indexPath.row];
	cell.textLabel.text = [service name];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.accessoryType = self.showDisclosureIndicators ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	if (self.needsActivityIndicator && self.currentResolve == service) {
		if (!cell.accessoryView) {
			CGRect frame = CGRectMake(0.0, 0.0, kProgressIndicatorSize, kProgressIndicatorSize);
			UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithFrame:frame];
			[spinner startAnimating];
			spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
			[spinner sizeToFit];
			spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
										UIViewAutoresizingFlexibleRightMargin |
										UIViewAutoresizingFlexibleTopMargin |
										UIViewAutoresizingFlexibleBottomMargin);
			cell.accessoryView = spinner;
			[spinner release];
		}
	} else if (cell.accessoryView) {
		cell.accessoryView = nil;
	}
	
	return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.services count] == 0)
		return nil;
	
	return indexPath;
}


- (void)stopCurrentResolve {
	self.needsActivityIndicator = NO;
	self.timer = nil;

	[self.currentResolve stop];
	self.currentResolve = nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentResolve) {
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.services indexOfObject:self.currentResolve] inSection:0];
		
	    // self.needsActivityIndicator
		[self stopCurrentResolve];
		
		if (indexPath.row != NSNotFound)
			[self.tableView reloadRowsAtIndexPaths:[NSArray	arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
	
    self.currentResolve = [self.services objectAtIndex:indexPath.row];
	[self.currentResolve setDelegate:self];
	
	[self.currentResolve resolveWithTimeout:0.0];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showWaiting:) userInfo:self.currentResolve repeats:NO];
}

- (void)showWaiting:(NSTimer*)timer {
	if (timer == self.timer) {
		NSNetService* service = (NSNetService*)[self.timer userInfo];
		if (self.currentResolve == service) {
			self.needsActivityIndicator = YES;

			NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.services indexOfObject:self.currentResolve] inSection:0];
			if (indexPath.row != NSNotFound) {
				[self.tableView reloadRowsAtIndexPaths:[NSArray	arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
		}
	}
}


- (void)initialWaitOver:(NSTimer*)timer {
	self.initialWaitOver= YES;
	if (![self.services count])
		[self.tableView reloadData];
}


- (void)sortAndUpdateUI {
	[self.services sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
	[self.tableView reloadData];
}


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
	if (self.currentResolve && [service isEqual:self.currentResolve]) {
		[self stopCurrentResolve];
	}
	[self.services removeObject:service];
	if (!moreComing) {
		[self sortAndUpdateUI];
	}
}	


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
	[self.services addObject:service];
	if (!moreComing) {
		[self sortAndUpdateUI];
	}
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	[self stopCurrentResolve];
	[self.tableView reloadData];
}


- (void)netServiceDidResolveAddress:(NSNetService *)service {
	assert(service == self.currentResolve);
	
	[service retain];
	[self stopCurrentResolve];
	
	[self.delegate browserViewController:self didResolveInstance:service];
	[service release];
}


- (void)cancelAction {
	[self.delegate browserViewController:self didResolveInstance:nil];
}


- (void)dealloc {
	[self stopCurrentResolve];
	self.services = nil;
	[self.netServiceBrowser stop];
	self.netServiceBrowser = nil;
	[_searchingForServicesString release];
	
	[super dealloc];
}


@end
