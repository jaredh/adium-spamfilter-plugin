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

#import "AISFPlugin.h"
#import <Adium/AIContentObject.h>
#import <Adium/AIContentMessage.h>
#import <Adium/AIChat.h>

#import <Adium/AIPreferenceControllerProtocol.h>

@implementation AISFPlugin

- (void)installPlugin
{
	preferences = [[AISFPreferences alloc] init];
	
	[preferences loadWindow];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willReceiveContent:)
												 name:Content_WillReceiveContent
											   object:nil];
	
	AILogWithSignature(@"Adium spamfilter plugin loaded.");
}

- (void)uninstallPlugin
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willReceiveContent:(NSNotification *)notification
{	
	AIContentObject		*contentObject = [[notification userInfo] objectForKey:@"Object"];
	
	if (![contentObject isKindOfClass:[AIContentMessage class]] ||
		!contentObject.source) {
		return;
	}
	
	BOOL				hidden = NO;
	
	NSArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																group:PREF_GROUP_SPAMFILTER];
	
	for (NSString *message in blacklist) {
		if ([contentObject.message.string rangeOfString:message options:NSCaseInsensitiveSearch].location != NSNotFound) {
			hidden = YES;
			AILogWithSignature(@"Hiding %@ as it matches %@", contentObject, message);
			break;
		}
	}
	
	// We use our own "did we hide?" variable, in case something else somewhere has caused this to not display.
	if (hidden) {
		contentObject.displayContent = NO;
	}
}

@end
