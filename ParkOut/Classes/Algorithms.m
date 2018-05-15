
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
    
    
    //User shut off the app while the status was PARKING. He has a spot, but he may have moved away from it. He turns the app back on. If he is further than DELTA, we he is not longer parking, so we default to NOT_MOVING
//    if (self.userInfo.current_session.status == PARKING){
//        if (Algorithms distanceFrom:self.c to:<#(CLLocationCoordinate2D)#>)
//            }
//}
//}
    if ([location speed] > DRIVING_SPEED || ([location speed] > RUNNING_SPEED && !user.current_session.on_feet)) {
        if ([self speedStaysDriving:user.current_session.user_locations pings: 2 * FACTOR]){
            user.current_session.status = NOT_PARKED;
            [Utils addToLog:user message:[NSString stringWithFormat:@"Top. setting status to NOT_PARKED. Speed: %f",location.speed]];

            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lat"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lng"];
            
            [user.current_session.user_locations removeAllObjects];
            user.current_session.last_significant_location = location.coordinate;
            
        }
    }
    
   
    else if (location.speed <= 2) {
        
        //analyze recent changes in speed.
        if ((int)user.current_session.user_locations.count > 15 * FACTOR && [self speedStaysWalking:user.current_session.user_locations pings: 15 * FACTOR] && user.current_session.status == NOT_PARKED) {
            
            user.current_session.parking_location = [user.current_session.user_locations[[self findLowestSpeed:user.current_session.user_locations]] coordinate];//or 7 * FACTOR - half way
            user.current_session.status = PARKING;
            [Utils addToLog:user message:[NSString stringWithFormat:@"1. setting status to PARKING"]];

            NSLog(@"setting status to parking");
            int index = [self findLowestSpeed:user.current_session.user_locations];
            
            for (int i = index; i > 0; i--){
                [user.current_session.user_locations removeObjectAtIndex:i];
            }
            user.current_session.last_significant_location = location.coordinate;
            
            
        }else if (user.current_session.user_locations.count >= 3 * FACTOR) {
            
            if ([self speedStaysLow:user.current_session.user_locations pings: 3 * FACTOR]) {//We assume the user parked.
                
//                int index = [self findLowestSpeed:user.current_session.user_locations];
                int index = (int)(user.current_session.user_locations.count - 1);// try this instead

                for (int i = index; i > 0; i--){
                    [user.current_session.user_locations removeObjectAtIndex:i];
                }
                
                if (user.current_session.status == NOT_PARKED) {
                    user.current_session.parking_location = [user.current_session.user_locations[0] coordinate];
                    NSLog(@"setting status to parking");
                    user.current_session.status = PARKING;
                    [Utils addToLog:user message:[NSString stringWithFormat:@"2. setting status to PARKING"]];

                    user.current_session.last_significant_location = location.coordinate;
                }else if ((user.current_session.status == PARKED_NOT_IN_RADIUS || user.current_session.status == PARKED_MOVING_AWAY
                          || user.current_session.status == PARKED_COMING_BACK) && user.current_session.isSet) {
                    if (user.current_session.user_locations.count > 15 * FACTOR && [self speedStaysLow:user.current_session.user_locations pings: 15 * FACTOR]) {
                        if (user.current_session.status == PARKED_COMING_BACK){
                            if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] > DISTANCE_DELTA){
                                user.current_session.status = NOT_MOVING;
                                [Utils addToLog:user message:[NSString stringWithFormat:@"1. setting status to NOT_MOVING"]];

                            }
                        }else{
                            user.current_session.status = NOT_MOVING;
                            [Utils addToLog:user message:[NSString stringWithFormat:@"2. setting status to NOT_MOVING"]];

                            
                        }
                    }else if ([self distanceFrom:[location coordinate] to:user.current_session.parking_location] < 0.00003){
                        user.current_session.status = UNPARKING;
                        [Utils addToLog:user message:[NSString stringWithFormat:@"1. setting status to UNPARKING"]];

                    }else if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] > DISTANCE_DELTA){
                        user.current_session.status = NOT_MOVING;
                        [Utils addToLog:user message:@"3. Setting status to NOT_MOVING: distance to car > DISTANCE_DELTA"];
                    }
                    user.current_session.last_significant_location = location.coordinate;
                }
                
            }else if ([self speedStaysWalking:user.current_session.user_locations pings: 3 * FACTOR] ||
                     
                      (user.current_session.on_feet && ![self speedStaysWalking:user.current_session.user_locations pings: 3 * FACTOR ])//User is running
                      ) {
                
                if (user.current_session.status == PARKING) {
                    
                    if (user.current_session.user_locations.count > 3 * FACTOR) {
                        
                        
                        if ([self distanceFrom:user.current_session.parking_location to: [location coordinate]] > DISTANCE_DELTA*2
                            && [self distanceIsIncreasing:user.current_session.user_locations reference: user.current_session.parking_location pings:2 * FACTOR]) {
                            if ([self isWithinRadius:user.current_session.parking_location userLocation:
                                 [location coordinate] user:user]) {
                                
                                user.current_session.status = PARKED_MOVING_AWAY;
                                [Utils addToLog:user message:[NSString stringWithFormat:@"1. setting status to PARKED_MOVING_AWAY"]];

                            }else {
                                user.current_session.status = PARKED_NOT_IN_RADIUS;
                                [Utils addToLog:user message:[NSString stringWithFormat:@"1. setting status to PARKED_NOT_IN_RADIUS"]];

                            }
                            user.current_session.last_significant_location = location.coordinate;
                        }
                    }
                }else if ((user.current_session.status == PARKED_NOT_IN_RADIUS || user.current_session.status == PARKED_MOVING_AWAY
                          || user.current_session.status == PARKED_COMING_BACK || user.current_session.status == UNPARKING || user.current_session.status == NOT_MOVING) && user.current_session.isSet) {
                    
                    if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] < 0.00003){
                        
                        user.current_session.status = UNPARKING;
                        [Utils addToLog:user message:[NSString stringWithFormat:@"2. setting status to UNPARKING"]];

                        user.current_session.last_significant_location = location.coordinate;
                    }
                    
