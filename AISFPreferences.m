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

@implementation AISFPreferences

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

- (void)saveTerms
{
	NSMutableArray *blacklistCopy = [[blacklist mutableCopy] autorelease];
	
	// Never save a blank term.
	[blacklistCopy removeObject:@""];
	
	[adium.preferenceController setPreference:blacklistCopy
									   forKey:KEY_SF_FILTERS
										group:PREF_GROUP_SPAMFILTER];
	
	[tableView reloadData];
}

- (IBAction)add:(id)sender
{
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
	
	NSMutableDictionary *newWord = [NSMutableDictionary dictionaryWithObjectsAndKeys:[addField stringValue], @"String",
									[NSNumber numberWithBool:([caseSensitive state] == NSOnState)], @"Case sensitive", nil];
	
	[blacklist addObject:newWord];
	
	[self saveTerms];
	
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
	[self saveTerms];
	
	[tableView reloadData];
	[tableView deselectAll:nil];
}

/*!
 * @brief The view loaded
 */
- (void)viewDidLoad
{
	[label_explanation setStringValue:@"Messages are hidden when they contain one of the following phrases. If case sensitive is enabled, \"sPaM\" will not match \"spam\"."];
	
	blacklist = [[NSMutableArray alloc] initWithArray:[adium.preferenceController preferenceForKey:KEY_SF_FILTERS group:PREF_GROUP_SPAMFILTER]];
	
	[super viewDidLoad];
}

- (void)viewWillClose
{
	[blacklist release]; blacklist = nil;
	
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
	
	[self saveTerms];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [blacklist count];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([[tableColumn identifier] isEqualToString:@"Case sensitive"]) {
		[cell setTitle:@""];
	}
}

@end
