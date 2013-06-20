//
//  ViewController.m
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/7/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlaySoundViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "Reachability.h"

@interface ViewController ()
{
    NSMutableArray *collection;
    NSMutableArray *artworkArray;
    NSURL *mostRecentSearchUrl;
    NSString *identifier;

    PlaySoundViewController *playSoundViewController;

    NSOperationQueue *operationQueue;
    NSMutableArray *changedIndexPaths;
    
    UIImage *defaultImage;
    UIImage *nextArtworkImage;
    
    BOOL loading;
    BOOL internetConnection;
}

-(void)loadArtworkWithUrl:(NSURL*)artworkUrl atIndexPath:(NSIndexPath*)indexPath;
@end

@implementation ViewController

@synthesize searchBar, tableView, nowPlayingButton, activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    operationQueue = [[NSOperationQueue alloc] init];
    changedIndexPaths = [NSMutableArray array];
    
    searchBar.delegate = self;
    tableView.delegate = self;
    tableView.dataSource = self;
    identifier = @"cell";
    
    [nowPlayingButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_nowplaying_pressed.png"] forState:UIControlStateHighlighted];
    nowPlayingButton.hidden = YES;
    
    if (playSoundViewController ==  nil) {
        UIStoryboard *storyboard = self.storyboard;
        playSoundViewController = [storyboard instantiateViewControllerWithIdentifier:@"playSoundVC"];
    }
    
    defaultImage = [UIImage imageNamed:@"cloud.png"];
    loading = NO;
    
    // allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.soundcloud.com"];
    //[Reachability reachabilityForInternetConnection]
    
    // set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"REACHABLE!");
        
        NSBlockOperation *updateInternetConnectionOperation = [NSBlockOperation blockOperationWithBlock:^{
            internetConnection = YES;
        }];
        
        [[NSOperationQueue mainQueue] addOperation:updateInternetConnectionOperation];
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
        
        NSBlockOperation *updateInternetConnectionOperation = [NSBlockOperation blockOperationWithBlock:^{
            internetConnection = NO;
        }];
        
        [[NSOperationQueue mainQueue] addOperation:updateInternetConnectionOperation];
    };
    
    // start the notifier which will cause the reachability object to retain itself!
    [reach startNotifier];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search button was clicked: %@", self.searchBar.text);
    
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
   
    playSoundViewController.currentIndex = -1;
    [changedIndexPaths removeAllObjects];
    
    if (internetConnection) {
    
        if (!loading) {
            
            loading = YES;
            [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            collection = [[NSMutableArray alloc] init];
            [artworkArray removeAllObjects];
            [tableView reloadData];
            
            [activityIndicator startAnimating];
            [UIView animateWithDuration:.5 animations:^{
                tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y+30, tableView.frame.size.width, tableView.frame.size.height-30);
            }];
        }
        
        
        NSString *searchText = self.searchBar.text;
        NSString *encodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:@"https://api.soundcloud.com/search/sounds.json?client_id=%@&q=%@", sClientId, encodedSearchText];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        mostRecentSearchUrl = url;
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if ([response.URL isEqual: mostRecentSearchUrl]) {
                
                NSLog(@"ResponseUrl: %@", response.URL);
                
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                collection = [[NSMutableArray alloc] initWithArray: [responseDictionary objectForKey:@"collection"]];
                artworkArray = [[NSMutableArray alloc] initWithCapacity:collection.count];
                
                
                NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
                
                for (int i = 0; i < collection.count; i++) {
                    if (collection[i][@"streamable"] == [[NSNumber alloc] initWithBool:NO]) {
                        [indexSet addIndex:i];
                    }
                    else {
                        [artworkArray addObject:defaultImage];
                    }
                }
                
                [collection removeObjectsAtIndexes:indexSet];
                
                if (collection.count == 0) {
                    identifier = @"noResults";
                }
                else {
                    identifier = @"cell";
                }
                
                [activityIndicator stopAnimating];
                
                [tableView reloadData];
                
                [UIView animateWithDuration:.5 animations:^{
                    tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y-30, tableView.frame.size.width, tableView.frame.size.height+30);
                }];
                
                loading = NO;
            }
        } ];
    }
    else {
        identifier = @"noInternet";
        [tableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([identifier isEqualToString:@"noResults"] || [identifier isEqualToString:@"noInternet"]) {
        return 1;
    }
    
    return collection.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if ([identifier isEqualToString:@"noResults"] || [identifier isEqualToString:@"noInternet"]) {
        return cell;
    }
    
    cell.textLabel.text = collection[indexPath.row][sTitle];
    cell.detailTextLabel.text = collection[indexPath.row][sUser][sUserName];
    
    if (![artworkArray[indexPath.row] isEqual: defaultImage]) {
        cell.imageView.image = artworkArray[indexPath.row];
    }
    else if (!loading){
        cell.imageView.image = defaultImage;
        
        NSURL *artworkUrl;
        if (collection[indexPath.row][sArtworkUrl] != [NSNull null]) {
            artworkUrl = [NSURL URLWithString:collection[indexPath.row][sArtworkUrl]];
            [self loadArtworkWithUrl:artworkUrl atIndexPath:indexPath];
        }
        else if (collection[indexPath.row][sUser][sAvatarUrl] != [NSNull null])
        {
            artworkUrl = [NSURL URLWithString:collection[indexPath.row][sUser][sAvatarUrl]];
            [self loadArtworkWithUrl:artworkUrl atIndexPath:indexPath];
        }
    }
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![identifier isEqual:@"cell"]) {
        return nil;
    }
    else {
        return indexPath;
    }
}

-(void)loadArtworkWithUrl:(NSURL*)artworkUrl atIndexPath:(NSIndexPath*)indexPath
{
 //   NSLog(@"Loading artworkUrl: %@", artworkUrl);
    if (![changedIndexPaths containsObject:indexPath]) {
        [changedIndexPaths addObject:indexPath];
    }
    
    NSBlockOperation *getArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *artworkData = [NSData dataWithContentsOfURL:artworkUrl];
        UIImage *artwork = [UIImage imageWithData:artworkData];
        

        NSBlockOperation *showArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (artwork != nil && loading == NO) {

                [artworkArray replaceObjectAtIndex:indexPath.row withObject:artwork];

                //NSLog(@"reload the tableview indexpath with new artwork");
                /*if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
                }*/
                
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadThese) object:nil];
                [self performSelector:@selector(reloadThese) withObject:nil afterDelay:0.3];
            }
        }];
        
        [[NSOperationQueue mainQueue] addOperation:showArtworkOperation];
    }];
    
    [operationQueue addOperation:getArtworkOperation];

}

- (void)reloadThese
{
    [self.tableView reloadRowsAtIndexPaths:changedIndexPaths withRowAnimation:NO];
    [changedIndexPaths removeAllObjects];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (playSoundViewController.currentIndex != indexPath.row) {
        playSoundViewController.newSoundSelected = YES;
        playSoundViewController.playlistArray = collection;
        playSoundViewController.currentIndex = indexPath.row;
    }
    else
    {
        playSoundViewController.newSoundSelected = NO;
    }
    
    [self presentViewController: playSoundViewController animated:YES completion:nil];
}

- (IBAction)goToNowPlaying:(id)sender {
    
    playSoundViewController.newSoundSelected = NO;
    [self presentViewController: playSoundViewController animated:YES completion:nil];
    
}

-(void)retainPlaySoundViewController
{
    playSoundViewController = (PlaySoundViewController*)self.presentedViewController;
    nowPlayingButton.hidden = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
