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
 
 File: DomainViewController.m
 Version: 1.1
 
 */

#import "DomainViewController.h"

#define kProgressIndicatorSize 20.0

@interface DomainViewController ()
@property(nonatomic, assign) BOOL showDisclosureIndicators; // Show Disclosure Indicators
@property(nonatomic, retain) NSMutableArray* domains;
@property(nonatomic, retain) NSMutableArray* customs;
@property(nonatomic, retain) NSString* customTitle;
@property(nonatomic, retain) NSString* addDomainTitle;
@property(nonatomic, retain) NSNetServiceBrowser* netServiceBrowser;
@property(nonatomic, assign) BOOL showCancelButton;

- (void)addButtons:(BOOL)editing; // Editing Service
- (void)addAction:(id)sender;
- (void)editAction:(id)sender;
@end

@implementation DomainViewController

@synthesize delegate = _delegate;
@synthesize showDisclosureIndicators = _showDisclosureIndicators;
@synthesize domains = _domains;
@synthesize customs = _customs;
@synthesize customTitle = _customTitle;
@synthesize addDomainTitle = _addDomainTitle;
@dynamic netServiceBrowser;
@synthesize showCancelButton = _showCancelButton;

- (id)initWithTitle:(NSString*)title showDisclosureIndicators:(BOOL)show customsTitle:(NSString*)customsTitle customs:(NSMutableArray*)customs addDomainTitle:(NSString*)addDomainTitle showCancelButton:(BOOL)showCancelButton {
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		self.title = title;
		self.domains = [[[NSMutableArray alloc] init] autorelease];
		self.showDisclosureIndicators = show;
		self.customTitle = customsTitle;
		self.customs = customs ? customs : [NSMutableArray array];
		self.addDomainTitle = addDomainTitle;
		self.showCancelButton = showCancelButton;
		[self addButtons:self.tableView.editing];
	}

	return self;
}

- (void)setNetServiceBrowser:(NSNetServiceBrowser*)newBrowser {
	[_netServiceBrowser stop];
	[newBrowser retain];
	[_netServiceBrowser release];
	_netServiceBrowser = newBrowser;
}


- (NSNetServiceBrowser*)netServiceBrowser {
	return _netServiceBrowser;
}


- (void)addAddButton:(BOOL)right {
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
	if (right) self.navigationItem.rightBarButtonItem = addButton;
	else self.navigationItem.leftBarButtonItem = addButton;
	[addButton release];
}

- (void)addButtons:(BOOL)editing {
	if (editing) {
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
		
		self.navigationItem.leftBarButtonItem = doneButton;
		[doneButton release];

		[self addAddButton:YES];
	} else {
		if ([self.customs count]) {
			// Add the "edit" button to the navigation bar
			UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
										   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
			
			self.navigationItem.leftBarButtonItem = editButton;
			[editButton release];
		} else {
			[self addAddButton:NO];
		}
		
		if (self.showCancelButton) {
			// add Cancel button as the nav bar's custom right view
			UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
										  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
			self.navigationItem.rightBarButtonItem = addButton;
			[addButton release];
		} else {
			self.navigationItem.rightBarButtonItem = nil;
		}
	}
}

- (BOOL)commonSetup {
	self.netServiceBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
	if(!self.netServiceBrowser) {
		return NO;
	}
	
	[self.netServiceBrowser setDelegate:self];
	return YES;
}

// A cover method to -[NSNetServiceBrowser searchForBrowsableDomains].
- (BOOL)searchForBrowsableDomains {
	if (![self commonSetup]) return NO;
	[self.netServiceBrowser searchForBrowsableDomains];
	return YES;
}

// A cover method to -[NSNetServiceBrowser searchForRegistrationDomains].
- (BOOL)searchForRegistrationDomains {
	if (![self commonSetup]) return NO;
	[self.netServiceBrowser searchForRegistrationDomains];	
	return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1 + ([self.customs count] ? 1 : 0);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [(section ? self.customs : self.domains) count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section ? self.customTitle : @"Bonjour"; // Note that "Bonjour" is the proper name of the technology, therefore should not be localized
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"] autorelease];
	}
	
	// Set up the text for the cell
	cell.textLabel.text = [(indexPath.section ? self.customs : self.domains) objectAtIndex:indexPath.row];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.accessoryType = self.showDisclosureIndicators ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	return cell;
}

// Table View
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section && tableView.editing;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.delegate domainViewController:self didSelectDomain:[(indexPath.section ? self.customs : self.domains) objectAtIndex:indexPath.row]];
}


- (void)updateUI {
	[self.domains sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[self.tableView reloadData];
}


- (NSString*) transmogrify:(NSString*)aString {
	
	NSString* tmp = [NSString stringWithString:aString];
	const char *ostr = [tmp UTF8String];
	const char *cstr = ostr;
	char *ptr = (char*) ostr;
	
	while (*cstr) {
		char c = *cstr++;
		if (c == '\\')
		{
			c = *cstr++;
			if (isdigit(cstr[-1]) && isdigit(cstr[0]) && isdigit(cstr[1]))
			{
				NSInteger v0 = cstr[-1] - '0';										NSInteger v1 = cstr[ 0] - '0';
				NSInteger v2 = cstr[ 1] - '0';
				NSInteger val = v0 * 100 + v1 * 10 + v2;
				if (val <= 255) { c = (char)val; cstr += 2; }				}
		}
		*ptr++ = c;
	}
	ptr--;
	*ptr = 0;
	return [NSString stringWithUTF8String:ostr];
}


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveDomain:(NSString*)domain moreComing:(BOOL)moreComing {
	[self.domains removeObject:[self transmogrify:domain]];
	
	
	if (!moreComing)
		[self updateUI];
}	


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindDomain:(NSString*)domain moreComing:(BOOL)moreComing {
	NSString* tmp = [self transmogrify:domain];
	if (![self.domains containsObject:tmp]) [self.domains addObject:tmp];

	
	if (!moreComing)
		[self updateUI];
}	


- (void)doneAction:(id)sender {
	[self.tableView setEditing:NO animated:YES];
	[self addButtons:self.tableView.editing];
}


- (void)editAction:(id)sender {
	[self.tableView setEditing:YES animated:YES];
	[self addButtons:self.tableView.editing];
}


- (IBAction)cancelAction {
	[self.delegate domainViewController:self didSelectDomain:nil];
}


- (void)addAction:(id)sender {
	SimpleEditViewController* sevc = [[SimpleEditViewController alloc] initWithTitle:self.addDomainTitle currentText:nil];
	[sevc setDelegate:self];
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:sevc];
	[sevc release];
	[self.navigationController presentModalViewController:nc animated:YES];
	[nc release];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	assert(editingStyle == UITableViewCellEditingStyleDelete);
	assert(indexPath.section == 1);
	[self.customs removeObjectAtIndex:indexPath.row];
	if (![self.customs count]) {
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationRight];
	} else {
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
	[self addButtons:self.tableView.editing];
}


- (void) simpleEditViewController:(SimpleEditViewController*)sevc didGetText:(NSString*)text {
	[self.navigationController dismissModalViewControllerAnimated:YES];

	if (![text length])
		return;
	
	if (![self.customs containsObject:text]) {
		[self.customs addObject:text];
		[self.customs sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	}
	
	[self addButtons:self.tableView.editing];
	[self.tableView reloadData];
	NSUInteger ints[2] = {1,[self.customs indexOfObject:text]};
	NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}


- (void)dealloc {
	[_domains release];
	[_customs release];
	[_customTitle release];
	[_addDomainTitle release];
	[_netServiceBrowser release];
	
	[super dealloc];
}

@end
