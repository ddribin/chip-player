//
//  DetailViewController.m
//  ChipPlayer
//
//  Created by Dave Dribin on 4/27/10.
//  Copyright Bit Maki, Inc. 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"

#import "MusicPlayerStateMachine.h"
#import "MusicPlayerAudioQueueOutput.h"
#import "MusicPlayerAUGraphOutput.h"
#import "MusicPlayerAUGraphWithQueueOutput.h"

#import "GmeMusicFile.h"
#import "TrackInfo.h"


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic) NSInteger currentTrack;
@property (nonatomic) NSInteger selectedTrack;

- (void)setupAudioSession;
- (void)setupAudioSessionCategory;
- (void)activateAudioSession;

- (void)configureView;
- (void)playCurrentTrack;
@end



@implementation DetailViewController

@synthesize toolbar, popoverController;
@synthesize detailItem = _detailItem;
@synthesize songTable = _songTable;
@synthesize currentTrack = _currentTrack;
@synthesize previousButton = _previousButton;
@synthesize playPauseButton = _playPauseButton;
@synthesize nextButton = _nextButton;

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)detailItem {
    if (_detailItem != detailItem) {
        [_detailItem release];
        _detailItem = [detailItem retain];
        
        [_stateMachine teardown];
        [_playerOutput release];
        [_stateMachine release];
        
#if 0
        Class MusicPlayerOutputClass = [MusicPlayerAudioQueueOutput class];
#elif 0
        Class MusicPlayerOutputClass = [MusicPlayerAUGraphOutput class];
#else
        Class MusicPlayerOutputClass = [MusicPlayerAUGraphWithQueueOutput class];
#endif
        _playerOutput = [[MusicPlayerOutputClass alloc] initWithDelegate:self];
        NSError * error = nil;
        if (![_playerOutput setupWithSampleRate:[detailItem sampleRate] error:&error]) {
            NSLog(@"error %@ %@", error, [error userInfo]);
        }
        [_playerOutput setMusicFile:_detailItem];
        
        _stateMachine = [[MusicPlayerStateMachine alloc] initWithActions:self];
        [_stateMachine setup];
        
        // Update the view.
        [self configureView];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


- (void)configureView {
    // Update the user interface for the detail item.
    [_songTable reloadData];
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Root List";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAudioSession];
}

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

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_detailItem numberOfTracks];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
    TrackInfo * trackInfo = [_detailItem infoForTrack:indexPath.row];
    cell.textLabel.text = [trackInfo song];
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
    [_stateMachine play];
}

#pragma mark -
#pragma mark Audio session handling

- (void)setupAudioSession;
{
    [self activateAudioSession];
    [[AVAudioSession sharedInstance] setDelegate:self];
    [self setupAudioSessionCategory];
}

- (void)setupAudioSessionCategory;
{
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    if (![session setCategory:AVAudioSessionCategoryPlayback error:&error]) {
        NSLog(@"Could not set audio session category: %@ %@", error, [error userInfo]);
    }
}

- (void)beginInterruption;
{
#if 0
    _playOnEndInterruption = self.isPlaying;
    [self stop];
#endif
    NSLog(@"beginInterruption ");
}

- (void)endInterruption;
{
#if 0
    [self activateAudioSession];
    
    if (_playOnEndInterruption) {
        [self play];
    }
#endif
    NSLog(@"endInterruption ");
}

- (void)activateAudioSession;
{
    NSError * error = nil;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    if (![session setActive:YES error:&error]) {
        NSLog(@"Could not activate audio session: %@ %@", error, [error userInfo]);
        return;
    }
}

#pragma mark -

- (IBAction)playPause:(id)sender;
{
    [_stateMachine togglePause];
}

- (IBAction)next:(id)sender;
{
    [_stateMachine next];
}

- (IBAction)previous:(id)sender;
{
    [_stateMachine previous];
}

#pragma mark -

- (void)musicPlayerOutputDidFinishTrack:(id<MusicPlayerOutput>)output;
{
    [_stateMachine trackDidFinish];
}

- (void)setSelectedTrack:(NSInteger)selectedTrack
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:selectedTrack inSection:0];
    [_songTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

- (NSInteger)selectedTrack
{
    NSIndexPath * indexPath = [_songTable indexPathForSelectedRow];
    if (indexPath == nil) {
        return NSNotFound;
    }
    return indexPath.row;
}

- (void)playCurrentTrack;
{
    NSInteger currentTrack = [self currentTrack];
    if (currentTrack == NSNotFound) {
        return;
    }
    
    NSError * error = nil;
    if (![_detailItem playTrack:currentTrack error:&error]) {
        NSLog(@"Could not play: %@ %@", error, [error userInfo]);
    }
}

#pragma mark -
#pragma mark MusicPlayerActions API

- (void)handleError:(NSError *)error;
{
    NSLog(@"handleError: %@ %@", error, [error userInfo]);
}

- (void)setButtonToPlay;
{
    [_playPauseButton setTitle:@"Play"];
}

- (void)setButtonToPause;
{
    [_playPauseButton setTitle:@"Pause"];
}

- (void)enableOrDisablePreviousAndNext;
{
    BOOL previousEnabled = ![self isCurrentTrackTheFirstTrack];
    [_previousButton setEnabled:previousEnabled];
    
    BOOL nextEnabled = ![self isCurrentTrackTheLastTrack];
    [_nextButton setEnabled:nextEnabled];
}

- (BOOL)setupAudio:(NSError **)error;
{
    return YES;
}

- (void)teardownAudio;
{
    [_playerOutput teardownAudio];
}

- (BOOL)startAudio:(NSError **)error;
{
    [self playCurrentTrack];
    return [_playerOutput startAudio:error];
}

- (void)setCurrentTrackToSelectedTrack;
{
    self.currentTrack = [self selectedTrack];
}

- (void)nextTrack;
{
    NSInteger currentTrack = self.currentTrack;
    if (currentTrack == NSNotFound) {
        return;
    }
    currentTrack++;
    self.currentTrack = currentTrack;
    self.selectedTrack = currentTrack;
}

- (void)previousTrack;
{
    NSInteger currentTrack = self.currentTrack;
    if (currentTrack == NSNotFound) {
        return;
    }
    currentTrack--;
    self.currentTrack = currentTrack;
    self.selectedTrack = currentTrack;
}

- (void)stopAudio;
{
    [_playerOutput stopAudio];
}

- (BOOL)pauseAudio:(NSError **)error;
{
    return [_playerOutput pauseAudio:error];
}

- (BOOL)unpauseAudio:(NSError **)error;
{
    return [_playerOutput unpauseAudio:error];
}

- (BOOL)isCurrentTrackTheLastTrack;
{
    NSInteger currentTrack = [self currentTrack];
    BOOL isLast = ((currentTrack+1) == [_detailItem numberOfTracks]);
    return isLast;
}


- (BOOL)isCurrentTrackTheFirstTrack;
{
    NSInteger currentTrack = [self currentTrack];
    BOOL isFirst = (currentTrack == 0);
    return isFirst;
}

#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    [_songTable release];
    [_previousButton release];
    [_playPauseButton release];
    [_nextButton release];
    
    [_stateMachine teardown];
    [_stateMachine release];
    [_detailItem release];
    [_playerOutput release];
    [super dealloc];
}

@end
