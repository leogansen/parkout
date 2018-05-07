
//
//  Algorithms.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "Algorithms.h"

@implementation Algorithms

static NSString* condition;
+(NSString*)getCondition{
    return condition;
}
+(int)determineStatus:(CLLocation*)location userInfo:(UserInfo*)user{
    [user.current_session.user_locations addObject:location];
    if (user.current_session.user_locations.count > 60){
        [user.current_session.user_locations removeObjectAtIndex:0];
    }
    NSLog(@"User locations: %d",(int)user.current_session.user_locations.count);
    CLLocationCoordinate2D prevParkingLoc =   CLLocationCoordinate2DMake([[[NSUserDefaults standardUserDefaults]objectForKey:@"parking_location_lat"]doubleValue], [[[NSUserDefaults standardUserDefaults]objectForKey:@"parking_location_lng"]doubleValue]);
    
    if (user.current_session.status != UNASSIGNED && [self distanceFrom:prevParkingLoc to:location.coordinate] > MAX_RADIUS){
        user.current_session.status = UNASSIGNED;
        user.current_session.parking_location = CLLocationCoordinate2DMake(0, 0);
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lat"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lng"];
    }
    
    if ([location speed] > 2) {
        if ([self speedStaysDriving:user.current_session.user_locations pings: 2 * FACTOR]){
            user.current_session.status = NOT_PARKED;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lat"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lng"];
            
            [user.current_session.user_locations removeAllObjects];
            user.current_session.last_significan_location = location.coordinate;
            
        }
    }
    
    else if (user.current_session.on_feet) {
        
        if (user.current_session.isSet) {
            if (user.current_session.user_locations.count > 5 * FACTOR) {
                if ([self distanceIsIncreasing:user.current_session.user_locations reference: user.current_session.parking_location pings:2 * FACTOR]) {
                    if ([self isWithinRadius:user.current_session.parking_location userLocation:
                         [user.current_session.user_locations[user.current_session.user_locations.count - 1] coordinate] user:user]) {
                        user.current_session.status = PARKED_MOVING_AWAY;
                    }else {
                        user.current_session.status = PARKED_NOT_IN_RADIUS;
                    }
                }else if ([self distanceIsDecreasing:user.current_session.user_locations reference: user.current_session.parking_location pings:2 * FACTOR]) {
                    if ([self isWithinRadius:user.current_session.parking_location userLocation:
                         [user.current_session.user_locations[user.current_session.user_locations.count - 1] coordinate]user:user])
                    {
                        user.current_session.status = PARKED_COMING_BACK;
                    }else {
                        user.current_session.status = PARKED_NOT_IN_RADIUS;
                    }
                }
            }
        }
    }else if (location.speed <= 2) {
        
        //analyze recent changes in speed.
        if ((int)user.current_session.user_locations.count > 15 * FACTOR && [self speedStaysWalking:user.current_session.user_locations pings: 15 * FACTOR] && user.current_session.status == NOT_PARKED) {
            
            user.current_session.parking_location = [user.current_session.user_locations[0] coordinate];
            user.current_session.status = PARKING;
            
            NSLog(@"setting status to parking");
            int index = [self findLowestSpeed:user.current_session.user_locations];
            
            for (int i = index; i > 0; i--){
                [user.current_session.user_locations removeObjectAtIndex:i];
            }
            user.current_session.last_significan_location = location.coordinate;
            
            
        }else if (user.current_session.user_locations.count >= 3 * FACTOR) {
            
            if ([self speedStaysLow:user.current_session.user_locations pings: 3 * FACTOR]) {//We assume the user parked.
                
                int index = [self findLowestSpeed:user.current_session.user_locations];
                
                for (int i = index; i > 0; i--){
                    [user.current_session.user_locations removeObjectAtIndex:i];
                }
                
                if (user.current_session.status == NOT_PARKED) {
                    user.current_session.parking_location = [user.current_session.user_locations[0] coordinate];
                    NSLog(@"setting status to parking");
                    user.current_session.status = PARKING;
                   
                    user.current_session.last_significan_location = location.coordinate;
                }else if (user.current_session.status == PARKED_NOT_IN_RADIUS || user.current_session.status == PARKED_MOVING_AWAY
                          || user.current_session.status == PARKED_COMING_BACK){
                    if (user.current_session.user_locations.count > 15 * FACTOR && [self speedStaysLow:user.current_session.user_locations pings: 15 * FACTOR]) {
                        if (user.current_session.status == PARKED_COMING_BACK){
                            if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] > DISTANCE_DELTA){
                                user.current_session.status = NOT_MOVING;
                            }
                        }else{
                            user.current_session.status = NOT_MOVING;
                            
                        }
                    }else if ([self distanceFrom:[(CLLocation*)user.current_session.user_locations[user.current_session.user_locations.count - 1] coordinate] to:user.current_session.parking_location] < 0.00003){
                        user.current_session.status = UNPARKING;
                        
                    }else if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] > DISTANCE_DELTA){
                        user.current_session.status = NOT_MOVING;
                        
                    }
                    user.current_session.last_significan_location = location.coordinate;
                }
                
            }else if ([self speedStaysWalking:user.current_session.user_locations pings: 3 * FACTOR]) {
                
                if (user.current_session.status == PARKING) {
                    
                    if (user.current_session.user_locations.count > 3 * FACTOR) {
                        
                        
                        if ([self distanceFrom:user.current_session.parking_location to: [user.current_session.user_locations[user.current_session.user_locations.count - 1] coordinate]] > DISTANCE_DELTA*2
                            && [self distanceIsIncreasing:user.current_session.user_locations reference: user.current_session.parking_location pings:2 * FACTOR]) {
                            if ([self isWithinRadius:user.current_session.parking_location userLocation:
                                 [user.current_session.user_locations[user.current_session.user_locations.count - 1] coordinate]user:user]) {
                                
                                user.current_session.status = PARKED_MOVING_AWAY;
                            }else {
                                
                                user.current_session.status = PARKED_NOT_IN_RADIUS;
                            }
                            user.current_session.last_significan_location = location.coordinate;
                        }
                    }
                }else if (user.current_session.status == PARKED_NOT_IN_RADIUS || user.current_session.status == PARKED_MOVING_AWAY
                          || user.current_session.status == PARKED_COMING_BACK || user.current_session.status == UNPARKING || user.current_session.status == NOT_MOVING) {
                    
                    if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] < 0.00003){
                        
                        user.current_session.status = UNPARKING;
                        user.current_session.last_significan_location = location.coordinate;
                    }else if (![self speedStaysWalking:user.current_session.user_locations pings: 5 * FACTOR] && [self distanceIsIncreasing:user.current_session.user_locations reference: user.current_session.parking_location pings:2 * FACTOR]) {
                        user.current_session.status = NOT_PARKED;
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lat"];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lng"];
                        
                        
                        [user.current_session.user_locations removeAllObjects];
                        user.current_session.last_significan_location = location.coordinate;
                    }else if ([self distanceFrom:[location coordinate] to:user.current_session.last_significan_location] > DISTANCE_DELTA){
                        if ([self distanceIsDecreasing:user.current_session.user_locations reference: user.current_session.parking_location pings: 2 * FACTOR]) {
                            if ([self isWithinRadius:user.current_session.parking_location userLocation:
                                 [user.current_session.user_locations[user.current_session.user_locations.count - 1] coordinate]user:user]) {
                                user.current_session.status = PARKED_COMING_BACK;
                                
                            }else{
                                user.current_session.status = PARKED_NOT_IN_RADIUS;
                            }
                        }else{
                            
                            if ([self isWithinRadius:user.current_session.parking_location userLocation:
                                 [user.current_session.user_locations[user.current_session.user_locations.count - 1] coordinate]user:user]) {
                                user.current_session.status = PARKED_MOVING_AWAY;
                            }else{
                                user.current_session.status = PARKED_NOT_IN_RADIUS;
                            }
                        }
                        
                        user.current_session.last_significan_location = location.coordinate;
                        
                    }else if (user.current_session.status == PARKED_COMING_BACK && ![self distanceIsDecreasing:user.current_session.user_locations reference:user.current_session.parking_location pings:5*FACTOR]){
                        if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] > DISTANCE_DELTA*2){
                            user.current_session.status = NOT_MOVING;
                            user.current_session.last_significan_location = location.coordinate;
                        }
                    }else if (user.current_session.status == PARKED_MOVING_AWAY && ![self distanceIsIncreasing:user.current_session.user_locations reference:user.current_session.parking_location pings:5*FACTOR]){
                        
                        user.current_session.status = NOT_MOVING;
                        user.current_session.last_significan_location = location.coordinate;
                    }
                }else{
                    
                }
            }
            
            
        }
        
    }
    
    if (user.current_session.status != user.current_session.prevStatus){
        if (user.current_session.status == NOT_PARKED){
            user.current_session.timestamp = ([[NSDate date] timeIntervalSince1970] * (long)1000);
        }
        user.current_session.prevStatus = user.current_session.status;
    }else if (user.current_session.status == NOT_PARKED && ([[NSDate date] timeIntervalSince1970] * (long)1000) - user.current_session.timestamp < 30000 && user.current_session.distance_from_car < 50){
        user.current_session.parking_location = CLLocationCoordinate2DMake(0, 0);
        //we remove this from the system only after 30 seconds. For the user himself, it disappears from the defaults right away
    }
    return user.current_session.status;
}

