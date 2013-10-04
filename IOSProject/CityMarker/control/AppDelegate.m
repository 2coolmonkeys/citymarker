//
//  AppDelegate.m
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import "AppDelegate.h"

#import "MapViewController.h"
#import "CitySDKManager.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    self.window.rootViewController = mapViewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
