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

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    viewController = [[ViewController alloc]initWithNibName:nil bundle:nil];
    NSLog(@"System version: %f",[[UIDevice currentDevice].systemVersion floatValue]);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = self.viewController;
    
    self.viewController = viewController;
    
    // Set loginUIViewController as root view controller
    [[self window] setRootViewController:viewController];
    
    // Override point for customization after app launch
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    if (viewController.userInfo.current_session.status == NOT_PARKED){
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:NOT_PARKED] forKey:@"status"];
    }
    
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [self registerForRemoteNotifications];
    
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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:viewController.userInfo.current_session.departing_in] forKey:@"departing_in"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLong:viewController.userInfo.current_session.departure_plan_timestamp] forKey:@"departure_plan_timestamp"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:viewController.locationManager.location.coordinate.latitude] forKey:@"last_lat"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:viewController.locationManager.location.coordinate.longitude] forKey:@"last_lng"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLong:[[NSDate date]timeIntervalSince1970]] forKey:@"last_signal_timestamp"];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if ((viewController.userInfo.current_session.status == PARKED_COMING_BACK
        || viewController.userInfo.current_session.status == PARKED_MOVING_AWAY || viewController.userInfo.current_session.status == PARKED_NOT_IN_RADIUS
         || viewController.userInfo.current_session.status == NOT_MOVING)
//        && [Algorithms distanceFrom:viewController.userInfo.current_session.user_location to:viewController.userInfo.current_session.parking_location] > DISTANCE_DELTA*2
//        && viewController.userInfo.current_session.isSet
        ){
        NSLog(@"User not moving");
        viewController.userInfo.current_session.status = NOT_MOVING;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:NOT_MOVING] forKey:@"status"];
        [Communicator reportStatus:viewController.userInfo.current_session completion:^(BOOL success, BOOL message_exists, NSString *message) {
            
        }];
        [viewController.locationManager startMonitoringSignificantLocationChanges];
        sleep(5);
    }else if (viewController.userInfo.current_session.status == NOT_PARKED || viewController.userInfo.current_session.status == UNASSIGNED || viewController.userInfo.current_session.status == PARKING){
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:viewController.userInfo.current_session.status] forKey:@"status"];
        [Communicator reportStatus:viewController.userInfo.current_session completion:^(BOOL success, BOOL message_exists, NSString *message) {
            
        }];
        
    }else{
        
    }

}

- (void)registerForRemoteNotifications {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }else{
                NSLog(@"ERROR registering for notifications");

            }
        }];
    }
    else {
        // Code for old versions
    }
}
// Handle remote notification registration.
- (void)application:(UIApplication *)app
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *devTokenBytes    = [[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    devTokenBytes              = [devTokenBytes stringByReplacingOccurrencesOfString:@" " withString:@""];
    // save device token
    [[NSUserDefaults standardUserDefaults]setObject:devTokenBytes forKey:@"DEVICE_TOKEN"];
    // Forward the token to your provider, using a custom method.
    NSLog(@"Device token: %@",devTokenBytes);//devTokenBytes
}

- (void)application:(UIApplication *)app
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error: %@", err);

}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"didReceiveRemoteNotification");
    if ([[userInfo objectForKey:@"id"] intValue] == 1){
        [viewController updateIntentions];
    }

}

//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    completionHandler();
}
@end
