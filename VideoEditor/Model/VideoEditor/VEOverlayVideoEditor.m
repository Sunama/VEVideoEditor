//
//  VEOverlayVideoEditor.m
//  VideoEditor
//
//  Created by Apple Macintosh on 4/17/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEOverlayVideoEditor.h"
#import "VEPreviewViewController.h"
#import "VEOverlayVideoComposition.h"
#import "VEAudioComposition.h"
#import "VEUtilities.h"
#import "VEVideoTrack.h"
#import "VEAudioComponent.h"

@implementation VEOverlayVideoEditor

@synthesize inputAsset, transform, presentationTime;

- (id)init {
    self = [super init];
    
    if (self) {
        videoComposition = [[VEOverlayVideoComposition alloc] init];
        audioComposition = [[VEAudioComposition alloc] init];
        previewViewController = [[VEPreviewViewController alloc] init];
        
        audioComposition.editor = self;
        previewViewController.editor = self;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [self init];
    
    if (self) {
        //Video
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        inputAsset = [[AVURLAsset alloc] initWithURL:url options:inputOptions];
        
        reader = [AVAssetReader assetReaderWithAsset:inputAsset error:nil];
        
        NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
        [outputSettings setObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]  forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
        
        AVAssetTrack *videoTrack = [inputAsset tracksWithMediaType:AVMediaTypeVideo][0];
        transform = videoTrack.preferredTransform;
        duration = CMTimeGetSeconds(inputAsset.duration);
        fps = videoTrack.nominalFrameRate;
        
        if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
            orientation = UIImageOrientationUp;
        }
        if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
            orientation = UIImageOrientationDown;
        }
        if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
            orientation = UIImageOrientationLeft;
        }
        if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
            orientation = UIImageOrientationRight;
        }
        
        readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:outputSettings];
        
        [reader addOutput:readerOutput];
        
        //Player
        if (orientation == UIImageOrientationDown || orientation == UIImageOrientationUp) {
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.width)];
            size = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        }
        else {
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height)];
            size = videoTrack.naturalSize;
        }
        //End
        
        videoComposition.editor = self;
        
        //Audio
        VEAudioComponent *audioComponent = [[VEAudioComponent alloc] initWithURL:url];
        
        [audioComposition addComponent:audioComponent];
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    return [self initWithURL:[VEUtilities convertURLFromPath:path]];
}

- (void)exportToURL:(NSURL *)url {
    [VEUtilities removeFileAtURL:url];
    isProcessing =  YES;
    
    NSError *error = nil;
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(assetWriter);
    assetWriter.shouldOptimizeForNetworkUse = NO;
    
    //Video
    if ([encode length] == 0) {
        encode = AVVideoCodecH264;
    }
    
    NSDictionary *videoSettings;
    
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight) {
        videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                         encode, AVVideoCodecKey,
                         [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                         [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                         nil];
    }
    else {
        videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                         encode, AVVideoCodecKey,
                         [NSNumber numberWithInt:size.height], AVVideoWidthKey,
                         [NSNumber numberWithInt:size.width], AVVideoHeightKey,
                         nil];
    }
    
    AVAssetWriterInput *assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    assetWriterVideoInput.transform = transform;
    
    NSParameterAssert(assetWriterVideoInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterVideoInput]);
    [assetWriter addInput:assetWriterVideoInput];
    
    //Audio
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSData dataWithBytes:&channelLayout length: sizeof(AudioChannelLayout) ], AVChannelLayoutKey,
                                   [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                                   nil];
    AVAssetWriterInput *assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    NSParameterAssert(assetWriterAudioInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterAudioInput]);
    [assetWriter addInput:assetWriterAudioInput];
    
    if (![assetWriter startWriting]) {
        isProcessing = NO;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:[NSString stringWithFormat:@"Cannot to start writing for reason : %@", error.localizedDescription] forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:1 userInfo:info];
        
        [delegate videoEditor:self exportFinishWithError:error];
    }
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    [videoComposition beginExport];
    [audioComposition beginExport];
    
    currentFrame = 0;
    __block BOOL isFinishVideo = NO;
    __block BOOL isFinishAudio = NO;
    
    if ([reader startReading] == NO) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:@"Cannot to start reading video" forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:3 userInfo:info];
        
        [delegate videoEditor:self exportFinishWithError:error];
    }
    
    //Write Video
    dispatch_queue_t videoQueue = dispatch_queue_create("Wite Video", NULL);
    
    [assetWriterVideoInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
        presentationTime = kCMTimeZero;
        
        while ([assetWriterVideoInput isReadyForMoreMediaData]) {
            while (reader.status != AVAssetReaderStatusReading) {
                usleep(0.1f);
            }
            
            CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
            if (sample) {
                presentationTime = CMSampleBufferGetPresentationTimeStamp(sample);
                CGImageRef cgImage = [videoComposition nextFrameImage];
                
                /* Composite over video frame */
                
                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sample);
                
                // Lock the image buffer
                CVPixelBufferLockBaseAddress(imageBuffer, 0);
                
                // Get information about the image
                uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
                size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
                size_t width;
                size_t height;
                
                if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight) {
                    width = CVPixelBufferGetWidth(imageBuffer);
                    height = CVPixelBufferGetHeight(imageBuffer);
                }
                else {
                    width = CVPixelBufferGetHeight(imageBuffer);
                    height = CVPixelBufferGetWidth(imageBuffer);
                }
                
                width = CVPixelBufferGetWidth(imageBuffer);
                height = CVPixelBufferGetHeight(imageBuffer);
                
                // Create a CGImageRef from the CVImageBufferRef
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
                
                /*** Draw into context ref to draw over video frame ***/
                /*
                if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight) {
                    CGContextDrawImage(newContext, CGRectMake(0.0f, 0.0f, size.width, size.height), cgImage);
                }
                else {
                    CGContextDrawImage(newContext, CGRectMake(0.0f, 0.0f, size.height, size.width), cgImage);
                }
                */
                
                CGContextDrawImage(newContext, CGRectMake(0.0f, 0.0f, width, height), cgImage);
                
                // We unlock the  image buffer
                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                
                // We release some components
                CGContextRelease(newContext);
                CGColorSpaceRelease(colorSpace);
                //CGImageRelease(cgImage);
                
                /* End composite */
                
                [assetWriterVideoInput appendSampleBuffer:sample];
                CFRelease(sample);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate videoEditor:self progressTo:CMTimeGetSeconds(presentationTime) / duration];
                });
                
                currentFrame++;

            }
            else {
                [assetWriterVideoInput markAsFinished];
                
                isFinishVideo = YES;
                
                if (isFinishAudio) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                        });
                    }];
                }
                
                break;
            }
        }
    }];
    
    //Write Audio
    dispatch_queue_t audioQueue = dispatch_queue_create("Wite Audio", NULL);
    
    [assetWriterAudioInput requestMediaDataWhenReadyOnQueue:audioQueue usingBlock:^ {
        while(assetWriterAudioInput.readyForMoreMediaData)
        {
            CMSampleBufferRef nextBuffer = [audioComposition nextSampleBuffer];
            if(nextBuffer != NULL) {
                //append buffer
                [assetWriterAudioInput appendSampleBuffer:nextBuffer];
            }
            else {
                [assetWriterAudioInput markAsFinished];
                
                isFinishAudio = YES;
                
                if (isFinishVideo) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                        });
                    }];
                }
                
                break;
            }
        }
    }];
}

@end
