//
//  ProcessingViewController.m
//  VideoEditor
//
//  Created by Apple Macintosh on 7/11/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "ProcessingViewController.h"
#import "Utilities.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

@interface ProcessingViewController ()

@end

@implementation ProcessingViewController

@synthesize videoEditor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    informationAlertView = [[UIAlertView alloc] initWithTitle:@"VideoEditor" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    videoEditor.delegate = self;
    startDate = [NSDate date];
    [videoEditor exportToURL:[Utilities urlDocumentsPath:[NSString stringWithFormat:@"%.0f.mov", [NSDate timeIntervalSinceReferenceDate]]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark VEVideoDelegate Delegate

- (void)videoEditor:(VEVideoEditor *)videoEditor exportFinishWithError:(NSError *)error {
    if (error) {
        informationAlertView.message = [NSString stringWithFormat:@"Error to export video with reason: %@", error];
    }
    else {
        informationAlertView.message = [NSString stringWithFormat:@"Export finished with time: %@\nVideo Size: %.0f x %.0f\nUsed Memory: %.4f mb\nFree Memory: %.4f mb", [Utilities minutesWithSeconds:[[NSDate date] timeIntervalSinceDate:startDate]], videoEditor.size.width, videoEditor.size.height, [self usedMemory] / (1024.0f * 1024.0f), [self get_free_memory] / (1024.0f * 1024.0f)];
    }
    
    [informationAlertView show];
}

- (void)videoEditor:(VEVideoEditor *)videoEditor progressTo:(double)progress {
    progressCount++;
    
    if (progressCount > 10) {
        progressLabel.text = [NSString stringWithFormat:@"%.2f%%", progress * 100.0f];
        progressView.progress = progress;
        
        progressCount = 0;
    }
}

#pragma mark -
#pragma mark Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
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
