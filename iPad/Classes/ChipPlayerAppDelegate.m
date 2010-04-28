//
//  ChipPlayerAppDelegate.m
//  ChipPlayer
//
//  Created by Dave Dribin on 4/27/10.
//  Copyright Bit Maki, Inc. 2010. All rights reserved.
//

#import "ChipPlayerAppDelegate.h"
#import "RootViewController.h"
#import "DetailViewController.h"

#import "DDCoreAudio.h"


@implementation ChipPlayerAppDelegate

@synthesize window, splitViewController;
@synthesize rootViewController = _rootViewController;
@synthesize detailViewController = _detailViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];

    NSLog(@"launchOptions: %@", launchOptions);
    NSArray * directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSAssert([directories count] == 1, @"Unexpected Documents directory count");
    NSLog(@"directories: %@", directories);
    NSString * documents = [directories objectAtIndex:0];
    NSArray * contents = [[NSFileManager defaultManager] directoryContentsAtPath:documents];
    contents = [contents sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSLog(@"contents: %@", contents);
    NSMutableArray * documentPaths = [NSMutableArray arrayWithCapacity:[contents count]];
    for (NSString * document in contents) {
        NSString * documentPath = [documents stringByAppendingPathComponent:document];
        [documentPaths addObject:documentPath];
    }
    
    _rootViewController.files = documentPaths;
    
    [DDAudioComponent printComponents];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

