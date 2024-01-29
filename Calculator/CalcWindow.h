/* CalcWindow */

#import <Cocoa/Cocoa.h>

@interface CalcWindow : NSWindow
{
	NSMutableDictionary *keyTable;
}

- (void)findButtons;
- (void)checkView:(NSView *)aView;
- (void)checkButton:(NSButton *)aButton;
- (void)checkMatrix:(NSMatrix *)aMatrix;
@end
