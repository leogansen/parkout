//
//  ParkEvent.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "ParkingSession.h"

@implementation ParkingSession

@synthesize distance_from_car,on_feet,parking_location,speed,status,time_from_car,timestamp,user_id,user_locations,last_significant_location,user_location,interval,prevStatus,departing_in,departure_plan_timestamp;

-(id)init{
    self = [super init];
    if (self){
        self.user_locations = [NSMutableArray array];
        self.interval = 3;
    }
    return self;
}
-(id)initWithParkingSession:(ParkingSession*)session{
    self = [super init];
    if (self){
        self.distance_from_car = session.distance_from_car;
        self.on_feet = session.on_feet;
        self.parking_location = session.parking_location;
        self.speed = session.speed;
        self.status = session.status;
        self.time_from_car = session.time_from_car;
        self.timestamp = session.timestamp;
        self.user_id = session.user_id;
        self.user_locations = [[NSMutableArray alloc]initWithArray: session.user_locations];
        self.user_id = session.user_id;
        self.last_significant_location = session.last_significant_location;
        self.user_location = session.user_location;
        self.interval = session.interval;
        self.departing_in = session.departing_in;
        self.departure_plan_timestamp = session.departure_plan_timestamp;
    }
    return self;
}
-(id)initWithPSDictionary:(NSDictionary*)dict{
    self = [super init];
    if (self){
        self.user_locations = [NSMutableArray array];
        
        if ([dict objectForKey:@"distance_from_car"] != [NSNull null]){
            self.distance_from_car = [[dict objectForKey:@"distance_from_car"] doubleValue];
        }
        if ([dict objectForKey:@"speed"] != [NSNull null]){
            self.speed = [[dict objectForKey:@"speed"]doubleValue];
        }
        if ([dict objectForKey:@"time_from_car"] != [NSNull null]){
            self.time_from_car = [[dict objectForKey:@"time_from_car"]doubleValue];
        }
        if ([dict objectForKey:@"on_feet"] != [NSNull null]){
            self.on_feet = [[dict objectForKey:@"on_feet"]boolValue];
        }
        if ([dict objectForKey:@"parking_location"] != [NSNull null]){
            self.parking_location = CLLocationCoordinate2DMake([[[dict objectForKey:@"parking_location"]objectForKey:@"latitude"]doubleValue], [[[dict objectForKey:@"parking_location"]objectForKey:@"longitude"]doubleValue]);
        }
        if ([dict objectForKey:@"status"] != [NSNull null]){
            self.status = [[dict objectForKey:@"status"]intValue];
        }
        if ([dict objectForKey:@"timestamp"] != [NSNull null]){
            self.timestamp = [[dict objectForKey:@"timestamp"]longValue];
        }
        if ([dict objectForKey:@"user_id"] != [NSNull null]){
            self.user_id = [dict objectForKey:@"user_id"];
        }
        if ([dict objectForKey:@"user_location"] != [NSNull null]){
            self.user_location = CLLocationCoordinate2DMake([[[dict objectForKey:@"user_location"]objectForKey:@"latitude"]doubleValue], [[[dict objectForKey:@"user_location"]objectForKey:@"longitude"]doubleValue]);
        }
        if ([dict objectForKey:@"interval"] != [NSNull null]){
            self.interval = [[dict objectForKey:@"interval"] intValue];
        }
        if ([dict objectForKey:@"departing_in"] != [NSNull null]){
            self.departing_in = [[dict objectForKey:@"departing_in"] intValue];
        }//departure_plan_timestamp
        if ([dict objectForKey:@"departure_plan_timestamp"] != [NSNull null]){
            self.departure_plan_timestamp = [[dict objectForKey:@"departure_plan_timestamp"] longValue];
        }
    }
    return self;
}

-(BOOL)isSet{
    float distance = [self distanceFrom:self.parking_location to:CLLocationCoordinate2DMake(0, 0)];
    if (distance > 1){
        return YES;
    }else{
        return NO;
    }
}
-(NSDictionary*)coordinateToDictionary:(CLLocationCoordinate2D)coordinate{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:coordinate.latitude],@"latitude",
            [NSNumber numberWithDouble:coordinate.longitude],@"longitude",
            nil];
}
-(NSDictionary*)dictionary_frontend_calculation{
    NSMutableDictionary* dict = [NSMutableDictionary
                                 dictionary];
    [dict setObject:[NSNumber numberWithDouble:self.distance_from_car] forKey:@"distance_from_car"];
    [dict setObject:[NSNumber numberWithDouble:self.speed] forKey:@"speed"];
    [dict setObject:[NSNumber numberWithDouble:self.time_from_car] forKey:@"time_from_car"];
    [dict setObject:[NSNumber numberWithBool:self.on_feet] forKey:@"on_feet"];
    [dict setObject:[NSNumber numberWithInt:self.interval] forKey:@"interval"];

//    if (self.parking_location.latitude != 0){
    [dict setObject:[self coordinateToDictionary:self.parking_location] forKey:@"parking_location"];
//    }
    [dict setObject:[NSNumber numberWithInt:self.status] forKey:@"status"];
    [dict setObject:[NSNumber numberWithLong:self.timestamp] forKey:@"timestamp"];
    if (self.user_id != nil){
        [dict setObject:self.user_id forKey:@"user_id"];
    }
//    if (self.user_location.latitude != 0){
    [dict setObject:[self coordinateToDictionary:self.user_location] forKey:@"user_location"];
    [dict setObject:[NSNumber numberWithInt:self.departing_in] forKey:@"departing_in"];
    [dict setObject:[NSNumber numberWithLong:self.departure_plan_timestamp] forKey:@"departure_plan_timestamp"];

//    }
    return dict;
}
-(double)distanceFrom:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2{
    NSLog(@"distanceFrom");
    
    double dx = coord1.longitude - coord2.longitude;
    double dy = coord1.latitude - coord2.latitude;
    double distance = sqrt(dx*dx + dy*dy);
    return distance;
}

@end
