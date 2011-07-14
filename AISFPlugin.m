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

#import <Adium/AIPreferenceControllerProtocol.h>
#import </usr/include/objc/objc-class.h>

@class AIMedia;

#import <AdiumLibpurple/CBPurpleAccount.h>

@implementation AISFPlugin

- (void)installPlugin
{
	//preferences = [[AISFPreferences preferencePaneForPlugin:self] retain];
	preferences = [[AISFPreferences sharedInstance] retain];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willReceiveContent:)
												 name:Content_WillReceiveContent
											   object:nil];
	
	AILogWithSignature(@"Doing risky stuff: swizzling authorizationRequestWithDict:");
	
	Method orig_method = nil, alt_method = nil;
	SEL orig = @selector(authorizationRequestWithDict:);
	SEL new = @selector(authorizationRequestWithDict:);
	orig_method = class_getInstanceMethod([CBPurpleAccount class], @selector(authorizationRequestWithDict:));
    alt_method = class_getInstanceMethod([CBPurpleAccount class], @selector(_authorizationRequestWithDict:));

    if(class_addMethod([CBPurpleAccount class], orig, method_getImplementation(alt_method), method_getTypeEncoding(alt_method)))
        class_replaceMethod([CBPurpleAccount class], new, method_getImplementation(orig_method), method_getTypeEncoding(orig_method));
    else
		method_exchangeImplementations(orig_method, alt_method);
	
	AILogWithSignature(@"Adium spamfilter plugin loaded: %@", [preferences view]);
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
	
	for (NSDictionary *message in blacklist) {
		if ([[message valueForKey:KEY_SF_REGEX] boolValue]) {
			
			NSPredicate *regex;
			
			if ([[message valueForKey:KEY_SF_CASE_SENSITIVE] boolValue]) {
				regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [message valueForKey:KEY_SF_PHRASE]];
			} else {
				regex = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", [message valueForKey:KEY_SF_PHRASE]];
			}
			
			@try {
				if ([regex evaluateWithObject:contentObject.message.string]) {
					hidden = YES;
					AILogWithSignature(@"Hiding %@ as it matches regex %@", contentObject, message);
					break;
				}
			}
			@catch (NSException *e) {
				AILog(@"Regex %@ seems to have failed: %@", message, e);
				// show the error after a delay, so the incoming message doesn't have to wait
				[self performSelector:@selector(error:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"Message", e, @"Exception", nil] afterDelay:0.1];
			}
			
		} else if ([contentObject.message.string rangeOfString:[message valueForKey:KEY_SF_PHRASE]
												options:([[message valueForKey:KEY_SF_CASE_SENSITIVE] boolValue] ? 0 : NSCaseInsensitiveSearch)].location != NSNotFound) {
			hidden = YES;
			AILogWithSignature(@"Hiding %@ as it matches %@", contentObject, message);
			break;
		}
	}
	
	if (hidden) {
		contentObject.displayContent = NO;
	}
}
				 
- (void)error:(NSDictionary *)context
{
	NSInteger result = NSRunAlertPanel([NSString stringWithFormat:@"Evaluation of regular expression \"%@\" failed.", [[context valueForKey:@"Message"] valueForKey:KEY_SF_PHRASE]],
									   [NSString stringWithFormat:@"Adium SpamFilter plugin encountered an error when evaluating this regular expression:\n\n%@", [context valueForKey:@"Exception"]],
									   @"OK",
									   @"Edit expression",
									   nil);
	
	if (result == NSAlertAlternateReturn) {
		[preferences editObject:[context valueForKey:@"Message"]];
	}
}

- (NSString *)pluginAuthor
{
	return @"Thijs Alkemade <thijsalkemade@gmail.com>";
}

- (NSString *)pluginVersion
{
	return @"0.1.0";
}

- (NSString *)pluginDescription
{
	return @"Allows you to specify filters on incoming messages.";
}

@end
