//
//  VideoViewController.m
//  videoRecord
//
//  Created by 田立彬 on 13-2-22.
//  Copyright (c) 2013年 田立彬. All rights reserved.
//

#import "VideoViewController.h"
#import "PlayViewController.h"


@interface VideoViewController ()

@property (nonatomic, assign) NSInteger currentFrame;
@property (nonatomic, assign) NSInteger maxFrame;

@end

@implementation VideoViewController

- (void)dealloc
{
    self.captureSession = nil;
    self.assetWriter = nil;
    self.assetWriterInput = nil;
    self.videoOutput = nil;
    self.outputMovURL = nil;
    self.outputMp4URL = nil;
    self.previewView = nil;
    
    [super dealloc];
}

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
	// Do any additional setup after loading the view, typically from a nib.

    self.started = NO;
    self.currentFrame = 0;
    self.maxFrame = 240; // 设置每秒24帖，最长10秒
    self.outputMovURL = [NSURL fileURLWithPath:[[self docDir] stringByAppendingPathComponent:@"v.mov"]];
    self.outputMp4URL = [NSURL fileURLWithPath:[[self docDir] stringByAppendingPathComponent:@"v.mp4"]];

    [self setupAVCapture];
    [self setupPreview];
    [self setupButtons];
}

- (void)setupPreview
{
    self.previewView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 320.0f, 427.0f)] autorelease];
    [self.view addSubview:self.previewView];
	// Make a preview layer so we can see the visual output of an AVCaptureSession
	AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[previewLayer setFrame:[self.previewView bounds]];
	
    // add the preview layer to the hierarchy
    CALayer *rootLayer = [self.previewView layer];
	[rootLayer setBackgroundColor:[[UIColor greenColor] CGColor]];
	[rootLayer addSublayer:previewLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - private method
- (NSString*)docDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = nil;
    if ([paths count] > 0) {
        docDir = [paths objectAtIndex:0];
    }
    return docDir;
}

- (void)showAlert:(NSString*)text
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)deleteFile:(NSURL*)filePath
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 是否存在
    BOOL isExistsOk = [fm fileExistsAtPath:[filePath path]];
    
    if (isExistsOk) {
        [fm removeItemAtURL:filePath error:nil];
        NSLog(@"file deleted:%@",filePath);
    }
    else {
        NSLog(@"file not exists:%@",filePath);
    }
    
    [fm release];
}

- (void)setupButtons
{
    CGFloat w = 60.0f;
    CGFloat h = 40.0f;
    CGFloat y = self.view.frame.size.height - h;
    CGRect f = CGRectMake(0.0f, y, w, h);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = f;
    [button setTitle:@"start" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    f.origin.x += (w + 5);
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = f;
    [button setTitle:@"stop" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    f.origin.x += (w + 5);
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = f;
    [button setTitle:@"playmov" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playmov:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    f.origin.x += (w + 5);
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = f;
    [button setTitle:@"playmp4" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playmp4:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)start:(id)sender
{
    UIButton* button = (UIButton*)sender;
    if (self.started) {
        // 暂停
        [button setTitle:@"start" forState:UIControlStateNormal];
        self.started = NO;
    }
    else {
        // 开始
        if (self.currentFrame == 0) {
            // 试图删一下原誩件
            [self deleteFile:self.outputMovURL];
        }
        [button setTitle:@"pause" forState:UIControlStateNormal];
        self.started = YES;
    }
}

- (void)stop:(id)sender
{
    self.started = NO;
    if (self.assetWriter != nil) {
        [self.assetWriterInput markAsFinished];
        [self.assetWriter finishWritingWithCompletionHandler:^{
            ;
        }];
        self.assetWriterInput = nil;
        self.assetWriter = nil;
    }
    self.currentFrame = 0;
}


- (void)playmov:(id)sender
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 是否存在
    BOOL isExistsOk = [fm fileExistsAtPath:[self.outputMovURL path]];
    
    if (isExistsOk) {
        PlayViewController* vc = [[PlayViewController alloc] init];
        vc.fileURL = self.outputMovURL;
        [self presentViewController:vc animated:YES completion:^{
            ;
        }];
        [vc release];
    }
    else {
        [self showAlert:@"文件不存在"];
    }
    
    [fm release];
}

- (void)playmp4:(id)sender
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 是否存在
    BOOL isExistsOk = [fm fileExistsAtPath:[self.outputMp4URL path]];
    
    if (isExistsOk) {
        PlayViewController* vc = [[PlayViewController alloc] init];
        vc.fileURL = self.outputMp4URL;
        [self presentViewController:vc animated:YES completion:^{
            ;
        }];
        [vc release];
    }
    else {
        [self showAlert:@"文件不存在"];
    }
    
    [fm release];
}

- (void)convertToMp4
{
    NSString* _mp4Quality = AVAssetExportPresetLowQuality;
    
    // 试图删除原mp4
    [self deleteFile:self.outputMp4URL];
    
    // 生成mp4
    CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:self.outputMovURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:_mp4Quality]) {
        __block AVAssetExportSession *exportSession = [[[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                               presetName:_mp4Quality] autorelease];
        
        exportSession.outputURL = self.outputMp4URL;
        //        exportSession.shouldOptimizeForNetworkUse = _networkOpt;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed:%@",[exportSession error]);
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"Successful!");
                    [self performSelectorOnMainThread:@selector(convertFinish) withObject:nil waitUntilDone:NO];
                    CFAbsoluteTime e = CFAbsoluteTimeGetCurrent();
                    
                    NSLog(@"MP4:%f",e-s);
                    
                }
                    break;
                default:
                    break;
            }
        }];
        [exportSession release];
    }
    else
    {
        [self showAlert:@"AVAsset doesn't support mp4 quality"];
    }
}

