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
#import <Cocoa/Cocoa.h>

@interface SSWindow : NSWindow
@end

@interface AppController : NSObject
{
  IBOutlet NSMenu*   _menu;
  IBOutlet SSWindow* _ssWindow;
  NSStatusItem*      _status;
  CFRunLoopSourceRef _src;
  CFMachPortRef      _tap;
  BOOL               _enabled;
}
-(IBAction)toggle:(id)sender;
-(void)keycheck;
-(SSWindow*)window;
-(BOOL)enabled;
@end
