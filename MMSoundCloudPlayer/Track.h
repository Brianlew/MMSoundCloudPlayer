//
//  Track.h
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/11/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (strong, nonatomic) NSString *trackTitle;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSURL *streamUrl;
@property (strong, nonatomic) NSURL *waveformUrl;
@property (strong, nonatomic) NSURL *artworkUrl;
@property (strong, nonatomic) UIImage *artWork;
@property (strong, nonatomic) UIImage *waveformImage;
@property NSInteger durationInMilliseconds;
@property NSInteger index;

-(void)fetchArtworkForImageView:(UIImageView *)imageView onOperationQueue:(NSOperationQueue *)operationQueue withCurrentIndex:(NSInteger)currentIndex;
-(void)fetchWaveformImageForImageView:(UIImageView*)imageView onOperationQueue:(NSOperationQueue *)operationQueue withCurrentIndex:(NSInteger)currentIndex;;
+(Track*)createTrackFromTrack:(Track*)track;

@end
