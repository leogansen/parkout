//
//  AppDelegate.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//


#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    viewController = [[ViewController alloc]initWithNibName:nil bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = self.viewController;
    
    self.viewController = viewController;
    
    // Set loginUIViewController as root view controller
    [[self window] setRootViewController:viewController];
    
    // Override point for customization after app launch
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
   
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if ((viewController.userInfo.current_session.status == PARKING || viewController.userInfo.current_session.status == PARKED_COMING_BACK
        || viewController.userInfo.current_session.status == PARKED_MOVING_AWAY || viewController.userInfo.current_session.status == PARKED_NOT_IN_RADIUS
         || viewController.userInfo.current_session.status == NOT_MOVING)
        && [Algorithms distanceFrom:viewController.userInfo.current_session.user_location to:viewController.userInfo.current_session.parking_location] > DISTANCE_DELTA*2){
        NSLog(@"User not moving");
        viewController.userInfo.current_session.status = NOT_MOVING;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:NOT_MOVING] forKey:@"status"];
        [Communicator reportStatus:viewController.userInfo.current_session completion:^(BOOL success, BOOL message_exists, NSString *message) {
            
        }];
        [viewController.locationManager startMonitoringSignificantLocationChanges];
        sleep(5);
    }

}


@end
