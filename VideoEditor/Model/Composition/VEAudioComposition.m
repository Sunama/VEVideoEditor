//
//  AudioComposition.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEAudioComposition.h"
#import "VEAudioComponent.h"

@implementation VEAudioComposition

@synthesize editor;

- (id)init {
    self = [super init];
    
    if (self) {
        components = [NSMutableArray array];
    }
    
    return self;
}

- (void)addComponent:(VEAudioComponent *)component {
    component.composition = self;
    [components addObject:component];
}

- (void)removeComponent:(VEAudioComponent *)component {
    component.composition = nil;
    [components removeObject:component];
}

- (NSArray *)componentsAtTime:(double)time {
    NSMutableArray *componentsAt = [NSMutableArray array];
    
    for (VEAudioComponent *component in components) {
        if (time > component.presentTime && time <= component.presentTime + component.duration) {
            [componentsAt addObject:component];
        }
    }
    
    return componentsAt;
}

- (void)beginExport {
    for (VEAudioComponent *component in components) {
        [component beginExport];
    }
}

- (CMSampleBufferRef)nextSampleBuffer {
    for (VEAudioComponent *component in components) {
        return [component nextSampleBuffer];
    }
    
    return NULL;
}

@end
