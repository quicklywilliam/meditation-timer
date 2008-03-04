 //
//  controller.m
//  Meditation Timer
//
//  Created by William Henderson on 2/24/06.
//	Free for any kind of peaceful use. 
//

#import "controller.h"


@implementation controller
- (id) init {
	//loads the sounds present in the resources folder into an array containing their names
	[super init];
	sessTimer = [[SessionTimer alloc] init];
	sessExporter = [[SessionExporter alloc] init];
	NSBundle *chimesBundle;
	chimesBundle = [NSBundle mainBundle];
	NSArray *chimesPaths = [chimesBundle pathsForResourcesOfType:@"mp3" inDirectory:@""];
	NSEnumerator *chimesPathsEnumerator = [chimesPaths objectEnumerator];
	id chimePath;
	chimesNames = [[NSMutableArray alloc] init];
	//go through and turn the paths into nice displayable names (we could have used an NSDict to store both...)
	while(chimePath = [chimesPathsEnumerator nextObject])
	{
		[chimesNames addObject:[chimePath lastPathComponent]];
	}
	if([chimesNames objectAtIndex:0] == nil) {
		NSLog(@"Error: no chimes could be loaded!"); //this should never happen unless the user has monkeyed with the bundle...
	}
	return self;
}
#pragma mark GUI CODE
- (void)awakeFromNib {
	[theWindow setDelegate:self];
	[self resizeWindow:self];
	[minCount setTarget: self];
	[minCount setAction:@selector(setCountUpDown:)];
	[minCount sendActionOn:NSLeftMouseDownMask];
	[disclosureButton setBezelStyle: NSRoundedDisclosureBezelStyle];
	[disclosureButton setButtonType: NSPushOnPushOffButton];
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if(standardUserDefaults) {		
		if(![standardUserDefaults boolForKey:@"doneFirstRunV12"]) {
			[theWindow makeKeyAndOrderFront:self];
			[NSApp beginSheet:welcomeWindow modalForWindow:theWindow
				modalDelegate:self didEndSelector:NULL contextInfo:nil];
			[standardUserDefaults setBool:YES forKey:@"doneFirstRunV12"];
			[standardUserDefaults setBool:YES forKey:@"countUp"];
			//make sure we're not going to have null values here...
			[standardUserDefaults setObject:[chimesNames objectAtIndex:0] forKey:@"endChime"];
			[standardUserDefaults setObject:[chimesNames objectAtIndex:0] forKey:@"startChime"];
			[standardUserDefaults setObject:[chimesNames objectAtIndex:0] forKey:@"periodChime"];
		}
	}
}
- (void)windowWillClose:(NSNotification *)aNotification {
	[NSApp terminate:self];
}
-(void)hideButtonAndKillText {
	[stopButton setHidden:YES];
	[startButton setHidden:NO];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[minCount setStringValue:@"-"];
}
-(IBAction)setCountUpDown:(id) sender {
	if([startButton isHidden] && [sessTimer timeCount] >= 0) {
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"countUp"]) {
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"countUp"];
		}
		else {
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"countUp"];
		}
		[self updateMinText];
	}
}
-(void)updateMinText {
	int theMins = [sessTimer timeCount];
	if(theMins == -1) {
		[minCount setStringValue:@"Starting in 1 minute"];
	}
	else if(theMins < 0) {
		int thePosMins = theMins * -1;
		NSString *minText = [NSString stringWithFormat:@"Starting in %i Minutes",thePosMins];
		[minCount setStringValue:minText];
	}	
	else {
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"countUp"]) {
			if(theMins == 0) {
				[minCount setStringValue:@"0 Minutes"];
			}
			else if(theMins == 1){
				[minCount setStringValue:@"1 Minute"];
			}
			else {
				NSString *minText = [NSString stringWithFormat:@"%d Minutes",theMins];
				[minCount setStringValue:minText];
			}
		}
		else {
			int totalMins = [[NSUserDefaults standardUserDefaults] integerForKey:@"endTime"];
			if((totalMins - theMins) > 1) {
				NSString *minText = [NSString stringWithFormat:@"%d Minutes left",(totalMins - theMins)];
				[minCount setStringValue:minText];
			}
			else {
				[minCount setStringValue:@"1 Minute left"];
			}
		}
	}
}
- (IBAction)resizeWindow:(id)sender;
{
	NSRect windowFrame;
	NSRect newWindowFrame;
	
	windowFrame = [theWindow frame];
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isExpandedState"]) { //then the user just clicked collapse...or it started as such

		newWindowFrame = NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - 129, 
									447, 129);
		NSColor *color = [NSColor colorWithPatternImage:[NSImage imageNamed:@"gradient_small"]];
		[theWindow setBackgroundColor:color];	
	}
	else{
		newWindowFrame = NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - 203, 
								447, 203);
		NSColor *color = [NSColor colorWithPatternImage:[NSImage imageNamed:@"gradient_big"]];
		[theWindow setBackgroundColor:color];	
	}
	[theWindow setFrame:newWindowFrame display:YES animate:YES];
}
-(IBAction)welcomeContinue:(id) sender {
	[welcomeWindow orderOut:nil];
	[NSApp endSheet:welcomeWindow];
}
-(IBAction)payPalDonate:(id) sender{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=william%2ec%2ehenderson%40gmail%2ecom&item_name=Meditation%20Timer&no_shipping=1&return=http%3a%2f%2fwhenderson%2eblogspot%2ecom&no_note=1&tax=0&currency_code=USD&bn=PP%2dDonationsBF&charset=UTF%2d8"]];
}
-(IBAction)visitWebsite:(id) sender{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://whenderson.blogspot.com"]];
}
-(IBAction)visitFlexTime:(id) sender{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.red-sweater.com/flextime/"]];
}
-(IBAction)showAbout:(id) sender{
	[aboutWindow makeKeyAndOrderFront:nil];
}
#pragma mark Function  Calls
-(IBAction)play:(id) sender
{
	NSString * theTitle = [sender titleOfSelectedItem];
	if(![theTitle isEqualToString:@"Nothing"]) {
		[sessTimer playChime:theTitle];
	}
}
-(IBAction)startSession:(id) sender
{
	[sessTimer stopPlayingChime];
	if(([[totalSessionMins stringValue] intValue] > 0) && (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPeriodChime"] || [[periodMins stringValue] intValue] < [[totalSessionMins stringValue] intValue]))  //make sure we have a valid number of minutes for the session and periods..
	{
		[stopButton setHidden:NO];
		[startButton setHidden:YES];
		[[NSNotificationCenter defaultCenter] addObserver: self
			selector: @selector(updateMinText) name: @"timerDidFire" object: sessTimer];
		[[NSNotificationCenter defaultCenter] addObserver: self
			selector: @selector(hideButtonAndKillText) name: @"timerDidStop" object: sessTimer];
		[sessTimer startTimer];
		[self updateMinText];
	}
	else {
		NSAlert* alert=[[NSAlert alloc] init]; 
		[alert addButtonWithTitle:@"OK"]; 
		[alert setMessageText:@"Please enter a longer session length."]; 
		[alert setInformativeText:@"The number of minutes in-between periodic chimes cannot exceed the total session length.  Ensure that periodic chimes are off or are set to a value smaller than the length of the session."]; 
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		[alert release];
	}
}
-(IBAction)stopSession:(id) sender
{
	[self hideButtonAndKillText];
	[sessTimer stopTimer];
}
-(IBAction)exportSession:(id) sender {
	NSAlert* confirm=[[NSAlert alloc] init]; 
	[confirm addButtonWithTitle:@"OK"];
	[confirm addButtonWithTitle:@"Cancel"]; 
	[confirm setMessageText:@"Export Session to iTunes"]; 
	[confirm setInformativeText:@"Exporting can take quite a while (several minutes or longer on slow computers) to complete.  I suggest you go make a cup of tea.  Continue?"]; 
	[confirm setAlertStyle:NSInformationalAlertStyle];
	int returnCode = [confirm runModal];
	if(returnCode == NSAlertFirstButtonReturn) {
		[NSApp beginSheet:progressWindow modalForWindow:theWindow
			modalDelegate:self didEndSelector:NULL contextInfo:nil];
		[progressIndicator setUsesThreadedAnimation:YES];
		[progressIndicator startAnimation: self];
		if(![sessExporter exportSession]) {
			NSAlert* alert=[[NSAlert alloc] init]; 
			[alert addButtonWithTitle:@"OK"]; 
			[alert setMessageText:@"The Meditation Session Could not be saved to a file"]; 
			[alert setInformativeText:@"There was an error saving the audio file to the disk.  Check that you have the lastest version of Quicktime and at least OS 10.3 installed, and then try again."]; 
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert runModal];
			[alert release];
		}
		[progressIndicator stopAnimation: self];
		[progressWindow orderOut:nil];
		[NSApp endSheet:progressWindow];
		//Now run the applescript that will take our newfangled audio file and import it into iTunes
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"exportToiTunes.scpt" ofType:@""];
		NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath]; //find the chime in the bundle
		NSAppleScript *theScript = [[NSAppleScript alloc] initWithContentsOfURL:fileURL error:nil];
		[theScript executeAndReturnError:nil];
	}
	[confirm release];
}
@end
