//
//  EditingViewController.m
//  VideoEditor
//
//  Created by Apple Macintosh on 7/11/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "EditingViewController.h"
#import "Utilities.h"
#import "LabelAddingViewController.h"
#import "ImageAddingViewController.h"
#import "ProcessingViewController.h"

@interface EditingViewController ()

@end

@implementation EditingViewController

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
    
    componentActionSheet = [[UIActionSheet alloc] initWithTitle:@"Video Editor" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Add Video" otherButtonTitles:@"Add Label", @"Add Image", nil];
    informationAlertView = [[UIAlertView alloc] initWithTitle:@"Video Editor" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    videoPickerViewController = [[UIImagePickerController alloc] init];
    videoPickerViewController.delegate = self;
    videoPickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    videoPickerViewController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [videoImageView addSubview:videoEditor.previewViewController.view];
    
    videoEditor.previewViewController.view.frame = CGRectMake(0.0f, 0.0f, videoImageView.frame.size.width, videoImageView.frame.size.height);
    timeSlider.value = 0.0f;
    
    [self timeSlide:timeSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ProcessingSegue"]) {
        ProcessingViewController *controller = segue.destinationViewController;
        controller.videoEditor = videoEditor;
    }
    else if ([[segue identifier] isEqualToString:@"LabelAddingSegue"]) {
        LabelAddingViewController *controller = segue.destinationViewController;
        controller.videoEditor = videoEditor;
    }
}

- (NSInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark Action

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addComponent:(id)sender {
    [componentActionSheet showFromToolbar:toolBar];
}

- (IBAction)remove:(id)sender {
    [videoEditor.videoComposition removeAllComponents];
}

- (IBAction)process:(id)sender {
    [self performSegueWithIdentifier:@"ProcessingSegue" sender:self];
}

- (IBAction)timeSlide:(id)sender {
    previewTime = timeSlider.value * videoEditor.duration;
    
    [videoEditor previewAtTime:previewTime];
    timeLabel.text = [Utilities minutesWithSeconds:previewTime];
    timeCounterLabel.text = [NSString stringWithFormat:@"- %@", [Utilities minutesWithSeconds:(videoEditor.duration - previewTime)]];
}

#pragma mark -
#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Video"]) {
        if ([videoEditor isKindOfClass:[VEOverlayVideoEditor class]]) {
            informationAlertView.message = @"Overlay Video Editor is not supported to add video";
            [informationAlertView show];
        }
        else {
            [self presentViewController:videoPickerViewController animated:YES completion:nil];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Label"]) {
        [self performSegueWithIdentifier:@"LabelAddingSegue" sender:self];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Image"]) {
        [self performSegueWithIdentifier:@"ImageAddingSegue" sender:self];
    }
}

#pragma mark -
#pragma mark Picker View Datasource

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *url = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        VEVideoTrack *videoTrack = [[VEVideoTrack alloc] initWithURL:url];
        videoTrack.presentTime = videoEditor.duration;
        
        [videoEditor.videoComposition addComponent:videoTrack];
        
        float width = videoEditor.size.width;
        float height = videoEditor.size.height;
        BOOL needChange = NO;
        
        if (videoTrack.size.width > width) {
            width = videoTrack.size.width;
            needChange = YES;
        }
        
        if (videoTrack.size.height > height) {
            height = videoTrack.size.height;
            needChange = YES;
        }
        
        if (needChange) {
            videoEditor.size = CGSizeMake(width, height);
        }
        
        timeSlider.value = previewTime / videoEditor.duration;
        [self timeSlide:timeSlider];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
