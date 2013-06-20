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
#import "ViewController.h"
#import "Constants.h"
#import "Track.h"
#import "Reachability.h"

@interface PlaySoundViewController ()
{
    NSOperationQueue *getArtworkOperationQueue;
    NSOperationQueue *getWaveformOperationQueue;
    
    NSTimer *timerToUpdateProgressBar;
    CGFloat timerInterval;

    NSTimer *buttonMashTimer;
    NSInteger buttonMashCount;
    NSInteger buttonMashMax;

    Track *previousTrack;
    Track *nextTrack;
    
    UIImage *playButtonImage;
    UIImage *pauseButtonImage;
        
    NSString *resize;
    NSInteger soundSeconds;
    NSInteger soundRemainingSeconds;
    
    BOOL internetConnection;
}

-(void)updateSoundProgressBar;
-(void)setUpGestureRecognizer;
-(void)seek;
-(void)loadTrack:(Track*)track forIndex:(NSInteger)index;

@end

@implementation PlaySoundViewController

@synthesize musicPlayer, currentIndex, playlistArray, artworkImageView, waveformProgressBar, waveformView, waveformShapeView, newSoundSelected, currentTrack, playPauseButton, usernameLabel, backButtonOutlet, rewindButtonOutlet, fastForwardButtonOutlet, soundTimeLabel, soundTimeRemainingLabel, titleLabel, lostInternetConnectionLabel;

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
    
    //
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    //
	// Do any additional setup after loading the view.
    getArtworkOperationQueue = [[NSOperationQueue alloc] init];
    getWaveformOperationQueue = [[NSOperationQueue alloc] init];

    self.delegate = (ViewController*)self.presentingViewController;
    
    timerInterval = .1;
    resize = @"-crop";
    
    buttonMashCount = 0;
    buttonMashMax = 2;
    
    [self setUpGestureRecognizer];
    
    playButtonImage = [UIImage imageNamed:@"playButton.png"];
    pauseButtonImage = [UIImage imageNamed:@"pauseButton.png"];
    [backButtonOutlet setBackgroundImage:[UIImage imageNamed:@"btn_nav_back_pressed"] forState:UIControlStateHighlighted];
    [rewindButtonOutlet setBackgroundImage:[UIImage imageNamed:@"rewindSelected"] forState:UIControlStateHighlighted];
    [fastForwardButtonOutlet setBackgroundImage:[UIImage imageNamed:@"fastForwardSelected"] forState:UIControlStateHighlighted];

    [playPauseButton setBackgroundImage:playButtonImage forState:UIControlStateNormal];
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.soundcloud.com"];
    //[Reachability reachabilityForInternetConnection]
    
    // set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"REACHABLE!");
        
        NSBlockOperation *updateInternetConnectionOperation = [NSBlockOperation blockOperationWithBlock:^{
            internetConnection = YES;
            playPauseButton.userInteractionEnabled = YES;
            fastForwardButtonOutlet.userInteractionEnabled = YES;
            rewindButtonOutlet.userInteractionEnabled = YES;
            lostInternetConnectionLabel.hidden = YES;
        }];
        
        [[NSOperationQueue mainQueue] addOperation:updateInternetConnectionOperation];
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
        
        NSBlockOperation *updateInternetConnectionOperation = [NSBlockOperation blockOperationWithBlock:^{
            internetConnection = NO;
            [musicPlayer pause];
            playPauseButton.userInteractionEnabled = NO;
            fastForwardButtonOutlet.userInteractionEnabled = NO;
            rewindButtonOutlet.userInteractionEnabled = NO;
            lostInternetConnectionLabel.hidden = NO;
        }];
        
        [[NSOperationQueue mainQueue] addOperation:updateInternetConnectionOperation];
    };
    
    // start the notifier which will cause the reachability object to retain itself!
    [reach startNotifier];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if (newSoundSelected) {
        currentTrack = [[Track alloc] init];
        previousTrack = [[Track alloc] init];
        nextTrack = [[Track alloc] init];
        
        [self loadTrack:currentTrack forIndex:currentIndex];
        
        if (currentIndex > 0) {
            [self loadTrack:previousTrack forIndex:currentIndex-1];
        }
        else
        {
            [self loadTrack:previousTrack forIndex:playlistArray.count-1];
        }
        if (currentIndex < playlistArray.count -1) {
            [self loadTrack:nextTrack forIndex:currentIndex+1];
        }
        else{
            [self loadTrack:nextTrack forIndex:0];
        }
        
        [self displayCurrentTrack];
    }
}



