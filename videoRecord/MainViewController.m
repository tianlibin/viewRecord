//
//  MainViewController.m
//  videoRecord
//
//  Created by 田立彬 on 13-3-4.
//  Copyright (c) 2013年 田立彬. All rights reserved.
//

#import "MainViewController.h"
#import "VideoViewController.h"


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
    
    CGRect r = CGRectMake(10.0f, 100.0f, 300.0f, 30.0f);
    UIButton* button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"录制:AVCaptureSession" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(recordCapture:) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = r;
    [self.view addSubview:button1];
    
    r.origin.y += 50;
    UIButton* button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setTitle:@"录制:UIImagePickerController" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(recordPicker:) forControlEvents:UIControlEventTouchUpInside];
    button2.frame = r;
    [self.view addSubview:button2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)recordCapture:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"设备无摄象头"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    VideoViewController* vc = [[VideoViewController alloc] init];
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

- (void)recordPicker:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"设备无摄象头"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
    pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    [self presentModalViewController:pickerView animated:YES];
    pickerView.videoMaximumDuration = 30;
    pickerView.delegate = self;
    [pickerView release];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}


@end
