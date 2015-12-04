//
//  BCAppDelegate.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import "BCAppDelegate.h"
#import "BCConverterViewController.h"

@implementation BCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    BCConverterViewController *converterViewController = [[BCConverterViewController alloc] init];
    UINavigationController *converterNavigationController = [[UINavigationController alloc] initWithRootViewController:converterViewController];
    converterNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Converter" image:nil tag:0];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[converterNavigationController];
    tabBarController.tabBar.tintColor = [UIColor colorWithRed:53.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
