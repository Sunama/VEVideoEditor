//
//  MainViewController.m
//  VideoEditor
//
//  Created by Apple Macintosh on 7/11/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "MainViewController.h"
#import "EditingViewController.h"
#import "VE.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    
    videoPickerViewController = [[UIImagePickerController alloc] init];
    videoPickerViewController.delegate = self;
    videoPickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    videoPickerViewController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"NormalVideoEditorSegue"]) {
        VEVideoEditor *videoEditor = [[VEVideoEditor alloc] init];
        videoEditor.fps = 30;
        
        EditingViewController *editingViewController = segue.destinationViewController;
        editingViewController.videoEditor = videoEditor;
    }
    else if ([[segue identifier] isEqualToString:@"OverlayVideoEditorSegue"]) {
        VEOverlayVideoEditor *videoEditor = [[VEOverlayVideoEditor alloc] initWithURL:url];
        
        EditingViewController *editingViewController = segue.destinationViewController;
        editingViewController.videoEditor = videoEditor;
    }
}

- (NSInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark Action

- (IBAction)overlay:(id)sender {
    [self presentViewController:videoPickerViewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark Picker View Datasource

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        //NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        // NSLog(@"%@",moviePath);
        
        url = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        /*
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
        */
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"OverlayVideoEditorSegue" sender:self];
    }];
}

@end