//                    else if (![self speedStaysWalking:user.current_session.user_locations pings: 5 * FACTOR] && [self distanceIsIncreasing:user.current_session.user_locations reference: user.current_session.parking_location pings:2 * FACTOR]) {
//                        user.current_session.status = NOT_PARKED;
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lat"];
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lng"];
//                        
//                        
//                        [user.current_session.user_locations removeAllObjects];
//                        user.current_session.last_significant_location = location.coordinate;
//                    }
                    
                    else if ([self distanceFrom:[location coordinate] to:user.current_session.last_significant_location] > DISTANCE_DELTA){
                        if ([self distanceIsDecreasing:user.current_session.user_locations reference: user.current_session.parking_location pings: 2 * FACTOR]) {
                            if ([self isWithinRadius:user.current_session.parking_location userLocation:
                                 [location coordinate]user:user]) {
                                user.current_session.status = PARKED_COMING_BACK;
                                [Utils addToLog:user message:[NSString stringWithFormat:@"1. setting status to PARKED_COMING_BACK. Distance to last significant location: %f",[self distanceFrom:[location coordinate] to:user.current_session.last_significant_location]]];

                            }else{
                                user.current_session.status = PARKED_NOT_IN_RADIUS;
                                [Utils addToLog:user message:[NSString stringWithFormat:@"2. setting status to PARKED_NOT_IN_RADIUS"]];

                            }
                        }else{
                            
                            if ([self isWithinRadius:user.current_session.parking_location userLocation:
                                 [location coordinate]user:user]) {
                                user.current_session.status = PARKED_MOVING_AWAY;
                                [Utils addToLog:user message:[NSString stringWithFormat:@"2. setting status to PARKED_MOVING_AWAY"]];

                            }else{
                                user.current_session.status = PARKED_NOT_IN_RADIUS;
                                [Utils addToLog:user message:[NSString stringWithFormat:@"3. setting status to PARKED_NOT_IN_RADIUS"]];

                            }
                        }
                        
                        user.current_session.last_significant_location = location.coordinate;
                        
                    }else if (user.current_session.status == PARKED_COMING_BACK && ![self distanceIsDecreasing:user.current_session.user_locations reference:user.current_session.parking_location pings:5*FACTOR]){
                        if ([self distanceFrom:location.coordinate to:user.current_session.parking_location] > DISTANCE_DELTA*2){
                            user.current_session.status = NOT_MOVING;
                            [Utils addToLog:user message:[NSString stringWithFormat:@"4. setting status to NOT_MOVING"]];

                            user.current_session.last_significant_location = location.coordinate;
                        }
                    }else if (user.current_session.status == PARKED_MOVING_AWAY && ![self distanceIsIncreasing:user.current_session.user_locations reference:user.current_session.parking_location pings:5*FACTOR]){
                        
                        user.current_session.status = NOT_MOVING;
                        [Utils addToLog:user message:[NSString stringWithFormat:@"5. setting status to NOT_MOVING"]];

                        user.current_session.last_significant_location = location.coordinate;
                    }
                }else{
                    
                }
            }
            
            
        }
        
    }
    
    if (user.current_session.status != user.current_session.prevStatus){
        //this is in case there is a crash
        if (user.current_session.status == PARKED_COMING_BACK
             || user.current_session.status == PARKED_MOVING_AWAY || user.current_session.status == PARKED_NOT_IN_RADIUS
            || user.current_session.status == NOT_MOVING){
            
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:NOT_MOVING] forKey:@"status"];

        }else if (user.current_session.status == NOT_PARKED || user.current_session.status == UNASSIGNED || user.current_session.status == PARKING){
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:user.current_session.status] forKey:@"status"];
        }
        
        
        if (user.current_session.status == NOT_PARKED){
            user.current_session.timestamp = ([[NSDate date] timeIntervalSince1970] * (long)1000);
        }
         if (user.current_session.status == PARKING){
             user.current_session.parking_location = location.coordinate;//Override algorithmic idea for now
             NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:PARKING],@"status", nil];
             [[NSNotificationCenter defaultCenter]postNotificationName:@"status_changed" object:nil userInfo:dict];
         }
        
        [Utils addToLog:user message:[NSString stringWithFormat:@"Status changed. PrevStatus: %d, new status: %d",user.current_session.prevStatus,user.current_session.status]];
        user.current_session.prevStatus = user.current_session.status;
        

    }else if (user.current_session.status == NOT_PARKED && ([[NSDate date] timeIntervalSince1970] * (long)1000) - user.current_session.timestamp < 30000 && user.current_session.distance_from_car < 50){
        user.current_session.parking_location = CLLocationCoordinate2DMake(0, 0);
        //we remove this from the system only after 30 seconds. For the user himself, it disappears from the defaults right away
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lat"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"parking_location_lng"];
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
        if ([(CLLocation*)locations[i] speed] < RUNNING_SPEED) {
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
+ (void)detectShaking:(CMAcceleration)_acceleration userInfo:(UserInfo*)user
{
    
    //Array for collecting acceleration for last one seconds period.
    static NSMutableArray *shakeDataForOneSec = nil;
    //Counter for calculating completion of one second interval
    static float currentFiringTimeInterval = 0.0f;
    
    currentFiringTimeInterval += 0.01f;
    if (currentFiringTimeInterval < 1.0f) {// if one second time intervall not completed yet
        if (!shakeDataForOneSec)
            shakeDataForOneSec = [NSMutableArray array];
        
        // Add current acceleration to array
        NSValue *boxedAcceleration = [NSValue value:&_acceleration withObjCType:@encode(CMAcceleration)];
        
        [shakeDataForOneSec addObject:boxedAcceleration];
        
    } else {
        NSLog(@"shakeDataForOneSec: %d",(int)shakeDataForOneSec.count);
        // Now, when one second was elapsed, calculate shake count in this interval. If there will be at least one shake then
        // we'll determine it as shaked in all this one second interval.
        
        int shakeCount = 0;
        NSArray* shakeDataForOneSecCopy = [shakeDataForOneSec copy];
        for (NSValue *boxedAcceleration in shakeDataForOneSecCopy) {
            CMAcceleration acceleration;
            [boxedAcceleration getValue:&acceleration];
            
            /*********************************
             *       Detecting shaking
             *********************************/
            double accX_2 = powf(acceleration.x,2);
            double accY_2 = powf(acceleration.y,2);
            double accZ_2 = powf(acceleration.z,2);
            
            double vectorSum = sqrt(accX_2 + accY_2 + accZ_2);
//            NSLog(@"vectorSum: %f",vectorSum);
            if (vectorSum >= 1.6f) {//3.5
                shakeCount++;
            }
            /*********************************/
        }
        user.current_session.on_feet = shakeCount > 0;
        
//        [shakeDataForOneSec removeAllObjects];
        shakeDataForOneSecCopy = nil;
        shakeDataForOneSec = nil;
        currentFiringTimeInterval = 0.0f;
    }
}

@end

