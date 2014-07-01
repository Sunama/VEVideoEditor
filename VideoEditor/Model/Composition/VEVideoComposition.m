//
//  VideoComposition.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEVideoComposition.h"
#import "VEVideoComponent.h"
#import "VEVideoEditor.h"
#import "VEUtilities.h"
#import "VEVideoTrack.h"
#import "VETimer.h"

@implementation VEVideoComposition

@synthesize editor, components;

- (id)init {
    self = [super init];
    
    if (self) {
        components = [NSMutableArray array];
        
        spliteTime = [NSMutableArray array];
        currentSplited = -1;
    }
    
    return self;
}

- (void)addComponent:(VEVideoComponent *)component {
    component.composition = self;
    [components addObject:component];
    [self calculateDuration];
    [self spliteComponent];
}

- (void)removeComponent:(VEVideoComponent *)component {
    component.composition = nil;
    [components removeObject:component];
    [self calculateDuration];
    [self spliteComponent];
}

- (void)removeAllComponents {
    [components removeAllObjects];
    [self calculateDuration];
    [self spliteComponent];
}

- (void)removeAllComponentsExceptVideoTrack {
    int numbers = [components count];
    int excepts = 0;
    
    for (int i = 0; i < numbers; i++) {
        if ([[components objectAtIndex:excepts] isKindOfClass:[VEVideoTrack class]]) {
            excepts++;
        }
        else {
            [((VEVideoComponent *)[components objectAtIndex:excepts]).view removeFromSuperview];
            [components removeObjectAtIndex:excepts];
        }
    }
    
    [self calculateDuration];
    [self spliteComponent];
}

- (void)bringToFront:(VEVideoComponent *)component {
    if ([components indexOfObject:component] != NSNotFound) {
        [components removeObject:component];
        [components addObject:component];
    }
}

- (void)sendToBack:(VEVideoComponent *)component {
    if ([components indexOfObject:component] != NSNotFound) {
        [components removeObject:component];
        [components insertObject:component atIndex:0];
    }
}

- (void)rearrangeComponent:(VEVideoComponent *)component To:(int)index {
    if ([components indexOfObject:component] != NSNotFound) {
        [components removeObject:component];
        [components insertObject:component atIndex:index];
    }
}

- (void)calculateDuration {
    double duration = 0.0f;
    
    for (VEVideoComponent *component in components) {
        if (component.duration + component.presentTime > duration) {
            duration = component.duration + component.presentTime;
        }
    }
    
    editor.duration = duration;
}

- (NSArray *)componentsAtTime:(double)time {
    if (components.count == 0) {
        return nil;
    }
    else {
        NSInteger splited = 0;
        
        for (NSInteger i = 0; i < spliteTime.count - 1; i++) {
            double t = [[spliteTime objectAtIndex:i] doubleValue];
            if (time > t) {
                splited = t;
            }
        }
        
        if (splited != currentSplited) {
            currentSplited = splited;
            currentComponents = [NSMutableArray array];
            
            for (VEVideoComponent *component in components) {
                if (time >= component.presentTime && time <= component.presentTime + component.duration) {
                    [currentComponents addObject:component];
                }
            }
        }
        
        return currentComponents;
    }
    
    /*
    NSMutableArray *componentsAt = [NSMutableArray array];
    
    for (VEVideoComponent *component in components) {
        if (time >= component.presentTime && time <= component.presentTime + component.duration) {
            [componentsAt addObject:component];
        }
    }
    
    return componentsAt;
    */
}

- (NSArray *)componentsAtFrame:(long)frame {
    double time = frame / editor.fps;
    
    return [self componentsAtTime:time];
}

