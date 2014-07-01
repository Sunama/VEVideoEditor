//
//  VETimer.h
//  VideoEditor
//
//  Created by Sukit Sunama on 6/29/2557 BE.
//  Copyright (c) 2557 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VETimer : NSObject {
    double totalTime;
    int count;
    
    CFAbsoluteTime startTime;
}

@property (nonatomic) double totalTime;

- (void)startProcess;
- (void)endProcess;
- (float)averageTime;

@end
