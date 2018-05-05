//
//  UserInfo.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize current_session,parking_location,log,email_address,first_name,last_name,loggedIn,password,token,user_id,username,middle_name,suffix,title;

-(id)init{
    self = [super init];
    if (self){
        self.current_session = [[ParkingSession alloc]init];
        self.log = @"";
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
        
    }
    return self;
}
-(id)initWithUserInfo:(UserInfo*)user{
    self = [super init];
    if (self){
        self.current_session = [[ParkingSession alloc]initWithParkingSession:user.current_session];
        self.log = user.log;
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
        self.current_session.user_id = self.user_id;
    }
    return self;
}


-(id)initWithDictionary:(NSDictionary*)dict{
    if (self = [super init]) {
        self.current_session = [[ParkingSession alloc]init];

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
        self.current_session.user_id = self.user_id;
        
        
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
            
            //Others?
            nil];
}
@end
