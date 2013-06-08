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
    AVPlayer *musicPlayer;
    NSTimer *timerToUpdateSlider;
}

-(void)updateSoundProgressSlider;
@end

@implementation PlaySoundViewController

@synthesize streamUrl, soundCurrentPositionOutlet, durationInMilliseconds;

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
    
    NSError *error;
    musicPlayer = [AVPlayer playerWithURL:streamUrl];
    
    if (musicPlayer==nil) {
        NSLog(@"Error: %@", error.description);
    }
    
    NSLog(@"Duration: %i", durationInMilliseconds);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playSound:(id)sender {
    timerToUpdateSlider = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSoundProgressSlider) userInfo:nil repeats:YES];
    [musicPlayer play];
}

- (IBAction)pauseSound:(id)sender {
    [musicPlayer pause];
    [timerToUpdateSlider invalidate];
}

- (IBAction)seek:(id)sender {
    CGFloat chosenPosition = soundCurrentPositionOutlet.value;
    NSLog(@"Chosen Position: %f", soundCurrentPositionOutlet.value);
    [musicPlayer seekToTime:CMTimeMake(durationInMilliseconds*chosenPosition, 1000)];
}

-(void)updateSoundProgressSlider
{
    NSLog(@"current position: %f", soundCurrentPositionOutlet.value);
    [soundCurrentPositionOutlet setValue:(soundCurrentPositionOutlet.value + 1000.00/(durationInMilliseconds)) animated:YES];
}
@end