-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent*)receivedEvent{
    
    NSLog(@"remoteControlReceivedWithEvent");
    
    if (receivedEvent.type == UIEventTypeRemoteControl){
        switch (receivedEvent.subtype){
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (musicPlayer.rate) {
                    [musicPlayer pause];
                }
                else {
                    [musicPlayer play];
                }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self skipToPreviousSong:self];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self skipToNextSong:self];
                break;
            default:
                break;
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [timerToUpdateProgressBar invalidate];

    NSLog(@"MusicPlayer Rate: %f", musicPlayer.rate);
    if ([keyPath isEqualToString:@"rate"]) {
        if (musicPlayer.rate) {
             timerToUpdateProgressBar = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(updateSoundProgressBar) userInfo:nil repeats:YES];
            
            [playPauseButton setBackgroundImage:pauseButtonImage forState:UIControlStateNormal];
            [playPauseButton setBackgroundImage:[UIImage imageNamed:@"pauseButtonSelected"] forState:UIControlStateHighlighted];


            NSLog(@"Playing");
        }
        else {
            [playPauseButton setBackgroundImage:playButtonImage forState:UIControlStateNormal];
            [playPauseButton setBackgroundImage:[UIImage imageNamed:@"playButtonSelected"] forState:UIControlStateHighlighted];
            
            if (ceil(waveformProgressBar.frame.size.width) >= waveformView.frame.size.width) {
                [self skipToNextSong:self];
            }
            
            NSLog(@"Paused");
        }
    }
}

-(void)displayCurrentTrack
{

    waveformProgressBar.frame = CGRectMake(waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, 0, waveformProgressBar.frame.size.height);
    [musicPlayer pause];

    titleLabel.text = currentTrack.trackTitle;
    usernameLabel.text = currentTrack.username;

    if (currentTrack.artWork == nil) {
        artworkImageView.image = [UIImage imageNamed:@"cloud.png"];
        
        if (buttonMashCount <= buttonMashMax) {
            [currentTrack fetchArtworkForImageView:artworkImageView onOperationQueue:getArtworkOperationQueue withCurrentIndex:currentIndex];
        }
    }
    else
    {
        artworkImageView.image = currentTrack.artWork;
    }
    
    if (currentTrack.waveformImage == nil) {
        waveformShapeView.image = [UIImage imageNamed:@"sampleWaveForm.png"];
        
        if (buttonMashCount <= buttonMashMax) {
            [currentTrack fetchWaveformImageForImageView:waveformShapeView onOperationQueue:getWaveformOperationQueue withCurrentIndex:currentIndex];
        }
    }
    else
    {
        waveformShapeView.image = currentTrack.waveformImage;
    }
    
    [musicPlayer removeObserver:self forKeyPath:@"rate"];
    musicPlayer = [AVPlayer playerWithURL:currentTrack.streamUrl];
    [musicPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    
    [musicPlayer play];
}

-(void)loadTrack:(Track*)track forIndex:(NSInteger)index
{    
    track.index = index;
    track.trackTitle = playlistArray[index][@"title"];
    track.username = playlistArray[index][@"user"][@"username"];

    NSString *streamUrlString = [NSString stringWithFormat:@"%@?client_id=%@", playlistArray[index][@"stream_url"], sClientId];
    track.streamUrl = [NSURL URLWithString:streamUrlString];
    
    track.durationInMilliseconds = [playlistArray[index][@"duration"] integerValue];
    track.waveformUrl = [NSURL URLWithString:playlistArray[index][@"waveform_url"]];
    
    NSString *artworkUrlResized = @"NOT Resized";
    
    if (playlistArray[index][@"artwork_url"] != [NSNull null]) {
        artworkUrlResized = [playlistArray[index][@"artwork_url"] stringByReplacingOccurrencesOfString:@"-large" withString:resize];
        track.artworkUrl = [NSURL URLWithString:artworkUrlResized];
    }
    else if ([playlistArray[index][@"user"][@"avatar_url"] rangeOfString:@"sndcdn.com/images/default_avatar_large.png"].location == NSNotFound)
    {
        artworkUrlResized = [playlistArray[index][@"user"][@"avatar_url"] stringByReplacingOccurrencesOfString:@"-large" withString:resize];
        track.artworkUrl = [NSURL URLWithString:artworkUrlResized];
    }
    
    buttonMashCount++;
    [buttonMashTimer invalidate];
    buttonMashTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resetButtonMashCount) userInfo:nil repeats:NO];
    
    if (buttonMashCount <= buttonMashMax) {
        [track fetchArtworkForImageView:nil onOperationQueue:getArtworkOperationQueue withCurrentIndex:currentIndex];
        [track fetchWaveformImageForImageView:nil onOperationQueue:getWaveformOperationQueue withCurrentIndex:currentIndex];
    }
    else
    {
        [getArtworkOperationQueue cancelAllOperations];
        [getWaveformOperationQueue cancelAllOperations];
    }
}

-(void)resetButtonMashCount
{
    if (buttonMashCount > buttonMashMax) {
        buttonMashCount = 0;
        [self displayCurrentTrack];
    }
    
    buttonMashCount = 0;
}

-(void)setUpGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(seek)];
    UITapGestureRecognizer *seekGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seek)];
    seekGesture.delegate = self;
    
    [waveformView addGestureRecognizer:seekGesture];
    [waveformView addGestureRecognizer:panGesture];
}



- (IBAction)playPauseSound:(id)sender
{    
    if ([[playPauseButton backgroundImageForState:UIControlStateNormal] isEqual:playButtonImage]) {
        [musicPlayer play];
    }
    else if ([[playPauseButton backgroundImageForState:UIControlStateNormal] isEqual:pauseButtonImage]) {
        [musicPlayer pause];
    }
}

