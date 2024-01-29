#import "CalcWindow.h"

@implementation CalcWindow

- (void)findButtons {
	// check all the views recursively
	[keyTable removeAllObjects];
	[self checkView: [self contentView]];
}

- (void)checkView:(NSView *)aView {
	id view;
	NSEnumerator *enumerator;
	
	// Log which aView is being processed; see PB for output
	NSLog(@"checkView(%@)\n", aView);
	
	// Process the aView if it's in an NSMatrix
	if([aView isKindOfClass: [NSMatrix class]]) {
		[self checkMatrix: aView];
		return;
	}
	
	//Process the aView if it's an NSButton
	if([aView isKindOfClass: [NSButton class]]) {
		[self checkButton: aView];
		return;
	}
	
	// Recursively check all subviews of the window
	enumerator = [[aView subviews] objectEnumerator];
	while (view = [enumerator nextObject]) {
		[self checkView: view];
	}
}

- (void)checkButton:(NSButton *)aButton {
	NSString *title = [aButton title];
	
	// Check for a cell with a title exactly one character long.
	// Put both uppercase and lowercase strings into the dictionary.
	// The 'c' key on the keyboard will clear, not display a hex 'c'.
	
	if ([title length]==1 && [aButton tag] != 0x0c) {
		[keyTable setObject: aButton forKey: [title uppercaseString]];
		[keyTable setObject: aButton forKey: [title lowercaseString]];
	}
}

- (void)checkMatrix:(NSMatrix *)aMatrix {
	id button;
	NSEnumerator *enumerator;
	
	enumerator = [[aMatrix cells] objectEnumerator];
	while (button = [enumerator nextObject]) {
		[self checkButton: button];
	}
}

- (void)keyDown:(NSEvent *)theEvent {
	id button;
	
	button = [keyTable objectForKey:[theEvent characters]];
	
	if (button) {
		[button performClick: self];
	}
	else {
		[super keyDown:theEvent];
	}
}

- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(unsigned int)aStyle
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)flag
{
	keyTable = [[NSMutableDictionary alloc] init];
	[self setInitialFirstResponder: self];
	
	return [super initWithContentRect:contentRect
							styleMask:aStyle
							  backing:bufferingType
								defer:flag];
}

- (void) dealloc {
	[keyTable release];
	[super dealloc];
}

@end
