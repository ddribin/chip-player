/*
 * Copyright (c) 2010 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "DetailViewController.h"
#import "RootViewController.h"
#import "SongsTableViewController.h"

#import "MusicPlayerStateMachine.h"
#import "MusicPlayerAudioQueueOutput.h"
#import "MusicPlayerAUGraphOutput.h"
#import "MusicPlayerAUGraphWithQueueOutput.h"

#import "GmeMusicFile.h"
#import "TrackInfo.h"

#import <AudioToolbox/AudioToolbox.h>


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic) NSInteger currentTrack;

- (void)setupAudioSession;
- (void)setupAudioSessionCategory;
- (void)activateAudioSession;

- (void)playCurrentTrack;
@end



@implementation DetailViewController

@synthesize toolbar, popoverController;
@synthesize songsTableViewController = _songsTableViewController;
@synthesize musicFile = _musicFile;
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
- (void)setMusicFile:(id)detailItem {
    if (_musicFile != detailItem) {
        [_musicFile release];
        _musicFile = [detailItem retain];
        
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
        [self activateAudioSession];
        NSError * error = nil;
        if (![_playerOutput setupWithSampleRate:[detailItem sampleRate] error:&error]) {
            NSLog(@"error %@ %@", error, [error userInfo]);
        }
        [_playerOutput setMusicFile:_musicFile];
        
        _stateMachine = [[MusicPlayerStateMachine alloc] initWithActions:self];
        [_stateMachine setup];
        
        // Update the view.
        _songsTableViewController.musicFile = _musicFile;
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [_songsTableViewController willRotateToInterfaceOrientation:interfaceOrientation duration:duration];
    [super willRotateToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    [super didRotateFromInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    _songsTableViewController.delegate = self;
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
#pragma mark Songs table view controller delegate

- (void)didSelectTrack:(NSInteger)track;
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
    [_stateMachine beginInterruption];
}

- (void)endInterruption;
{
    [_stateMachine endInterruption];
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

- (void)playCurrentTrack;
{
    NSInteger currentTrack = [self currentTrack];
    if (currentTrack == NSNotFound) {
        return;
    }
    
    NSError * error = nil;
    if (![_musicFile playTrack:currentTrack error:&error]) {
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
    [self activateAudioSession];
    return YES;
}

- (void)teardownAudio;
{
    [_playerOutput teardownAudio];
}

- (BOOL)startAudio:(NSError **)error;
{
    [self activateAudioSession];
    [self playCurrentTrack];
    return [_playerOutput startAudio:error];
}

- (void)setCurrentTrackToSelectedTrack;
{
    self.currentTrack = [_songsTableViewController selectedTrack];
}

- (void)nextTrack;
{
    NSInteger currentTrack = self.currentTrack;
    if (currentTrack == NSNotFound) {
        return;
    }
    currentTrack++;
    self.currentTrack = currentTrack;
    _songsTableViewController.selectedTrack = currentTrack;
}

- (void)previousTrack;
{
    NSInteger currentTrack = self.currentTrack;
    if (currentTrack == NSNotFound) {
        return;
    }
    currentTrack--;
    self.currentTrack = currentTrack;
    _songsTableViewController.selectedTrack = currentTrack;
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
    BOOL isLast = ((currentTrack+1) == [_musicFile numberOfTracks]);
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
    [_musicFile release];
    [_playerOutput release];
    [super dealloc];
}

@end