- (IBAction)skipToPreviousSong:(id)sender
{    
    if (CMTimeGetSeconds(musicPlayer.currentTime) < 2) { //go to previous song
        currentIndex--;
        nextTrack = [Track createTrackFromTrack:currentTrack];
        currentTrack = [Track createTrackFromTrack:previousTrack];
        
        previousTrack = [[Track alloc] init];

        if (currentIndex <= 0) {
            [self loadTrack:previousTrack forIndex:playlistArray.count-1];
        }
        else
        {
            [self loadTrack:previousTrack forIndex:currentIndex-1];
        }
        
        if (currentIndex < 0) {
            currentIndex = playlistArray.count - 1;
        }
        
        [self displayCurrentTrack];

    }
    else //restart song from beginning
    {
        [musicPlayer seekToTime:CMTimeMake(0, 1000)];
        waveformProgressBar.frame = CGRectMake(waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, 0, waveformProgressBar.frame.size.height);
    }
    
}

- (IBAction)skipToNextSong:(id)sender {
  
    currentIndex++;
    previousTrack = [Track createTrackFromTrack:currentTrack];
    currentTrack = [Track createTrackFromTrack:nextTrack];
    
    nextTrack = [[Track alloc] init];
    
    if (currentIndex >= playlistArray.count - 1) {
        [self loadTrack:nextTrack forIndex:0];
    }
    else
    {
        [self loadTrack:nextTrack forIndex:currentIndex+1];
    }
    
    if (currentIndex > playlistArray.count - 1) {
        currentIndex = 0;
    }
    
    [self displayCurrentTrack];

}

- (void)seek {
    [musicPlayer pause];
    
    CGPoint seekPosition = [waveformView.gestureRecognizers[0] locationInView:waveformView];
    
    UIPanGestureRecognizer *panGesture = waveformView.gestureRecognizers[1];
    
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded) {
        seekPosition = [panGesture locationInView:waveformView];
    }
    
    NSLog(@"Seek Position x: %f", seekPosition.x);
    
    if (seekPosition.x < 0) {
        seekPosition.x = 0;
        [musicPlayer pause];
    }
    if (seekPosition.x > waveformView.frame.size.width) {
        seekPosition.x = waveformView.frame.size.width;
        [musicPlayer pause];
    }
    
    [musicPlayer seekToTime:CMTimeMake(currentTrack.durationInMilliseconds*seekPosition.x/waveformView.frame.size.width, 1000)];

    waveformProgressBar.frame = CGRectMake(waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, seekPosition.x, waveformProgressBar.frame.size.height);
    

    NSLog(@"progress width: %f", waveformProgressBar.frame.size.width);
    
    [musicPlayer play];
}

- (IBAction)backToSearchResults:(id)sender {
    
    [self.delegate retainPlaySoundViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSoundProgressBar
{
    soundSeconds = CMTimeGetSeconds(musicPlayer.currentTime);
    soundRemainingSeconds = floor(currentTrack.durationInMilliseconds/1000.00 - soundSeconds);
    
    if (currentTrack.durationInMilliseconds <= 10*60*1000) {
        soundTimeLabel.text = [NSString stringWithFormat:@"%01d:%02d", soundSeconds/60,soundSeconds%60];
        soundTimeRemainingLabel.text = [NSString stringWithFormat:@"-%01d:%02d", soundRemainingSeconds/60,soundRemainingSeconds%60];

    }
    else if (currentTrack.durationInMilliseconds <= 10*60*1000*6){
        soundTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", soundSeconds/60,soundSeconds%60];
        soundTimeRemainingLabel.text = [NSString stringWithFormat:@"-%02d:%02d", soundRemainingSeconds/60,soundRemainingSeconds%60];
    }
    else {
        soundTimeLabel.text = [NSString stringWithFormat:@"%01d:%02d:%02d", soundSeconds/(60*60), soundSeconds/60,soundSeconds%60];
        soundTimeRemainingLabel.text = [NSString stringWithFormat:@"-%01d:%02d:%02d", soundRemainingSeconds/(60*60), soundRemainingSeconds/60, soundRemainingSeconds%60];
    }
    
    CGFloat progressWidth = waveformShapeView.frame.size.width * CMTimeGetSeconds(musicPlayer.currentTime) / (currentTrack.durationInMilliseconds/1000.00);
        
    if(progressWidth < 0 )
    {
        progressWidth = 0;
    }
    if (progressWidth > waveformView.frame.size.width) {
        progressWidth = waveformView.frame.size.width;
    }
    
   // [UIView animateWithDuration:timerInterval animations:^{
        waveformProgressBar.frame = CGRectMake(waveformShapeView.frame.origin.x, waveformShapeView.frame.origin.y, progressWidth, waveformShapeView.frame.size.height);
    
    NSLog(@"progressBar x: %f, y: %f, width: %f, height: %f", waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, waveformProgressBar.frame.size.width, waveformProgressBar.frame.size.height);
   // }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
