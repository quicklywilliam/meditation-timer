//
//  SessionTimer.h
//  Meditation Timer
//
//  Created by William Henderson on 2/24/06.
//	Free for any kind of peaceful use. 
//

#import <Cocoa/Cocoa.h>


@interface SessionTimer : NSObject {
	NSMovie *playingChime;
	NSTimer *theTimer;
	int timeCount;
	}
-(int)timeCount;
-(void)playChime:(NSString *) chimeName;
-(void)stopPlayingChime;
-(void)startTimer;
-(void)stopTimer;
-(void)timerFire;

@end
