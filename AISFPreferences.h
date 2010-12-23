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

#import <Cocoa/Cocoa.h>

#import "AISFPlugin.h"
#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/AIAdvancedPreferencePane.h>

@interface AISFPreferences : AIAdvancedPreferencePane {
	IBOutlet NSTableView		*tableView;
	IBOutlet NSWindow			*addSheet;
	IBOutlet NSTextField		*addField;
	
	IBOutlet NSButton			*phraseIsCaseSensitive;
	IBOutlet NSButton			*phraseIsRegularExpression;
	
	IBOutlet NSTextField		*label_explanation;
	
	NSMutableArray				*blacklist;
	NSMutableDictionary			*currentlyEditing;
	
	NSNumber					*shouldIgnoreAuthorizationRequests;
}

+ (AISFPreferences *)sharedInstance;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)accept:(id)sender;

- (IBAction)save:(id)sender;

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (void)editObject:(NSDictionary *)inObject;

@property (copy) NSNumber *shouldIgnoreAuthorizationRequests;

@end
