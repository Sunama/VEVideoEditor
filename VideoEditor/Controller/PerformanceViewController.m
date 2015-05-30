//
//  PerformanceViewController.m
//  VideoEditor
//
//  Created by Sukit Sunama on 12/19/2557 BE.
//  Copyright (c) 2557 Afternoon Tea Break. All rights reserved.
//

#import "PerformanceViewController.h"
#import "Utilities.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

@interface PerformanceViewController ()

@end

@implementation PerformanceViewController

//@synthesize videoEditor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    samplePaths = [NSMutableArray array];
    samplePath = [Utilities bundlePath:@"IMG_0275.MOV"];
    
    experiments = 1;
    method = 1;
    sample = 30;
    
    [self loadExperiment];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark Experiment

- (void)loadExperiment {
    [videoEditor dispose];
    videoEditor = nil;
    if (experiments == 0) {
        //NSString *path = [Utilities bundlePath:[samplePaths objectAtIndex:sample]];
        NSString *path = samplePath;
        if (method == 0) {
            videoEditor = [[VEVideoEditor alloc] initWithPath:path];
            ((VEVideoTrack *)[videoEditor.videoComposition.components objectAtIndex:0]).duration = sample;
        }
        else
            videoEditor = [[VEOverlayVideoEditor alloc] initWithPath:path];
        
        //sample++;
        videoEditor.duration = sample;
        
        for (int i = 0; i < 5; i++) {
            [self randText];
        }
        
        if (sample == 30) {
            experiments = 1;
            sample = 0;
        }
    }
    else if (experiments == 1) {
        if (method == 0) {
            videoEditor = [[VEVideoEditor alloc] initWithPath:samplePath];
            ((VEVideoTrack *)[videoEditor.videoComposition.components objectAtIndex:0]).duration = 10.0f;
        }
        else
            videoEditor = [[VEOverlayVideoEditor alloc] initWithPath:samplePath];

        videoEditor.duration = 10.0f;
        
        for (int i = 0; i < sample; i++) {
            [self randText];
        }
    }
    
    sumUsedMemory = 0;
    samplingTime = 0;
    
    videoEditor.delegate = self;
    startDate = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%.0f.mov", [NSDate timeIntervalSinceReferenceDate]];
    [videoEditor exportToURL:[Utilities urlDocumentsPath:fileName]];
}

- (void)randText {
    int x = [Utilities generateRandomNumberWithlowerBound:0 upperBound:videoEditor.size.width];
    int y = [Utilities generateRandomNumberWithlowerBound:0 upperBound:videoEditor.size.height];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 0.0f, 0.0f)];
    label.font = [UIFont fontWithName:label.font.fontName size:videoEditor.size.height * 0.2f];
    label.text = @"Hello";
    label.backgroundColor = [UIColor clearColor];
    
    CGSize labelSize = [label.text sizeWithFont:label.font];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    
    VEVideoComponent *component = [[VEVideoComponent alloc] initWithView:label];
    
    double time1 = 0.0f;
    double time2 = videoEditor.duration;
    
    component.presentTime = time1;
    component.duration = time2 - time1;
    
    [videoEditor.videoComposition addComponent:component];
}

#pragma mark -
#pragma mark VEVideoDelegate Delegate

- (void)videoEditor:(VEVideoEditor *)videoEditor exportFinishWithError:(NSError *)error {
    NSString *message;
    
    if (error) {
        message = [NSString stringWithFormat:@"Error to export video with reason: %@", error];
    }
    else {
        float time = [startDate timeIntervalSinceNow] * -1000.0;
        
        message = [NSString stringWithFormat:@"Experiments #%d, sample %d, Export finished with time: %.0f ms\nVideo Size: %.0f x %.0f\nUsed Memory: %.4f mb\nFree Memory: %.4f mb", experiments, sample, time, videoEditor.size.width, videoEditor.size.height, sumUsedMemory / samplingTime, [self get_free_memory] / (1024.0f * 1024.0f)];
        NSLog(@"\n%.0f\n\n%.4f", time, sumUsedMemory / samplingTime);
    }
    
    processTextView.text = [NSString stringWithFormat:@"%@ \n%@", processTextView.text, message];
    
    //[self loadExperiment];
}

- (void)videoEditor:(VEVideoEditor *)videoEditor progressTo:(double)progress {
    //[memories addObject:[NSNumber numberWithFloat:[self usedMemory] / (1024.0f * 1024.0f)]];
    sumUsedMemory += [self usedMemory] / (1024.0f * 1024.0f);
    samplingTime++;
    NSLog(@"%.2f%%", progress * 100);
}

- (natural_t)get_free_memory {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }
    
    /* Stats in bytes */
    natural_t mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

- (void)report_memory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %u (%u mb)", info.resident_size, info.resident_size / (1024 *1024)) ;
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

- (vm_size_t)usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return info.resident_size;
    }
    else {
        return 0;
    }
}


@end
