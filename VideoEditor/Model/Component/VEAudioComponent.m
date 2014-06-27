//
//  AudioComponent.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEAudioComponent.h"
#import "VEUtilities.h"
#import "VEAudioComposition.h"
#import "VEVideoEditor.h"

@implementation VEAudioComponent

@synthesize composition, presentTime, duration;

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:url options:inputOptions];
        
        reader = [AVAssetReader assetReaderWithAsset:inputAsset error:nil];
        
        NSMutableDictionary* audioReadSettings = [NSMutableDictionary dictionary];
        [audioReadSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM]
                             forKey:AVFormatIDKey];
        
        AVAssetTrack *audioTrack = [[inputAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        duration = CMTimeGetSeconds(inputAsset.duration);
        presentTime = 0;
        
        readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioReadSettings];
        
        [reader addOutput:readerOutput];
        
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    return [self initWithURL:[VEUtilities convertURLFromPath:path]];
}

- (void)beginExport {
    if ([reader startReading] == NO) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:@"Cannot to start reading audio" forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:4 userInfo:info];
        
        [composition.editor.delegate videoEditor:composition.editor exportFinishWithError:error];
    }
}

- (CMSampleBufferRef)nextSampleBuffer {
    while (reader.status != AVAssetReaderStatusReading) {
        NSLog(@"sleep");
        usleep(0.1f);
    }
    
    return [readerOutput copyNextSampleBuffer];
}

@end
