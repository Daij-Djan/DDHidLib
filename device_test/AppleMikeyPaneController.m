/*
 * Copyright (c) 2007 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "AppleMikeyPaneController.h"
#import "DDHidLib.h"
#include <IOKit/hid/IOHIDUsageTables.h>

@implementation AppleMikeyPaneController

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mEvents = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) awakeFromNib;
{
    NSArray * mikeys = [DDHidAppleMikey allMikeys];
    
    [mikeys makeObjectsPerformSelector: @selector(setDelegate:)
                               withObject: self];
    [self setMikeys: mikeys];
    
    if ([mikeys count] > 0)
        [self setMikeyIndex: 0];
    else
        [self setMikeyIndex: NSNotFound];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mMikeys release];
    [mEvents release];
    
    mMikeys = nil;
    mEvents = nil;
    [super dealloc];
}

//=========================================================== 
//  mikeys
//=========================================================== 
- (NSArray *) mikeys
{
    return mMikeys;
}

- (void) setMikeys: (NSArray *) theMikeys
{
    if (mMikeys != theMikeys)
    {
        [mMikeys release];
        mMikeys = [theMikeys retain];
    }
}
//=========================================================== 
//  mikeyIndex
//=========================================================== 
- (NSUInteger) mikeyIndex
{
    return mMikeyIndex;
}

- (void) setMikeyIndex: (NSUInteger) theMikeyIndex
{
    if (mCurrentMikey != nil)
    {
        [mCurrentMikey stopListening];
        mCurrentMikey = nil;
    }
    mMikeyIndex = theMikeyIndex;
    [mMikeysController setSelectionIndex: mMikeyIndex];
    [self willChangeValueForKey: @"events"];
    [mEvents removeAllObjects];
    [self didChangeValueForKey: @"events"];
    if (mMikeyIndex != NSNotFound)
    {
        mCurrentMikey = [mMikeys objectAtIndex: mMikeyIndex];
        [mCurrentMikey startListening];
    }
}

//=========================================================== 
//  events 
//=========================================================== 
- (NSMutableArray *) events
{
    return mEvents; 
}

- (void) setEvents: (NSMutableArray *) theEvents
{
    if (mEvents != theEvents)
    {
        [mEvents release];
        mEvents = [theEvents retain];
    }
}
- (void) addEvent: (id)theEvent
{
    [[self events] addObject: theEvent];
}
- (void) removeEvent: (id)theEvent
{
    [[self events] removeObject: theEvent];
}

@end

@implementation AppleMikeyPaneController (DDHidAppleMikeyDelegate)

- (void) ddhidAppleMikey:(DDHidAppleMikey *)mikey press:(unsigned int)usageId upOrDown:(BOOL)upOrDown
{
    NSString *usage = nil;
    if(usageId==kHIDUsage_GD_SystemMenuDown) {
        usage = @"MenuDown";
    }
    else if(usageId == kHIDUsage_GD_SystemMenuUp) {
        usage = @"MenuUp";
    }
    
    if(!usage)
        return;
    
    NSMutableDictionary * row = [[mMikeysEventsController newObject] autorelease];
    [row setObject: upOrDown ? @"Down" : @"Up" forKey: @"event"];
    [row setObject:usage forKey: @"description"];
    [mMikeysEventsController addObject: row];
}

@end
