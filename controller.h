//
//  controller.h
//  Meditation Timer
//
//  Created by William Henderson on 2/24/06.
//	Free for any kind of peaceful use. 
//

#import <Cocoa/Cocoa.h>
#import "SessionTimer.h"
#import "SessionExporter.h"
#import "WBTextField.h"

@interface controller : NSObject {
	IBOutlet NSTextField *totalSessionMins;
	IBOutlet NSTextField *periodMins;
	IBOutlet NSTextField *delayMins;
	IBOutlet NSPopUpButton *endChime;
	IBOutlet NSPopUpButton *periodChime;
	IBOutlet NSPopUpButton *delayChime;
	IBOutlet WBTextField *minCount;
	IBOutlet NSButton *stopButton;
	IBOutlet NSButton *startButton;
	IBOutlet NSButton *disclosureButton;
	IBOutlet NSWindow *theWindow;
	IBOutlet NSWindow *progressWindow;
	IBOutlet NSWindow *welcomeWindow;
	IBOutlet NSWindow *aboutWindow;
	IBOutlet NSProgressIndicator *progressIndicator;
	SessionTimer *sessTimer;
	SessionExporter *sessExporter;
	NSMutableArray *chimesNames;
}
-(IBAction)resizeWindow:(id)sender;
-(IBAction)showAbout:(id)sender;
-(IBAction)welcomeContinue:(id)sender;
-(IBAction)payPalDonate:(id)sender;
-(IBAction)visitWebsite:(id) sender;
-(IBAction)visitFlexTime:(id) sender;
-(IBAction)play:(id) sender;
-(IBAction)startSession:(id) sender;
-(IBAction)stopSession:(id) sender;
-(IBAction)exportSession:(id) sender;
-(IBAction)setCountUpDown:(id) sender;
-(void)hideButtonAndKillText;
-(void)updateMinText;


@end
