//
//  AudioComposition.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class VEVideoEditor, VEAudioComponent;

@interface VEAudioComposition : NSObject {
    VEVideoEditor *editor;
    NSMutableArray *components;
}

@property (nonatomic, strong) VEVideoEditor *editor;

- (void)addComponent:(VEAudioComponent *)component;
- (void)removeComponent:(VEAudioComponent *)component;
- (NSArray *)componentsAtTime:(double)time;

- (void)beginExport;
- (CMSampleBufferRef)nextSampleBuffer;

@end
