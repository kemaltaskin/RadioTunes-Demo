//
//  AppDelegate.h
//  Demo
//
//  Created by Kemal Taskin on 5/11/12.
//  Copyright (c) 2012 Yakamoz Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    MainViewController *_mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
