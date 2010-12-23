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
#import <Adium/AIPlugin.h>
#import <Adium/AIContentControllerProtocol.h>
#import <Adium/ESDebugAILog.h>

#import "AISFPreferences.h"

#define KEY_SF_FILTERS @"SF Filters"
#define PREF_GROUP_SPAMFILTER @"SpamFilter Plugin"

#define KEY_SF_PHRASE @"String"
#define KEY_SF_CASE_SENSITIVE @"Case Sensitive"
#define KEY_SF_REGEX @"Regular Expression"

#define KEY_SF_SHOULD_BLOCK_AUTH @"Should Ignore Authorization Requests"

@class AISFPreferences;

@interface AISFPlugin : NSObject <AIPlugin> {
	AISFPreferences *preferences;
}

@end
