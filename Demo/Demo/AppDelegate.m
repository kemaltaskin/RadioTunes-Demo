//
//  AppDelegate.m
//
//  Copyright (c) 2013 Yakamoz Labs. All rights reserved.
//

#import "AppDelegate.h"
#import <RadioTunes/RadioTunes.h>
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[YLAudioSession sharedInstance] startAudioSession];
    
    _mainViewController = [[MainViewController alloc] init];
    _navController = [[UINavigationController alloc] initWithRootViewController:_mainViewController];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window setRootViewController:_navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc {
    [_navController release];
    [_mainViewController release];
    [_window release];
    
    [super dealloc];
}

@end
