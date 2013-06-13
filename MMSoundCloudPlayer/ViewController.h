//
//  ViewController.h
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/7/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RetainPlaySoundViewControllerProtocol.h"

@interface ViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, RetainPlaySoundViewControllerProtocol>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIImage *currentArtworkImage;

@property (weak, nonatomic) IBOutlet UIButton *nowPlayingButton;
- (IBAction)goToNowPlaying:(id)sender;

@end
