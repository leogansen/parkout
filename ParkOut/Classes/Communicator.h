//
//  Communicator.h
//  ParkOut
//
//  Created by Leonid on 4/30/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "UserInfo.h"

@interface Communicator : NSObject

+(void)validateRegistrationToken:(NSString*)token completion:(void (^)(BOOL))completion;
+(void)logInWithUsername:(NSString*)username password:(NSString*)password completion:(void (^)(NSDictionary*,BOOL))completion;
+(void)resendConfirmationEmail:(UserInfo*)ui completion:(void (^)(BOOL,BOOL,NSString*))completion;
+(void)recoverPasswordWithUserInfo:(UserInfo*)ui completion:(void (^)(BOOL,NSError*))completion;
+(void)reportStatus:(ParkingSession*)session completion:(void (^)(BOOL,BOOL,NSString*))completion;
+(void)fetchParkingLocations:(CLLocationCoordinate2D)location userId:(NSString*)user_id latDelta:(float)latDelta lngDelta:(float)lngDelta completion:(void (^)(NSDictionary* ))completion;
+(void)postNotification:(NSString*)requested_user_id message:(NSString*)message completion:(void (^)(BOOL,BOOL,NSString*))completion;

@end
