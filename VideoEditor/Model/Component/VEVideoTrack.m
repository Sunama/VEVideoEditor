//
//  VideoTrack.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEVideoTrack.h"
#import "VEUtilities.h"
#import "VEVideoEditor.h"
#import "VEVideoComposition.h"

@implementation VEVideoTrack

@synthesize orientation, rotate, size, fps, trimFromTime, trimDuration;

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        inputAsset = [[AVURLAsset alloc] initWithURL:url options:inputOptions];
        
        reader = [AVAssetReader assetReaderWithAsset:inputAsset error:nil];
        
        NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
        [outputSettings setObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]  forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
        
        AVAssetTrack *track = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        duration = CMTimeGetSeconds(inputAsset.duration);
        fps = track.nominalFrameRate;
        presentTime = 0;
        
        AVAssetTrack *videoTrack = [inputAsset tracksWithMediaType:AVMediaTypeVideo][0];
        CGAffineTransform transform = videoTrack.preferredTransform;
        
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
        
        self.rotate = UIImageOrientationUp;
        
        readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:outputSettings];
        
        [reader addOutput:readerOutput];
        
        //Player
        if (orientation == UIImageOrientationDown || orientation == UIImageOrientationUp) {
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, track.naturalSize.height, track.naturalSize.width)];
            size = CGSizeMake(track.naturalSize.height, track.naturalSize.width);
        }
        else {
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, track.naturalSize.width, track.naturalSize.height)];
            size = track.naturalSize;
        }
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    return [self initWithURL:[VEUtilities convertURLFromPath:path]];
}

- (void)setRotate:(UIImageOrientation)_rotate {
    rotate = _rotate;
    
    int intOrientation;
    int intRotate;
    
    if (orientation == UIImageOrientationUp) {
        intOrientation = 0;
    }
    else if (orientation == UIImageOrientationLeft) {
        intOrientation = 1;
    }
    else if (orientation == UIImageOrientationDown) {
        intOrientation = 2;
    }
    else if (orientation == UIImageOrientationRight) {
        intOrientation = 3;
    }
    else {
        intOrientation = 0;
    }
    
    if (rotate == UIImageOrientationUp) {
        intRotate = 0;
    }
    else if (rotate == UIImageOrientationLeft) {
        intRotate = 1;
    }
    else if (rotate == UIImageOrientationDown) {
        intRotate = 2;
    }
    else if (rotate == UIImageOrientationRight) {
        intRotate = 3;
    }
    else {
        intRotate = 0;
    }
    
    int intResult = (intOrientation + intRotate) % 4;
    
    if (intResult == 0) {
        resultOrientation = UIImageOrientationUp;
    }
    else if (intResult == 1) {
        resultOrientation = UIImageOrientationLeft;
    }
    else if (intResult == 2) {
        resultOrientation = UIImageOrientationDown;
    }
    else if (intResult == 3) {
        resultOrientation = UIImageOrientationRight;
    }
    
    if (rotate == UIImageOrientationUp || rotate == UIImageOrientationDown) {
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
    }
    else if (rotate == UIImageOrientationLeft || rotate == UIImageOrientationRight) {
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.height, size.width);
    }
}

- (void)beginExport {
    if ([reader startReading] == NO) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:@"Cannot to start reading video" forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:3 userInfo:info];
        
        [composition.editor.delegate videoEditor:composition.editor exportFinishWithError:error];
    }
    
    currentTime = 0.0f;
}

- (CGImageRef)frameImageAtTime:(double)time {
    time = time - presentTime;
    CGImageRelease(previousImage);
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:inputAsset];
    generator.appliesPreferredTrackTransform = NO;
    CMTime thumbTime = CMTimeMakeWithSeconds(time, fps);
    CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:nil error:nil];
    
    if (resultOrientation == UIImageOrientationUp) {
        image = [VEUtilities imageByRotatingImage:image fromImageOrientation:UIImageOrientationLeftMirrored];
    }
    else if (resultOrientation == UIImageOrientationDown) {
        image = [VEUtilities imageByRotatingImage:image fromImageOrientation:UIImageOrientationRightMirrored];
    }
    else if (resultOrientation == UIImageOrientationLeft) {
        image = [VEUtilities imageByRotatingImage:image fromImageOrientation:UIImageOrientationUpMirrored];
    }
    else if (resultOrientation == UIImageOrientationRight) {
        image = [VEUtilities imageByRotatingImage:image fromImageOrientation:UIImageOrientationDownMirrored];
    }
    
    previousImage = CGImageCreateCopy(image);
    
    return image;
}

- (CGImageRef)nextFrameImage {
    if (presentTime + currentTime > composition.editor.currentFrame * composition.editor.fps) {
        return CGImageCreateCopy(previousImage);
    }
    else {
        CGImageRelease(previousImage);
        
        while (reader.status != AVAssetReaderStatusReading) {
            usleep(0.1f);
        }
        
        CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
        
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sample);
        currentTime = CMTimeGetSeconds(presentationTime);
        
        /* Composite over video frame */
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sample);
        
        // Lock the image buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get information about the image
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a CGImageRef from the CVImageBufferRef
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        previousImage = CGBitmapContextCreateImage(context);
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        // We release some components
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        /* End composite */
        
        CFRelease(sample);
        
        if (resultOrientation == UIImageOrientationUp) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationLeftMirrored];
        }
        else if (resultOrientation == UIImageOrientationDown) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationRightMirrored];
        }
        else if (resultOrientation == UIImageOrientationLeft) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationUpMirrored];
        }
        else if (resultOrientation == UIImageOrientationRight) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationDownMirrored];
        }
        
        return CGImageCreateCopy(previousImage);
    }
}


- (BOOL)updateAtTime:(double)time {
    return YES;
}

- (BOOL)updateNextFrame {
    if (presentTime + currentTime <= composition.editor.currentFrame * composition.editor.fps) {
        CGImageRelease(previousImage);
        
        while (reader.status != AVAssetReaderStatusReading) {
            usleep(0.1f);
        }
        
        CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
        
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sample);
        currentTime = CMTimeGetSeconds(presentationTime);
        
        /* Composite over video frame */
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sample);
        
        // Lock the image buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get information about the image
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a CGImageRef from the CVImageBufferRef
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        previousImage = CGBitmapContextCreateImage(context);
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        // We release some components
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        /* End composite */
        
        CFRelease(sample);
        
        if (resultOrientation == UIImageOrientationUp) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationRight];
        }
        else if (resultOrientation == UIImageOrientationDown) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationLeft];
        }
        else if (resultOrientation == UIImageOrientationLeft) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationDown];
        }
        else if (resultOrientation == UIImageOrientationRight) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:UIImageOrientationUp];
        }
        
        ((UIImageView *)view).image = [UIImage imageWithCGImage:previousImage];
        
        return YES;
    }
    else {
        return NO;
    }
}

@end
