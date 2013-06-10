//
//  PlaySoundViewController.m
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/8/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "PlaySoundViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface PlaySoundViewController ()
{
    NSTimer *timerToUpdateProgressBar;
    CGFloat timerInterval;
}

-(void)updateSoundProgressBar;
-(void)setUpGestureRecognizer;
-(void)seek;

@end

@implementation PlaySoundViewController

@synthesize musicPlayer, streamUrl, durationInMilliseconds, artworkImageView, artworkImage, waveformUrl, waveformProgressBar, waveformView, waveformShapeView;

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
    
 /*   if (musicPlayer != nil) {
        [musicPlayer replaceCurrentItemWithPlayerItem:[AVPlayer playerWithURL:streamUrl]];
    }
    else
    {
        musicPlayer = [AVPlayer playerWithURL:streamUrl];

    }*/
    
    [self setUpGestureRecognizer];
    
    artworkImageView.image = artworkImage;
    NSLog(@"Duration: %i", durationInMilliseconds);
    timerInterval = .2;
    
    NSData *waveFormImageData = [NSData dataWithContentsOfURL:waveformUrl];
    waveformShapeView.image = [UIImage imageWithData:waveFormImageData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(seek)];
    UITapGestureRecognizer *seekGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seek)];
    seekGesture.delegate = self;
   // seekGesture.maximumNumberOfTouches = 1;
   // seekGesture.minimumNumberOfTouches = 1;
    [waveformView addGestureRecognizer:seekGesture];
    [waveformView addGestureRecognizer:panGesture];

    
}

- (IBAction)playSound:(id)sender {
    timerToUpdateProgressBar = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(updateSoundProgressBar) userInfo:nil repeats:YES];
    [musicPlayer play];
}

- (IBAction)pauseSound:(id)sender {
    [musicPlayer pause];
    [timerToUpdateProgressBar invalidate];
}

- (void)seek {
    
    CGPoint seekPosition = [waveformView.gestureRecognizers[0] locationInView:waveformView];
    
    UIPanGestureRecognizer *panGesture = waveformView.gestureRecognizers[1];
    
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded) {
        seekPosition = [panGesture locationInView:waveformView];
    }
    
    [musicPlayer seekToTime:CMTimeMake(durationInMilliseconds*seekPosition.x/waveformView.frame.size.width, 1000)];

    NSLog(@"Seek Position x: %f", seekPosition.x);
    
    if (seekPosition.x >= 0 && seekPosition.x <= waveformView.frame.size.width) {
            waveformProgressBar.frame = CGRectMake(waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, seekPosition.x, waveformProgressBar.frame.size.height);
    }

    NSLog(@"progress width: %f", waveformProgressBar.frame.size.width);
}

- (IBAction)backToSearchResults:(id)sender {
    
    [timerToUpdateProgressBar invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSoundProgressBar
{
    CGFloat progressWidth = waveformProgressBar.frame.size.width + 1000.00*timerInterval*waveformView.frame.size.width/durationInMilliseconds;
    
    if(progressWidth < 0 )
    {
        progressWidth = 0;
    }
    if (progressWidth > waveformView.frame.size.width) {
        progressWidth = waveformView.frame.size.width;
        [timerToUpdateProgressBar invalidate];
    }
    
    [UIView animateWithDuration:timerInterval animations:^{
        waveformProgressBar.frame = CGRectMake(waveformView.frame.origin.x, waveformView.frame.origin.y, progressWidth, waveformView.frame.size.height);
    }];
}
@end
