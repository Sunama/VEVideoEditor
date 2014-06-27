//
//  AudioComponent.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class VEAudioComposition;

@interface VEAudioComponent : NSObject {
    VEAudioComposition *composition;
    
    AVAssetReader *reader;
    AVAssetReaderTrackOutput *readerOutput;
    
    double presentTime;
    double duration;
}

@property (nonatomic, strong) VEAudioComposition *composition;

@property double presentTime;
@property double duration;

- (id)initWithURL:(NSURL *)url;
- (id)initWithPath:(NSString *)path;

- (void)beginExport;
- (CMSampleBufferRef)nextSampleBuffer;

@end
