//
//  PlayViewController.m
//  videoCapture
//
//  Created by 田立彬 on 13-2-25.
//  Copyright (c) 2013年 田立彬. All rights reserved.
//

#import "PlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayViewController ()

@property (nonatomic, retain) MPMoviePlayerController* player;

@end

@implementation PlayViewController

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
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:self.fileURL];
    
//    self.player.scalingMode = MPMovieScalingModeAspectFit;
    self.player.controlStyle = MPMovieControlStyleDefault;
    [self.player prepareToPlay];
    [self.player.view setFrame:self.view.bounds];
    [self.view addSubview:self.player.view];
    self.player.shouldAutoplay = YES;
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [ notificationCenter addObserver:self selector:@selector(done:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player ];
    [ notificationCenter addObserver:self selector:@selector(done2:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:self.player];
    
//    [self.player play];
}

- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)done2:(id)sender
{
    NSLog(@"aa");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
