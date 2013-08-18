//
//  BBUAppDelegate.m
//  Me
//
//  Created by Boris Bügling on 09.08.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "BBUAppDelegate.h"
#import "BBUPositionsViewController.h"

@implementation BBUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [BBUPositionsViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
