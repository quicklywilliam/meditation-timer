//
//  SessionTimer.m
//  Meditation Timer
//
//  Created by William Henderson on 2/24/06.
//	Free for any kind of peaceful use. 

#import "SessionTimer.h"


@implementation SessionTimer
-(id) init
{
	timeCount = 0;
	playingChime = nil;
	[super init];
	return self;

}
#pragma mark Audio Routines
-(void)playChime:(NSString *) chimeName {
	[self stopPlayingChime];
	NSMovie *endChime;
	//error checking code for playing sounds needed...
	NSString *fileName = [[NSBundle mainBundle] pathForResource:chimeName ofType:@""]; //find the chime in the bundle
	endChime = [[NSMovie alloc] 
			initWithURL:[NSURL fileURLWithPath: fileName] byReference: NO];
	GoToBeginningOfMovie([endChime QTMovie]);
	StartMovie ([endChime QTMovie]);
	playingChime = endChime;
}
-(void)stopPlayingChime {
	if(playingChime != nil) { //if a sound has played, make sure its done...
		StopMovie ([playingChime QTMovie]);
		[playingChime release];
		playingChime = nil;
	}
}
#pragma mark Timer Routines
-(void)startTimer
{
	//all the options are stored in the user defaults system, since they are continually updates
	//this means the main window is actually a preferences window, though it is more accessible
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasStartChime"]) {
		timeCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"startTime"] * -1;
	}
	else {
		timeCount = 0;
	}
	//!change 3 to 60 after debugging√
	theTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self
											  selector:@selector(timerFire) userInfo:self repeats:YES];
}
-(void)stopTimer {
	[theTimer invalidate];
	timeCount = 0;
	[[NSNotificationCenter defaultCenter] 
		postNotificationName: @"timerDidStop" object: self];
}
-(void)timerFire { 
	timeCount++;
	if(timeCount == 0) { //the start delay time is up
		[self playChime:[[NSUserDefaults standardUserDefaults] stringForKey:@"startChime"]];
	}
	else if(timeCount == [[NSUserDefaults standardUserDefaults] integerForKey:@"endTime"])//the end time is up
	{
		[self stopTimer];
		[self playChime:[[NSUserDefaults standardUserDefaults] stringForKey:@"endChime"]];
	}
	else if (timeCount > 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPeriodChime"] &&
		(timeCount % [[NSUserDefaults standardUserDefaults] integerForKey:@"periodTime"] == 0))
	{
		[self playChime:[[NSUserDefaults standardUserDefaults] stringForKey:@"periodChime"]];
	}
	[[NSNotificationCenter defaultCenter] 
		postNotificationName: @"timerDidFire" object: self];
}
-(int)timeCount {
	return timeCount;
}


@end
