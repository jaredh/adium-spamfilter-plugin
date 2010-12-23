/* 
 * Adium SpamFilter Plugin - Blacklist annoying messages in Adium
 * Copyright (C) 2010 Thijs Alkemade
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "AISFPreferences.h"

static AISFPreferences	*sharedInstance = nil;

@implementation AISFPreferences

@synthesize shouldIgnoreAuthorizationRequests;

+ (AISFPreferences *)sharedInstance
{	
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[self alloc] init];
		}
	}
	
	return sharedInstance;
}

- (AIPreferenceCategory)category
{
    return AIPref_Advanced;
}

- (NSString *)label
{
    return @"SpamFilter-plugin";
}

- (NSString *)nibName
{
    return @"SFPreferences";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"block"];
}

- (IBAction)save:(id)sender
{
	AILogWithSignature(@"Saving: %@", self.shouldIgnoreAuthorizationRequests);
	NSMutableArray *blacklistCopy = [[blacklist mutableCopy] autorelease];
	
	// Never save a blank term.
	[blacklistCopy removeObject:@""];
	
	[adium.preferenceController setPreference:blacklistCopy
									   forKey:KEY_SF_FILTERS
										group:PREF_GROUP_SPAMFILTER];
	
	[adium.preferenceController setPreference:self.shouldIgnoreAuthorizationRequests
									   forKey:KEY_SF_SHOULD_BLOCK_AUTH
										group:PREF_GROUP_SPAMFILTER];
	
	[tableView reloadData];
}

- (IBAction)add:(id)sender
{
	[currentlyEditing release]; currentlyEditing = nil;
	
	[addField setStringValue:@""];
	[addField becomeFirstResponder];
	
	[NSApp beginSheet:addSheet modalForWindow:[view window]
		modalDelegate:self didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)cancel:(id)sender
{
	[addSheet orderOut:nil];
	[NSApp endSheet:addSheet];
}

- (IBAction)accept:(id)sender
{
	AILogWithSignature(@"Adding %@ to blacklist", [addField stringValue]);
	
	if (!currentlyEditing) {
		NSMutableDictionary *newWord = [NSMutableDictionary dictionaryWithObjectsAndKeys:[addField stringValue], KEY_SF_PHRASE,
										[NSNumber numberWithBool:([phraseIsCaseSensitive state] == NSOnState)], KEY_SF_CASE_SENSITIVE,
										[NSNumber numberWithBool:([phraseIsRegularExpression state] == NSOnState)], KEY_SF_REGEX, nil];
		
		
		[blacklist addObject:newWord];
	} else {
		[currentlyEditing setValue:[addField stringValue] forKey:KEY_SF_PHRASE];
		[currentlyEditing setValue:[NSNumber numberWithBool:([phraseIsCaseSensitive state] == NSOnState)] forKey:KEY_SF_CASE_SENSITIVE];
		[currentlyEditing setValue:[NSNumber numberWithBool:([phraseIsRegularExpression state] == NSOnState)] forKey:KEY_SF_REGEX];
	}

	
	[self save:nil];
	
	[addSheet orderOut:nil];
	[NSApp endSheet:addSheet];
	
	[tableView reloadData];
}

/*!
 * @brief Remove the selected rows
 */
- (IBAction)remove:(id)sender
{
	NSIndexSet *indexes = [tableView selectedRowIndexes];
	
	[blacklist removeObjectsAtIndexes:indexes];
	[self save:nil];
	
	[tableView reloadData];
	[tableView deselectAll:nil];
}

- (NSView *)view
{
	return [[super view] retain];
}

/*!
 * @brief The view loaded
 */
- (void)viewDidLoad
{
	[label_explanation setStringValue:@"Messages are hidden when they match one of the following phrases. If case sensitive is enabled, \"sPaM\" will not match \"spam\"."];
	
	blacklist = [[NSMutableArray alloc] initWithArray:[adium.preferenceController preferenceForKey:KEY_SF_FILTERS group:PREF_GROUP_SPAMFILTER]];
	
	self.shouldIgnoreAuthorizationRequests = [adium.preferenceController preferenceForKey:KEY_SF_SHOULD_BLOCK_AUTH group:PREF_GROUP_SPAMFILTER];
	
	[super viewDidLoad];
}

- (void)viewWillClose
{
	[blacklist release]; blacklist = nil;
	
	[[super view] release];
	
	[super viewWillClose];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[blacklist objectAtIndex:row] valueForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSMutableDictionary *word = [[blacklist objectAtIndex:row] mutableCopy];
	
	[word setValue:[object copy] forKey:[tableColumn identifier]];
	
	[blacklist replaceObjectAtIndex:row withObject:word];
	
	[self save:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [blacklist count];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([[tableColumn identifier] isEqualToString:KEY_SF_CASE_SENSITIVE] || [[tableColumn identifier] isEqualToString:KEY_SF_REGEX]) {
		[cell setTitle:@""];
	}
}

- (void)editObject:(NSDictionary *)inObject
{
	currentlyEditing = [inObject retain];
	
	[addField setStringValue:[inObject valueForKey:KEY_SF_PHRASE]];
	[phraseIsCaseSensitive setState:[[inObject valueForKey:KEY_SF_CASE_SENSITIVE] integerValue]];
	[phraseIsRegularExpression setState:[[inObject valueForKey:KEY_SF_REGEX] integerValue]];
	
	[addSheet makeKeyAndOrderFront:self];
	[addSheet setLevel:NSModalPanelWindowLevel];
}

@end
