//
//  SessionExporter.m
//  Meditation Timer
//
//  Created by William Henderson on 2/24/06.
//	Free for any kind of peaceful use. 
//

#import "SessionExporter.h"



@implementation SessionExporter
- (BOOL)exportSession
{
	//First we need to generate the audio.

	QTMovie * theSession; //we'll just set it to the end chime first and then insert in front of it thereafter
	NSString *theChime = [[NSUserDefaults standardUserDefaults] stringForKey:@"endChime"];
	NSString *fileName = [[NSBundle mainBundle] pathForResource:theChime ofType:@""]; //find the chime in the bundle
	theSession = [[QTMovie alloc] initWithFile:fileName error:nil]; //initialize the movie with it
	[theSession setAttribute:[NSNumber numberWithBool:YES] forKey:@"QTMovieEditableAttribute"]; //and make sure its editable!
	int lengthBetweenStartAndNextBell = 0;//this will hold the period of time between the start and either the first period bell or the end bell (if there are no periods)

	//now work backwards through the session, inserting periods (if they exist) and period chimes until the session length has elapsed
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasPeriodChime"]) {
		//load the period chime
		QTMovie *periodChime;
		theChime = [[NSUserDefaults standardUserDefaults] stringForKey:@"periodChime"];
		fileName = [[NSBundle mainBundle] pathForResource:theChime ofType:@""]; //find the chime in the bundle
		periodChime = [[QTMovie alloc] initWithFile:fileName error:nil]; //initialize the movie with it

		int sessionLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"endTime"];  //in MINUTES
		int periodLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"periodTime"]; //in MINUTES
		int periodsInserted = 0;
		if(sessionLength % periodLength > 1) { //that is, if we've got at least 1 extra minute on top of the evenly divided periods, then we should take care of that first
			//insert the silence
			//                                                    \/convert from minutes to 1/600th seconds
			long finalPdLength = ((sessionLength % periodLength)* 36000) - [periodChime duration].timeValue; //this remainder period will last the remainder - the length of the chime periodChime before it.
			QTTime insertionPoint = QTMakeTime(0,600); //the scale is 600 as in 600 whatevers per second
			QTTime durationTime = QTMakeTime(finalPdLength,600); //how long the silence goes		
			QTTimeRange theRange = QTMakeTimeRange(insertionPoint,durationTime);
			[theSession insertEmptySegmentAt:theRange];
			//insert the chime
			durationTime = [periodChime duration];
			theRange = QTMakeTimeRange(insertionPoint,durationTime); //using the same insertion point
			[theSession insertSegmentOfMovie:periodChime timeRange:theRange atTime:insertionPoint];
			periodsInserted++;
		}
		while((periodsInserted + 1) * periodLength < sessionLength) { //we only want to go to the 2cnd period and insert the chime for the first, since there are n+1 periods and n chimes.
			//insert a silence period of periodLength - [chime duration]
			long pdLength = (periodLength * 36000) - [periodChime duration].timeValue;
			QTTime insertionPoint = QTMakeTime(0,600);
			QTTime durationTime = QTMakeTime(pdLength,600); //how long the silence goes		
			QTTimeRange theRange = QTMakeTimeRange(insertionPoint,durationTime);
			[theSession insertEmptySegmentAt:theRange];
			//insert the chime
			durationTime = [periodChime duration];
			theRange = QTMakeTimeRange(insertionPoint,durationTime); //using the same insertion point
			[theSession insertSegmentOfMovie:periodChime timeRange:theRange atTime:insertionPoint];
			periodsInserted++;
		}
		lengthBetweenStartAndNextBell = periodLength; //this will get that n+1'th period
	}

	else {//if there's no periodChimes (ie n=0), just make lengthBetweenStartChimeAndNextBell = the sessionLength
		lengthBetweenStartAndNextBell = [[NSUserDefaults standardUserDefaults] integerForKey:@"endTime"];
	}
	//finally, insert the startChime and delay if they exists

	if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasStartChime"]) {
		//load the start chime
		QTMovie *startChime;
		theChime = [[NSUserDefaults standardUserDefaults] stringForKey:@"startChime"];
		fileName = [[NSBundle mainBundle] pathForResource:theChime ofType:@""]; //find the chime in the bundle
		startChime = [[QTMovie alloc] initWithFile:fileName error:nil]; //initialize the movie with it
		
		int delayLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"startTime"];  //in MINUTES
		//first, insert the first (if any) period
		long pdLength = (lengthBetweenStartAndNextBell * 36000) - [startChime duration].timeValue;
		QTTime insertionPoint = QTMakeTime(0,600); 
		QTTime durationTime = QTMakeTime(pdLength,600); //how long the silence goes		
		QTTimeRange theRange = QTMakeTimeRange(insertionPoint,durationTime);
		[theSession insertEmptySegmentAt:theRange];
		//now insert the chime
		durationTime = [startChime duration];
		theRange = QTMakeTimeRange(insertionPoint,durationTime); //using the same insertion point
		[theSession insertSegmentOfMovie:startChime timeRange:theRange atTime:insertionPoint];
		//now insert the delay
		long delayDuration = (delayLength *36000);
		insertionPoint = QTMakeTime(0,600);
		durationTime = QTMakeTime(delayDuration,600); //how long the silence goes		
		theRange = QTMakeTimeRange(insertionPoint,durationTime);
		[theSession insertEmptySegmentAt:theRange];
	}
	else {//if no startTime, then we still need to insert lengthBetweenStartAndNextBell
		long pdLength = lengthBetweenStartAndNextBell * 36000;
		QTTime insertionPoint = QTMakeTime(0,600);
		QTTime durationTime = QTMakeTime(pdLength,600); //how long the silence goes		
		QTTimeRange theRange = QTMakeTimeRange(insertionPoint,durationTime);
		[theSession insertEmptySegmentAt:theRange];
	}

	//PHEW! now do the exporting
	NSDictionary* theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool: YES], QTMovieExport,
		[NSNumber numberWithLong: kQTFileTypeMP4], QTMovieExportType, nil]; //here is our file export information
	
	BOOL result = [theSession writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"MeditationSession.m4a"] 
							withAttributes:theAttributes];
	if(!result)
	{
		NSLog(@"Error writing session to audio file");
		return NO;
	}
	
	return YES;
}

@end