//find highest speed in a collection. If highest > 5 comes after lowest (< 5), revert to NOT_PARKED
+(int) findHighestSpeed:(NSMutableArray*)locations {
    NSLog(@"findHighestSpeed");
    int index = 0;
    for (int i = 1; i < locations.count; i++) {
        if ([(CLLocation*)locations[i] speed] > [(CLLocation*)locations[i-1] speed]) {
            index = i;
        }
    }
    return index;
}
//find lowest speed in a collection. If lowest < 5, still NOT_PARKED
+(int) findLowestSpeed:(NSMutableArray*)locations {
    NSLog(@"findLowestSpeed");
    
    int index = 0;
    for (int i = 1; i < locations.count; i++) {
        if ([(CLLocation*)locations[i] speed] < [(CLLocation*)locations[i-1] speed]) {
            index = i;
        }
    }
    return index;
}
//find if the speed of the last 5 pings is < 3
+(BOOL)speedStaysLow:(NSMutableArray*)locations pings:(int) pings {
    NSLog(@"speedStaysLow");
    
    BOOL stays = YES;
    if ((int)locations.count < pings){
        pings = (int)locations.count - 1;
    }
    for (int i = (int)locations.count - 1; i > (int)locations.count - pings; i--) {
        if ([(CLLocation*)locations[i] speed] > 0.4) {
            stays = NO;
        }
    }
    return stays;
}
//find if the speed of the last 5 pings is < 3
+(BOOL)speedStaysWalking:(NSMutableArray*)locations pings:(int) pings {
    NSLog(@"speedStaysWalking");
    
    BOOL stays = YES;
    if ((int)locations.count < pings){
        pings = (int)locations.count - 1;
    }
    for (int i = (int)locations.count - 1; i > (int)locations.count - pings; i--) {
        if ([(CLLocation*)locations[i] speed] > 2) {
            stays = NO;
        }
    }
    return stays;
}

