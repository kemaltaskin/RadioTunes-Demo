//
//  YLAppDelegate.h
//  Demo
//
//  Copyright (c) 2013 Yakamoz Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *_navController;
    MainViewController *_mainViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
