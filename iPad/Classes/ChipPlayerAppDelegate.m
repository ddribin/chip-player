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

