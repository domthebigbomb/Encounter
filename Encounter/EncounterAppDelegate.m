//
//  EncounterAppDelegate.m
//  Encounter
//
//  Created by Dominic Ong on 12/23/13.
//  Copyright (c) 2013 DOngJKau. All rights reserved.
//

#import "EncounterAppDelegate.h"
#import "EncounterMapApiKey.h"
#import <GoogleMaps/GoogleMaps.h>
@implementation EncounterAppDelegate
{
    id services_;
}

//@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if ([kAPIKey length] == 0) {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure APIKey inside SDKDemoAPIKey.h for your "
        @"bundle `%@`, see README.GoogleMapsSDKDemos for more information";
        @throw [NSException exceptionWithName:@"SDKDemoAppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    [GMSServices provideAPIKey:kAPIKey];
    services_ = [GMSServices sharedServices];
    
    // Log the required open source licenses!  Yes, just NSLog-ing them is not
    // enough but is good for a demo.
    NSLog(@"Open source licenses:\n%@", [GMSServices openSourceLicenseInfo]);
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
     */
    return YES;

}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
