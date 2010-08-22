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

- (id)init
{
	if ((self = [super initWithWindowNibName:@"SFPreferences"])) {
		NSMutableArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																		   group:PREF_GROUP_SPAMFILTER];
		
		if (!blacklist) {
			blacklist = [[NSMutableArray alloc] init];
			
			[adium.preferenceController setPreference:blacklist
											   forKey:KEY_SF_FILTERS
												group:PREF_GROUP_SPAMFILTER];
		}
	}
	
	return self;
}

- (IBAction)add:(id)sender
{
	[addField setStringValue:@""];
	
	[NSApp beginSheet:addSheet
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)remove:(id)sender
{
	NSMutableArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																	   group:PREF_GROUP_SPAMFILTER];
	[blacklist removeObjectAtIndex:[tableView selectedRow]];
	[tableView reloadData];
}

- (IBAction)cancel:(id)sender
{
	[addSheet orderOut:nil];
	[NSApp endSheet:addSheet];
}

- (IBAction)accept:(id)sender
{
	AILogWithSignature(@"Adding %@ to blacklist", [addField stringValue]);
	
	NSMutableArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																	   group:PREF_GROUP_SPAMFILTER];
	
	[blacklist addObject:[addField stringValue]];
	
	[addSheet orderOut:nil];
	[NSApp endSheet:addSheet];

	[tableView reloadData];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSMutableArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																	   group:PREF_GROUP_SPAMFILTER];
	
	return [blacklist objectAtIndex:row];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSMutableArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																	   group:PREF_GROUP_SPAMFILTER];
	
	[blacklist replaceObjectAtIndex:row withObject:object];
	[tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSMutableArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																	   group:PREF_GROUP_SPAMFILTER];
	
	return [blacklist count];
}

- (NSString *)pluginAuthor
{
	return @"Thijs Alkemade <thijsalkemade@gmail.com>";
}

- (NSString *)pluginVersion
{
	return @"0.0.1";
}

- (NSString *)pluginDescription
{
	return @"Allows you to specify filters on incoming messages.";
}

@end
