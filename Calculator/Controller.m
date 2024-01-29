#import "Controller.h"
#import "CalcWindow.h"


NSString *ltob(unsigned long val)
{
	int i;
	char buf[53];
	
	for (i=0; i<32; i++) {
		buf[i] = (val & (1<<(31-i)) ? '1': '0');
	}
	buf[32] = '\0';
	
	for (i=0; i<32; i++) {
		if (buf[i] != '0') {
			return [NSString stringWithCString: buf+i];
		}
	}
	return [NSString stringWithCString: buf+31];
}

@implementation Controller

- (IBAction)clear:(id)sender {
	X = 0.0;
	decimalFlag = NO;
	decimalPlace = 1;
	[decimalKey setEnabled: TRUE];
	unaryMinusFlag = NO;
	[unaryMinusKey setEnabled: TRUE];
	digitEnteredFlag = NO;
	[readout clearDisplay];

	[self displayX];
}


- (IBAction)clearAll:(id)sender {
	X = 0.0;
	Y = 0.0;
	operation = NOOP;
	yFlag = NO;
	enterFlag = NO;
	decimalFlag = NO;
	[decimalKey setEnabled: TRUE];
	decimalPlace = 1;
	unaryMinusFlag = NO;
	[unaryMinusKey setEnabled: TRUE];
	digitEnteredFlag = NO;
	[readout displayOp: operation];
	[readout clearDisplay];

	[self displayX];
}


- (IBAction)enterOP:(id)sender {
	if (yFlag && digitEnteredFlag) {
		switch (operation) {
			case PLUS:
				X = Y + X;
				break;
			case SUBTRACT:
				X = Y - X;
				break;
			case MULTIPLY:
				X = Y * X;
				break;
			case DIVIDE:
				if(X != 0) {     // check for divide by zero
					X = Y / X;
				} else {
					errorFlag = YES;
				}
				break;
		}
	}
	
	if (errorFlag) {   // attempted to divide by zero
		[self displayErr];
		errorFlag = NO;
		}
	else {
		Y = X;
	    yFlag = YES;
	
	    operation = [[sender selectedCell] tag];
		enterFlag = YES;
		decimalFlag = NO;
		decimalPlace = 1;
		[decimalKey setEnabled: TRUE];
		unaryMinusFlag = NO;
		[unaryMinusKey setEnabled: TRUE];
		digitEnteredFlag = NO;
		[self displayX];
		[readout displayOp: operation];
	}
}

- (IBAction)enterDigit:(id)sender {
	
	NSString *s = nil;
	s = [NSString stringWithFormat: @"%x", [[sender selectedCell] tag]];

	// check if an operation has been entered
	// if so, then move the accumulator to Y and clear
	// the accumulator for a new value
	if (enterFlag) {
		Y = X;
		X = 0.0;
		enterFlag = NO;
		[readout clearDisplay];
		[self displayX];
		[readout displayOp: operation];
	}
	
	// ignore zero keypresses if decimal is not set
	if([[sender selectedCell] tag] == 0 && X == 0 && decimalFlag == FALSE) return;

	
	// add character to display string
	// Note this method only adds the character to the display
	// string and does not display the complete value
	// of the X register. That only happens when
	// an operation is performed.
	//
	// it is implemented this way because leading decimal zeros
	// do not change the value of X, so aren't displayed
	// with the displayX method.
	// 
	// drop the leading zero if required by clearing the display
	// note if the minus key was entered before a digit, then display
	// the minus character on the display
	if([[sender selectedCell] tag] != 0 && X == 0 && decimalFlag == FALSE) {
		[readout clearDisplay];
		if(unaryMinusFlag == TRUE){
			[readout pushChar: @"-"];
		}
	}
	//
	digitEnteredFlag = YES;
	[readout pushChar: s];
	
	// update accumulator value with new value
	// Note, it is necessary to keep track of the decimal
	// place for entering decimal values
	if (unaryMinusFlag == NO) {
		if (decimalFlag) {
			X = X + [[sender selectedCell] tag]/pow(radix,decimalPlace);
			decimalPlace++;
		} else {
			X = (X*radix) + [[sender selectedCell] tag];
		}
	}
	
	if (unaryMinusFlag == YES) {
		if (decimalFlag) {
			X = X - [[sender selectedCell] tag]/pow(radix,decimalPlace);
			decimalPlace++;
		} else {
			X = (X*radix) - [[sender selectedCell] tag];
		}
	}
}

