//
//  VETimer.m
//  VideoEditor
//
//  Created by Sukit Sunama on 6/29/2557 BE.
//  Copyright (c) 2557 Afternoon Tea Break. All rights reserved.
//

#import "VETimer.h"

@implementation VETimer

@synthesize totalTime;

- (void)startProcess {
    startTime = CFAbsoluteTimeGetCurrent();
}

- (void)endProcess {
    totalTime += (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0f;
    count++;
}

- (float)averageTime {
    return totalTime / (float)count;
}

@end
