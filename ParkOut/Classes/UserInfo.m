//
//  UserInfo.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize current_session,log,email_address,first_name,last_name,loggedIn,password,token,user_id,username,middle_name,suffix,title,vehicle_make,device_token;

-(id)init{
    self = [super init];
    if (self){
        self.current_session = [[ParkingSession alloc]init];
        self.log = [[[NSUserDefaults standardUserDefaults]objectForKey:@"user_log"]mutableCopy];
        if (self.log == nil){
            self.log = [[NSMutableArray alloc]init];
        }
        self.username = @"";
        self.password = @"";
        self.email_address = @"";
        self.first_name = @"";
        self.last_name = @"";
        self.token = @"";
        self.user_id = @"";
        
        self.title = @"";
        self.middle_name = @"";
        self.suffix = @"";
        self.loggedIn = NO;
        self.vehicle_make = @"";
        self.device_token = @"";
    }
    return self;
}
-(id)initWithUserInfo:(UserInfo*)user{
    self = [super init];
    if (self){
        self.current_session = [[ParkingSession alloc]initWithParkingSession:user.current_session];
        self.log = [user.log mutableCopy];
        if (self.log == nil){
            self.log = [[NSMutableArray alloc]init];
        }
        self.username = user.username;
        self.password = user.password;
        self.email_address = user.email_address;
        self.first_name = user.first_name;
        self.last_name = user.last_name;
        self.token = user.token;
        self.user_id = user.user_id;
        
        self.title = user.title;
        self.middle_name = user.middle_name;
        self.suffix = user.suffix;
        self.loggedIn = user.loggedIn;
        self.vehicle_make = user.vehicle_make;
        self.device_token = user.device_token;
    }
    return self;
}


-(id)initWithDictionary:(NSDictionary*)dict{
    if (self = [super init]) {
        self.current_session = [[ParkingSession alloc]initWithPSDictionary:[dict objectForKey:@"current_session"]];
        
        self.username = @"";
        if ([dict objectForKey:@"username"] != [NSNull null]){
            self.username = [dict objectForKey:@"username"];
        }
        self.password = @"";
        if ([dict objectForKey:@"password"] != [NSNull null]){
            self.password = [dict objectForKey:@"password"];
        }
        self.email_address = @"";
        if ([dict objectForKey:@"email_address"] != [NSNull null]){
            self.email_address = [dict objectForKey:@"email_address"];
            
        }
        self.title = @"";
        if ([dict objectForKey:@"title"] != [NSNull null]){
            self.title = [dict objectForKey:@"title"];
            
        }
        self.first_name = @"";
        if ([dict objectForKey:@"first_name"] != [NSNull null]){
            self.first_name = [dict objectForKey:@"first_name"];
            
        }
        self.middle_name = @"";
        if ([dict objectForKey:@"middle_name"] != [NSNull null]){
            self.middle_name = [dict objectForKey:@"middle_name"];
            
        }
        self.last_name = @"";
        if ([dict objectForKey:@"last_name"] != [NSNull null]){
            self.last_name = [dict objectForKey:@"last_name"];
            
        }
        self.suffix = @"";
        if ([dict objectForKey:@"suffix"] != [NSNull null]){
            self.suffix = [dict objectForKey:@"suffix"];
            
        }
        
        self.token = @"";
        if ([dict objectForKey:@"token"] != [NSNull null]){
            self.token = [dict objectForKey:@"token"];
            
        }
        self.user_id = @"";
        if ([dict objectForKey:@"user_id"] != [NSNull null]){
            self.user_id = [dict objectForKey:@"user_id"];
            
        }
        self.vehicle_make = @"";
        if ([dict objectForKey:@"vehicle_make"] != [NSNull null]){
            self.vehicle_make = [dict objectForKey:@"vehicle_make"];
            
        }
        
        self.log = [[[NSUserDefaults standardUserDefaults]objectForKey:@"user_log"]mutableCopy];
        if (self.log == nil){
            self.log = [[NSMutableArray alloc]init];
        }
      
        self.device_token = @"";
        if ([dict objectForKey:@"device_token"] != [NSNull null]){
            self.device_token = [dict objectForKey:@"device_token"];
            
        }
        
    }
    return self;
}


-(NSMutableDictionary*) userinfo_dictionary{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            self.username,@"username",
            self.password,@"password",
            self.email_address,@"email_address",
            self.title,@"title",
            self.first_name,@"first_name",
            self.middle_name,@"middle_name",
            self.last_name,@"last_name",
            self.suffix,@"suffix",
            self.user_id, @"user_id",
            self.vehicle_make, @"vehicle_make",
            [[NSUserDefaults standardUserDefaults] objectForKey:@"DEVICE_TOKEN"],@"device_token",
            //Others?
            nil];
}
@end