+(BOOL)speedStaysDriving:(NSMutableArray*)locations pings:(int) pings {
    NSLog(@"speedStaysDriving. Locations: %d, ping: %d",(int)locations.count, pings);
    BOOL stays = YES;
    
    if ((int)locations.count < pings){
        pings = (int)locations.count - 1;
    }
    for (int i = (int)locations.count - 1; i > (int)locations.count - pings; i--) {
        if ([(CLLocation*)locations[i] speed] > 5) {
            stays = NO;
        }
    }
    return stays;
}



//distance is increasing
+(BOOL)distanceIsIncreasing:(NSMutableArray*)locations reference:(CLLocationCoordinate2D) reference pings:(int)pings{
    NSLog(@"distanceIsIncreasing");
    if (pings >= (int)locations.count){
        pings = (int)locations.count - 1;
    }
    BOOL increasing = NO;
    if (locations.count > 0 && [self distanceFrom:[(CLLocation*)locations[locations.count - 1 - pings] coordinate] to:reference] <
        [self distanceFrom:[(CLLocation*)locations[locations.count - 1] coordinate] to:reference]){
        increasing = YES;
    }
    return increasing;
}
+(double)distanceFrom:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2{
    NSLog(@"distanceFrom");
    
    double dx = coord1.longitude - coord2.longitude;
    double dy = coord1.latitude - coord2.latitude;
    double distance = sqrt(dx*dx + dy*dy);
    return distance;
}

+(BOOL)distanceIsDecreasing:(NSMutableArray*)locations reference:(CLLocationCoordinate2D) reference pings:(int)pings {
    NSLog(@"distanceIsDecreasing");
    if (pings >= (int)locations.count){
        pings = (int)locations.count - 1;
    }
    BOOL decreasing = NO;
    if (locations.count > 0 && [self distanceFrom:[(CLLocation*)locations[locations.count - 1 - pings] coordinate] to:reference] >
        [self distanceFrom:[(CLLocation*)locations[locations.count - 1] coordinate] to:reference]){
        decreasing = YES;
    }
    return decreasing;
}

+(BOOL)isWithinRadius:(CLLocationCoordinate2D) parkingSpot userLocation:(CLLocationCoordinate2D) userLocation user:(UserInfo*)user{
    NSLog(@"isWithinRadius");
    
    BOOL inRadius = true;
    double distance = [self distanceFrom:parkingSpot to:userLocation];
    if (distance > IN_RADIUS) {
        inRadius = false;
    }
    //user.log = [//user.log stringByAppendingString:[NSString stringWithFormat:@"D: In radius? Distance: %f\n",distance]];
    
    return inRadius;
}


@end

