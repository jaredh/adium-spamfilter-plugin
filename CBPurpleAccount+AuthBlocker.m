//
//  ESPurpleICQAccount+CyrillicAuthBlocker.m
//  spamfilter
//
//  Created by Thijs Alkemade on 23-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CBPurpleAccount+AuthBlocker.h"
#import "AISFPreferences.h"
#import <Adium/AIPreferenceControllerProtocol.h>

@implementation CBPurpleAccount (AuthBlocker)

- (id)authorizationRequestWithDict:(NSDictionary*)dict {
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
	
	return [super authorizationRequestWithDict:dict];
}

@end
