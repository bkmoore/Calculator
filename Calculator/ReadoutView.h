/* readoutView */

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@interface ReadoutView : NSView
{
	NSMutableString *displayString;
	int op;
}

- (void)displayString:(NSString *)aString;
- (void)displayOp:(enum opCodes)operation;
- (void)pushChar:(NSString *)c;
- (void)clearDisplay;

@end
