#import <Cocoa/Cocoa.h>
#import "ReadoutView.h"

// These op codes are used to process
// key inputs and to pass the operation
// message to the readoutView.
enum opCodes {
	PLUS = 1001,
	SUBTRACT = 1002,
	MULTIPLY = 1003,
	DIVIDE = 1004,
	EQUALS = 1005, 
	NOOP = 1006
};


@interface Controller : NSObject  {
    IBOutlet id readout;
	BOOL enterFlag;
	BOOL yFlag;
	BOOL errorFlag;
	BOOL decimalFlag;
	BOOL unaryMinusFlag;
	BOOL digitEnteredFlag;
	int decimalPlace;
	int operation;
	int radix;
	double X;
	double Y;
	IBOutlet id aboutPanel;
	IBOutlet id radixPopUp;
	IBOutlet id keyPad;
	IBOutlet id decimalKey;
	IBOutlet id unaryMinusKey;
}

- (IBAction)clear:(id)sender;
- (IBAction)clearAll:(id)sender;
- (IBAction)enterOP:(id)sender;
- (IBAction)enterDigit:(id)sender;
- (IBAction)doUnaryMinus:(id)sender;
- (IBAction)decimalKey:(id)sender;
- (void)displayX;
- (void)displayErr;
- (void)showAboutPanel:(id)sender;
- (IBAction)setRadix:(id)sender;
@end


@interface Controller(NSApplicationNotifications)
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
@end