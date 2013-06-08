//
//  ViewController.h
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/7/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
