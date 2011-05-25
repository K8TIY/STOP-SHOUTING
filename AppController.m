/*
Copyright © 2008-2011 Brian S. Hall

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
#import <Carbon/Carbon.h>
#import "AppController.h"

@implementation SSWindow
-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)style
     backing:(NSBackingStoreType)buffering defer:(BOOL)flag
{
  #pragma unused (style,buffering,flag)
  self = [super initWithContentRect:contentRect
                styleMask:NSBorderlessWindowMask
                backing:NSBackingStoreBuffered defer:NO];
  [self setBackgroundColor:[NSColor clearColor]];
  [self setLevel:kCGMaximumWindowLevel];
  [self setAlphaValue:0.25f];
  [self setOpaque:NO];
  return self;
}
-(BOOL)canBecomeKeyWindow {return NO;}
-(BOOL)canBecomeMainWindow {return NO;}
-(BOOL)ignoresMouseEvents {return YES;}
@end


@interface AppController (Private)
-(void)_setEnabled:(BOOL)flag;
@end

static CGEventRef local_TapCallback(CGEventTapProxy proxy, CGEventType type,
                                    CGEventRef event, void* refcon);

@implementation AppController
-(void)awakeFromNib
{
  _status = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
  [_status setHighlightMode:YES];
  NSImage* icon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"caps" ofType:@"tif"]];
  [_status setImage:icon];
  [icon release];
  icon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"caps_alt" ofType:@"tif"]];
  [_status setAlternateImage:icon];
  [_status setMenu:_menu];
  [icon release];
  NSRect inhabitable = [[NSScreen mainScreen] visibleFrame];
  [_ssWindow setFrame:inhabitable display:YES];
  [_status setEnabled:YES];
  [self _setEnabled:YES];
  _tap = CGEventTapCreate(kCGSessionEventTap, kCGTailAppendEventTap, kCGEventTapOptionListenOnly,
                          CGEventMaskBit(kCGEventFlagsChanged), local_TapCallback, self);
  if (_tap)
  {
    _src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, _tap, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), _src, kCFRunLoopCommonModes);
  }
}

-(void)applicationWillTerminate:(NSNotification*)note
{
  #pragma unused (note)
  CFMachPortInvalidate(_tap);
  CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _src, kCFRunLoopCommonModes);
  CFRelease(_src);
  CFRelease(_tap);
  [[NSStatusBar systemStatusBar] removeStatusItem:_status];
  [_status release];
}

-(IBAction)toggle:(id)sender
{
  [self _setEnabled:([sender state] == NSOffState)];
}

-(void)_setEnabled:(BOOL)flag
{
  _enabled = flag;
  if (_tap) CGEventTapEnable(_tap, _enabled);
  [[_menu itemAtIndex:0] setState:(_enabled)? NSOnState:NSOffState];
  [self keycheck];
}

-(void)keycheck
{
  if (_enabled && alphaLock & GetCurrentEventKeyModifiers()) [_ssWindow orderFront:self];
  else [_ssWindow orderOut:self];
}

-(SSWindow*)window { return _ssWindow; }
-(BOOL)enabled { return _enabled; }

@end

static CGEventRef local_TapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* refcon)
{
  #pragma unused (proxy,type)
  AppController* myself = refcon;
  SSWindow* w = [myself window];
  if ([myself enabled] && kCGEventFlagMaskAlphaShift == (kCGEventFlagMaskAlphaShift & CGEventGetFlags(event))) [w orderFront:myself];
  else [w orderOut:myself];
  return event;
}


