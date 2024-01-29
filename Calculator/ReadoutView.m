#import "readoutView.h"

@implementation ReadoutView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		displayString = [[NSMutableString alloc] init];
		op = NOOP;
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	float width = [self bounds].size.width;
	float height = [self bounds].size.height;
	
	[[NSColor colorWithCalibratedRed: 0.80 green: 0.56 blue: 0.25 alpha: 100] set];
	NSRectFill([self bounds]);

	
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	[attrs setObject: [NSFont fontWithName:@"Helvetica" size: 40.0] 
			  forKey: NSFontAttributeName];
	[attrs setObject: [NSColor blackColor] forKey: NSForegroundColorAttributeName];
	
	id str = [[NSMutableAttributedString alloc] 
	initWithString: displayString
		attributes: attrs];
	
	// get the graphical width of the string object
	float strlen = [str size].width;
	float strheight = [str size].height;
	
	[str drawAtPoint: NSMakePoint((width-strlen-10),(0.5*(height-strheight)))];
	
	////// Display the Opcode if one is defined //////
	NSString *s;
	
	// draw the opcode in the corner
	
	switch(op) {
		case PLUS:
			s = @"+";
			break;
		case SUBTRACT:
			s = @"-";
			break;
		case MULTIPLY:
			s = @"*";
			break;
		case DIVIDE:
			s = @"Ö";
			break;
		case EQUALS:
			s = @"=";
			break;
		case NOOP:
			s = @" ";
			break;
		default:
			s = @" ";
	}
	
	[attrs setObject: [NSFont fontWithName:@"Helvetica" size: 60.0] 
			  forKey: NSFontAttributeName];
	
	id opstr = [[NSMutableAttributedString alloc] 
		initWithString: s
			attributes: attrs];
	
	[opstr drawAtPoint: NSMakePoint(10, 0.5*(height - [opstr size].height))];
}

- (void)displayString:(NSString *)aString
{
	[aString retain];
	[displayString setString: aString];
	NSLog(displayString);
	[self setNeedsDisplay: YES];
}

- (void)displayOp:(enum opCodes)operation
{
	op = operation;
	[self setNeedsDisplay: YES];
}

- (void)pushChar:(NSString *)c
{
	[c retain];
	[displayString appendString: c];
	[c release];
	[self setNeedsDisplay: YES];
}

- (void)clearDisplay
{
	[displayString setString: @""];
	op = NOOP;
	[self setNeedsDisplay: YES];
}

@end