#pragma mark - capture method
- (BOOL)setupAVCapture
{
	NSError *error = nil;
    // 24 fps - taking 25 pictures will equal 1 second of video
	self.frameDuration = CMTimeMakeWithSeconds(1./24., 90000);
	
	self.captureSession = [[[AVCaptureSession alloc] init] autorelease];
	[self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
	
	// Select a video device, make an input
	AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
	if (error)
		return NO;
	if ([self.captureSession canAddInput:input])
		[self.captureSession addInput:input];
	
    self.videoOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [self.videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [self.videoOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
	
    self.videoOutput.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // start the capture session running, note this is an async operation
    // status is provided via notifications such as AVCaptureSessionDidStartRunningNotification/AVCaptureSessionDidStopRunningNotification
    [self.captureSession startRunning];
	
	return YES;
}

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (BOOL)setupAssetWriterForURL:(NSURL *)fileURL formatDescription:(CMFormatDescriptionRef)formatDescription
{
    // allocate the writer object with our output file URL
	NSError *error = nil;
	self.assetWriter = [[[AVAssetWriter alloc] initWithURL:fileURL fileType:AVFileTypeQuickTimeMovie error:&error] autorelease];
	if (error)
		return NO;
	
    // initialized a new input for video to receive sample buffers for writing
    // passing nil for outputSettings instructs the input to pass through appended samples, doing no processing before they are written
    // 下面这个参数，设置图像质量，数字越大，质量越好
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithDouble:512*1024.0], AVVideoAverageBitRateKey,
                                           nil ];
    // 设置编码和宽高比。宽高比最好和摄像比例一致，否则图片可能被压缩或拉伸
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                         [NSNumber numberWithFloat:320.0f], AVVideoWidthKey,
                         [NSNumber numberWithFloat:240.0f], AVVideoHeightKey,
                         videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
	self.assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:dic];
	[self.assetWriterInput setExpectsMediaDataInRealTime:YES];
	if ([self.assetWriter canAddInput:self.assetWriterInput])
		[self.assetWriter addInput:self.assetWriterInput];
	
    // specify the prefered transform for the output file
	CGFloat rotationDegrees;
	switch ([[UIDevice currentDevice] orientation]) {
		case UIDeviceOrientationPortraitUpsideDown:
			rotationDegrees = -90.;
			break;
		case UIDeviceOrientationLandscapeLeft: // no rotation
			rotationDegrees = 0.;
			break;
		case UIDeviceOrientationLandscapeRight:
			rotationDegrees = 180.;
			break;
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationUnknown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		default:
			rotationDegrees = 90.;
			break;
	}
	CGFloat rotationRadians = DegreesToRadians(rotationDegrees);
	[self.assetWriterInput setTransform:CGAffineTransformMakeRotation(rotationRadians)];
	
    // initiates a sample-writing at time 0
	self.nextPTS = kCMTimeZero;
	[self.assetWriter startWriting];
	[self.assetWriter startSessionAtSourceTime:self.nextPTS];
	
    return YES;
}


// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.started) {
        // set up the AVAssetWriter using the format description from the first sample buffer captured
        if ( self.assetWriter == nil ) {
            //NSLog(@"Writing movie to \"%@\"", outputURL);
            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
            if ( NO == [self setupAssetWriterForURL:self.outputMovURL formatDescription:formatDescription] ) {
                NSLog(@"setupAssetWriterForURL error");
                return;
            }
        }
        // re-time the sample buffer - in this sample frameDuration is set to 5 fps
        CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
        timingInfo.duration = self.frameDuration;
        timingInfo.presentationTimeStamp = self.nextPTS;
        CMSampleBufferRef sbufWithNewTiming = NULL;
        
        
        OSStatus err = CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault,
                                                             sampleBuffer,
                                                             1, // numSampleTimingEntries
                                                             &timingInfo,
                                                             &sbufWithNewTiming);
        if (err) {
            NSLog(@"CMSampleBufferCreateCopyWithNewTiming error");
            return;
        }
        
        // append the sample buffer if we can and increment presnetation time
        if ( [self.assetWriterInput isReadyForMoreMediaData] ) {
            if ([self.assetWriterInput appendSampleBuffer:sbufWithNewTiming]) {
                self.nextPTS = CMTimeAdd(self.frameDuration, self.nextPTS);
            }
            else {
                NSError *error = [self.assetWriter error];
                NSLog(@"failed to append sbuf: %@", error);
            }
        }
        else {
            NSLog(@"isReadyForMoreMediaData error");
        }
        
        // release the copy of the sample buffer we made
        CFRelease(sbufWithNewTiming);
        
        self.currentFrame++;
        if (self.currentFrame >= self.maxFrame) {
            [self performSelectorOnMainThread:@selector(stopedForce) withObject:nil waitUntilDone:YES];
        }
    }
}

- (void)stopedForce
{
    [self stop:nil];
    [self showAlert:@"stoped force"];    
}
@end
