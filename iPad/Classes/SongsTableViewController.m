//
//  SongsTableViewController.m
//  ChipPlayer
//
//  Created by Dave Dribin on 5/2/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import "SongsTableViewController.h"
#import "GmeMusicFile.h"
#import "TrackInfo.h"
#import "SongTableViewCell.h"


@interface SongsTableViewController ()
@property (nonatomic, readonly) UITableView * tableView;
@end

@implementation SongsTableViewController

@synthesize delegate = _delegate;
@synthesize musicFile = _musicFile;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

#pragma mark -

- (UITableView *)tableView
{
    return (UITableView *)self.view;
}

- (void)setMusicFile:(GmeMusicFile *)musicFile
{
    if (musicFile == _musicFile) {
        return;
    }
    
    [_musicFile release];
    _musicFile = [musicFile retain];
    [self.tableView reloadData];
}

- (void)setSelectedTrack:(NSInteger)selectedTrack
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:selectedTrack inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

- (NSInteger)selectedTrack
{
    NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath == nil) {
        return NSNotFound;
    }
    return indexPath.row;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_musicFile numberOfTracks];
}

- (id)viewFromNibNamed:(NSString *)nibName
{
    UIViewController * controller = [[UIViewController alloc] initWithNibName:nibName bundle:nil];
    id view = [[controller.view retain] autorelease];
    [controller release];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    SongTableViewCell *cell = (SongTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
#if 0
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
#else
        cell = [self viewFromNibNamed:@"SongTableViewCell"];
#endif
    }
    
    // Configure the cell.
    TrackInfo * trackInfo = [_musicFile infoForTrack:indexPath.row];
#if 0
    cell.textLabel.text = trackInfo.song;
#else
    cell.songLabel.text = trackInfo.song;
    cell.artistLabel.text = trackInfo.author;
    cell.gameLabel.text = trackInfo.game;
    cell.copyrightLabel.text = trackInfo.copyright;
    cell.interfaceOrientation = self.interfaceOrientation;
#endif
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [_delegate didSelectTrack:indexPath.row];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

