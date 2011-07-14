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

#import "CBPurpleAccount+AuthBlocker.h"
#import "AISFPreferences.h"
#import <Adium/AIPreferenceControllerProtocol.h>

@class AIMedia;

#import <AdiumLibpurple/CBPurpleAccount.h>

@implementation CBPurpleAccount (AuthBlocker)

- (id)_authorizationRequestWithDict:(NSDictionary*)dict {
	if ([AISFPreferences sharedInstance].shouldIgnoreAuthorizationRequests) {
		NSString *reason = [dict valueForKey:@"Reason"];
		
		NSArray *blacklist = [adium.preferenceController preferenceForKey:KEY_SF_FILTERS
																	group:PREF_GROUP_SPAMFILTER];
		
		for (NSDictionary *message in blacklist) {
			if ([[message valueForKey:KEY_SF_REGEX] boolValue]) {
				
				NSPredicate *regex;
				
				if ([[message valueForKey:KEY_SF_CASE_SENSITIVE] boolValue]) {
					regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [message valueForKey:KEY_SF_PHRASE]];
				} else {
					regex = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", [message valueForKey:KEY_SF_PHRASE]];
				}
				
				@try {
					if ([regex evaluateWithObject:reason]) {
						AILogWithSignature(@"Ignoring auth request %@ as it matches regex %@", dict, message);
						return NULL;
					}
				}
				@catch (NSException *e) {
					AILog(@"Regex %@ seems to have failed: %@", message, e);
					// show the error after a delay, so the incoming message doesn't have to wait
					[self performSelector:@selector(error:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"Message", e, @"Exception", nil] afterDelay:0.1];
				}
				
			} else if ([reason rangeOfString:[message valueForKey:KEY_SF_PHRASE]
									 options:([[message valueForKey:KEY_SF_CASE_SENSITIVE] boolValue] ? 0 : NSCaseInsensitiveSearch)].location != NSNotFound) {
				AILogWithSignature(@"Ignoring auth request %@ as it matches regex %@", dict, message);
				return NULL;
			}
		}
	}
	
	return [self _authorizationRequestWithDict:dict];
}

@end