- (IBAction)doUnaryMinus:(id)sender {
	X = -X;
	unaryMinusFlag = YES;
	[unaryMinusKey setEnabled: FALSE];
	[readout clearDisplay];
	[self displayX];
}


- (void)displayX {
	
	NSString *s = nil;
	
	switch (radix) {
		case 16:
			s = [NSString stringWithFormat: @"%x", (int)X];
			break;
		case 10:
			s = [NSString stringWithFormat: @"%15.10g", X];
			break;
		case 8:
			s = [NSString stringWithFormat: @"%o", (int)X];
			break;
		case 2:
			s = ltob((int)X);
			break;
	}
	[readout displayString: s];
}

- (void)displayErr {
	[readout displayString: @"Error"];
}

- (void)showAboutPanel:(id)sender {
	if ( aboutPanel == nil) {
		if (![NSBundle loadNibNamed:@"AboutPanel.nib" owner:self] )	{
			NSLog(@"Load of AboutPanel.xib failed");
			return;
		}
	}
	[aboutPanel makeKeyAndOrderFront: nil];
}

- (IBAction)decimalKey:(id)sender 
{		
	// check if an operation has been entered
	// and this is a new number
	if (enterFlag) {
		Y = X;
		X = 0.0;
		enterFlag = NO;
		[readout clearDisplay];
	}
	// check if decimal hasn't already been seet
	// before setting the flag and appending the
	// string
	if(!decimalFlag) {
		decimalFlag = YES;
		digitEnteredFlag = YES;
		[readout pushChar: @"."];
		[decimalKey setEnabled: FALSE];
	}
}

- (IBAction)setRadix:(id)sender 
{	
	NSEnumerator *enumerator;
	NSCell *cell;
	int oldRadix = radix;
	
	radix = [[sender selectedCell] tag];  // get new radix
	
	// resize keypad if necessary
	if (radix != oldRadix && (radix==16 || oldRadix==16)) {
		double ysize = [keyPad cellSize].height * 2 + [keyPad intercellSpacing].height * 2;
		
		int row, col;
		NSWindow *win = [keyPad window];
		NSRect frame = [win frame];
		
		// If switching to radix 16, then grow the window
		// and keep the title bar in the same place
		if (radix == 16) {
			frame.size.height += ysize;
			frame.origin.y -= ysize;
			[win setFrame: frame display: YES animate: YES];
			
			for (row=0; row<2; row++) {
				[keyPad insertRow: 0];
				
				for (col=0; col<3; col++) {
					int val = 10 + row*3+col;
					cell = [keyPad cellAtRow:0 column: col];
					[cell setTag: val];
					[cell setTitle: [NSString stringWithFormat: @"%X", val]];
				}
			}
			[keyPad sizeToCells];
			[keyPad setNeedsDisplay: YES];
		}
		
		// If switching away from base 16, shrink the window
		// (keeping the title bar in the same place)
		else {
			frame.size.height -= ysize;
			frame.origin.y += ysize;
			[keyPad removeRow: 0];
			[keyPad removeRow: 0];
			[keyPad sizeToCells];
			[keyPad setNeedsDisplay: YES];
			[win setFrame: frame display: YES animate: YES];
		}
	}
		
	// Disable the buttons that are higher than the selected radix
	enumerator = [[keyPad cells] objectEnumerator];
	
	while (cell = [enumerator nextObject]) {
		[cell setEnabled: ([cell tag] < radix)];
	}
	
	if(radix == 10) {    // only use decimal key if base is 10
		[decimalKey setEnabled: YES];
		[unaryMinusKey setEnabled: YES];
	} else {
		[decimalKey setEnabled: NO];
		[unaryMinusKey setEnabled: NO];
	}
	[self displayX];
	
	// Radix has changed, set up the NSMutableDictionary for the new base.
	[ (CalcWindow *)[keyPad window] findButtons];
}

@end

@implementation Controller(ApplicationNotifications)

-(void)applicationDidFinishLaunching:(NSNotification*)notification
{
    radix = [ [radixPopUp selectedItem] tag];
    [self clearAll:self];
	
	// Set up the NSMutableDictionary
	[ (CalcWindow *)[keyPad window] findButtons];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp terminate:self];
}



@end

