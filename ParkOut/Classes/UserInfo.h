//
//  UserInfo.h
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ParkingSession.h"

@interface UserInfo : NSObject

@property(copy, nonatomic) NSString* username;
@property(copy, nonatomic) NSString* password;
@property(copy, nonatomic) NSString* email_address;
@property(copy, nonatomic) NSString* title;
@property(copy, nonatomic) NSString* first_name;
@property(copy, nonatomic) NSString* middle_name;
@property(copy, nonatomic) NSString* last_name;
@property(copy, nonatomic) NSString* suffix;
@property(readwrite) BOOL loggedIn;
@property(copy, nonatomic) NSString* user_id;
@property(copy, nonatomic) NSString* vehicle_make;
@property(copy, nonatomic) NSString* device_token;
@property(copy, nonatomic) NSString* token;
@property (strong, nonatomic) ParkingSession* current_session;

@property (strong, atomic) NSMutableArray* log;

-(id)init;
-(id)initWithDictionary:(NSDictionary*)dict;
-(NSMutableDictionary*) userinfo_dictionary;
-(id)initWithUserInfo:(UserInfo*)user;

@end