- (void)spliteComponent {
    [spliteTime removeAllObjects];
    [spliteTime addObject:[NSNumber numberWithDouble:0.0f]];
    [spliteTime addObject:[NSNumber numberWithDouble:editor.duration]];
    
    currentSplited = -1;
    
    //For Present Time
    for (VEVideoComponent *component in components) {
        for (NSInteger i = 0; i < spliteTime.count - 1; i++) {
            double time = [[spliteTime objectAtIndex:i] doubleValue];
            
            if (time == component.presentTime) {
                break;
            }
            else {
                double nextTime = [[spliteTime objectAtIndex:i + 1] doubleValue];
                
                if (component.presentTime > time && component.presentTime < nextTime) {
                    [spliteTime addObject:[NSNumber numberWithDouble:component.presentTime]];
                    break;
                }

            }
        }
    }
    
    //For Present Time + Duration
    for (VEVideoComponent *component in components) {
        for (NSInteger i = 0; i < spliteTime.count - 1; i++) {
            double time = [[spliteTime objectAtIndex:i] doubleValue];
            double componentTime = component.presentTime + component.duration;
            
            if (time == componentTime) {
                break;
            }
            else {
                double nextTime = [[spliteTime objectAtIndex:i + 1] doubleValue];
                
                if (componentTime > time && componentTime < nextTime) {
                    [spliteTime addObject:[NSNumber numberWithDouble:component.presentTime + component.duration]];
                    break;
                }
                
            }
        }
    }
    
    //Order
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [spliteTime sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
}

- (void)beginExport {
    currentSplited = -1;
    
    for (VEVideoComponent *component in components) {
        [component beginExport];
    }
}

- (CGImageRef)frameImageAtTime:(double)time {
    NSArray *nextComponents = [self componentsAtTime:time];
    
    CGImageRef image;
    CGImageRef images[[nextComponents count]];
    int i = 0;
    
    for (VEVideoComponent *component in nextComponents) {
        images[i] = [component frameImageAtTime:time];
        i++;
    }
    
    UIGraphicsBeginImageContext(editor.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    i = 0;
    
    for (VEVideoComponent *component in nextComponents) {
        CGContextDrawImage(context, component.view.frame, images[i]);
        i++;
    }
    
    image = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    for (i = 0; i < [nextComponents count]; i++) {
        CGImageRelease(images[i]);
    }
    
    return image;
}

- (CGImageRef)frameImageUpdateOnlyComponent:(VEVideoComponent *)component {
    NSArray *nextComponents = [self componentsAtTime:editor.previewTime];
    
    CGImageRef image;
    CGImageRef images[[nextComponents count]];
    
    int i = 0;
    
    for (VEVideoComponent *comp in nextComponents) {
        if ([component isEqual:comp]) {
            images[i] = [comp frameImageAtTime:editor.previewTime];
        }
        else {
            images[i] = CGImageCreateCopy(comp.previousImage);
        }
        
        i++;
    }
    
    UIGraphicsBeginImageContext(editor.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    i = 0;
    
    for (VEVideoComponent *component in nextComponents) {
        CGContextDrawImage(context, component.view.frame, images[i]);
        i++;
    }
    
    image = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    for (i = 0; i < [nextComponents count]; i++) {
        CGImageRelease(images[i]);
    }
    
    return image;
}

- (CGImageRef)nextFrameImage {
    NSArray *nextComponents = [self componentsAtFrame:editor.currentFrame];
    
    CGImageRef image;
    CGImageRef images[[nextComponents count]];
    int i = 0;
    
    for (VEVideoComponent *component in nextComponents) {
        images[i] = [component nextFrameImage];
        i++;
    }
    
    [editor.drawImageTimer startProcess];
    
    UIGraphicsBeginImageContext(editor.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    i = 0;
    
    for (VEVideoComponent *component in nextComponents) {
        CGContextDrawImage(context, component.view.frame, images[i]);
        i++;
    }
    
    image = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    for (i = 0; i < [nextComponents count]; i++) {
        CGImageRelease(images[i]);
    }
    
    [editor.drawImageTimer endProcess];
    
    return image;
}

- (BOOL)updateAtTime:(double)time {
    BOOL updated = NO;
    
    for (VEVideoComponent *component in components) {
        if ([component updateAtTime:time]) {
            updated = YES;
        }
    }
    
    return updated;
}

- (void)dispose {
    for (VEVideoComponent *component in components) {
        [component dispose];
    }
}

@end
