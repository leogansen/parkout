//
//  UserInfo.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize current_event,parking_location,log;

-(id)init{
    self = [super init];
    if (self){
        current_event = [[ParkEvent alloc]init];
        self.log = @"";
    }
    return self;
}

@end
