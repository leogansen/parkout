//
//  ParkEvent.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "ParkEvent.h"

@implementation ParkEvent

@synthesize distance_from_car,in_radius,parked,parking_location,speed,status,time_from_car,timestamp,unique_id,user_locations,walking,timestamp_unparking,last_significan_location;

-(id)init{
    self = [super init];
    if (self){
        self.user_locations = [NSMutableArray array];
    }
    return self;
}

-(BOOL)isSet{
    if ((int)self.parking_location.latitude != 0 && (int)self.parking_location.longitude != 0){
        return YES;
    }else{
        return NO;
    }
}

@end
