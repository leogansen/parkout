
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
    [user.current_event.user_locations addObject:location];
    if (user.current_event.user_locations.count > 60){
        [user.current_event.user_locations removeObjectAtIndex:0];
    }
    NSLog(@"User locations: %d Speed: %f",(int)user.current_event.user_locations.count,[(CLLocation*)user.current_event.user_locations[user.current_event.user_locations.count - 1] speed]);
    
    if ([location speed] > 2) {
        user.log = [user.log stringByAppendingString:@"Condition A\n"];
        NSLog(@"A");condition = @"0";
        if ([self speedStaysDriving:user.current_event.user_locations pings: 2 * FACTOR]){
            user.log = [user.log stringByAppendingString:@"Speed stays driving; Status NOT_PARKED\n"];
            user.current_event.status = NOT_PARKED;
            [user.current_event.user_locations removeAllObjects];
            user.current_event.last_significan_location = user.current_event.parking_location = CLLocationCoordinate2DMake(0, 0);
        }
    }

    else if (user.current_event.walking) {
         NSLog(@"C");condition = @"2";
        user.log = [user.log stringByAppendingString:@"Condition C\n"];

        if (user.current_event.isSet) {
            if (user.current_event.user_locations.count > 5 * FACTOR) {
                if ([self distanceIsIncreasing:user.current_event.user_locations reference: user.current_event.parking_location pings:2 * FACTOR]) {
                    if ([self isWithinRadius:user.current_event.parking_location userLocation:
                                       [user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate] user:user]) {
                        user.current_event.status = PARKED_MOVING_AWAY;
                    }else {
                        user.current_event.status = PARKED_NOT_IN_RADIUS;
                    }
                }else if ([self distanceIsDecreasing:user.current_event.user_locations reference: user.current_event.parking_location pings:2 * FACTOR]) {
                    if ([self isWithinRadius:user.current_event.parking_location userLocation:
                         [user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate]user:user])
                    {
                        user.current_event.status = PARKED_COMING_BACK;
                    }else {
                        user.current_event.status = PARKED_NOT_IN_RADIUS;
                    }
                }
            }
        }
    }else if (location.speed <= 2) {
        user.log = [user.log stringByAppendingString:[NSString stringWithFormat:@"Condition D. Points: %d\n",(int)user.current_event.user_locations.count]];

         NSLog(@"D");condition = @"3";
        //analyze recent changes in speed.
        if ((int)user.current_event.user_locations.count > 15 * FACTOR && [self speedStaysWalking:user.current_event.user_locations pings: 15 * FACTOR] && user.current_event.status == NOT_PARKED) {
            user.log = [user.log stringByAppendingString:@"User has been walking, user.current_event.user_locations > 15 * FACTOR  D\n"];
        
            user.current_event.parking_location = [user.current_event.user_locations[0] coordinate];
            user.log = [user.log stringByAppendingString:@"D: PARKING LOCATION STORED BECAUSE USER WAS WALKING FOR TOO LONG\n"];
            user.current_event.status = PARKING;
            
            int index = [self findLowestSpeed:user.current_event.user_locations];
            user.log = [user.log stringByAppendingString:@"D: Deleting points\n"];
            
            for (int i = index; i > 0; i--){
                [user.current_event.user_locations removeObjectAtIndex:i];
            }
            user.current_event.last_significan_location = location.coordinate;
        
            
        }else if (user.current_event.user_locations.count >= 3 * FACTOR) {
            user.log = [user.log stringByAppendingString:@"D: > 5 points\n"];

            condition = @"3.1";
            if ([self speedStaysLow:user.current_event.user_locations pings: 3 * FACTOR]) {//We assume the user parked.
                user.log = [user.log stringByAppendingString:@"D: Speed stays low (3.1.1)\n"];

                condition = @"3.1.1";
                int index = [self findLowestSpeed:user.current_event.user_locations];
                user.log = [user.log stringByAppendingString:@"D: Deleting points\n"];

                for (int i = index; i > 0; i--){
                    [user.current_event.user_locations removeObjectAtIndex:i];
                }
                
                if (user.current_event.status == NOT_PARKED) {
                    user.current_event.parking_location = [user.current_event.user_locations[0] coordinate];
                    user.log = [user.log stringByAppendingString:@"D: PARKING LOCATION STORED\n"];
                    user.current_event.status = PARKING;
                    user.current_event.last_significan_location = location.coordinate;
                }else if (user.current_event.status == PARKED_NOT_IN_RADIUS || user.current_event.status == PARKED_MOVING_AWAY
                          || user.current_event.status == PARKED_COMING_BACK){
                    if (user.current_event.user_locations.count > 10 * FACTOR && [self speedStaysLow:user.current_event.user_locations pings: 10 * FACTOR]) {
                        user.current_event.status = NOT_MOVING;
                        user.log = [user.log stringByAppendingString:@"D: NOT MOVING\n"];
                    }else if ([self distanceFrom:[(CLLocation*)user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate] to:user.current_event.parking_location] < 0.00003){
                        user.current_event.status = UNPARKING;
                        user.log = [user.log stringByAppendingString:@"D: VERY SLOWLY GOT BACK. STATUS - UNPARKING\n"];
                        
                     }else if ([self distanceFrom:[(CLLocation*)user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate] to:user.current_event.parking_location] > 0.00003){
                         user.current_event.status = NOT_MOVING;
                         user.log = [user.log stringByAppendingString:@"D: Signal not stable? NOT MOVING\n"];
                         
                     }
                    user.current_event.last_significan_location = location.coordinate;
                }
                NSLog(@"STATUS? %d",user.current_event.status);
                
            }else if ([self speedStaysWalking:user.current_event.user_locations pings: 3 * FACTOR]) {
                user.log = [user.log stringByAppendingString:@"D: speed stays walking (3.1.1)\n"];

                condition = @"3.1.2";
                if (user.current_event.status == PARKING) {
                    condition = @"3.1.2.1";
                    user.log = [user.log stringByAppendingString:@"D: 3.1.2.1 - walking\n"];

                    if (user.current_event.user_locations.count > 3 * FACTOR) {
                        user.log = [user.log stringByAppendingString:@"D: 3.1.2.1 enough points\n"];
                       
                        
                        if ([self distanceFrom:user.current_event.parking_location to: [user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate]] > DISTANCE_DELTA*2
                            && [self distanceIsIncreasing:user.current_event.user_locations reference: user.current_event.parking_location pings:2 * FACTOR]) {
                            if ([self isWithinRadius:user.current_event.parking_location userLocation:
                                               [user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate]user:user]) {
                                user.log = [user.log stringByAppendingString:@"D: Distance is increasing\n"];

                                condition = @"3.1.2.1.1";
                                user.current_event.status = PARKED_MOVING_AWAY;
                            }else {
                                condition = @"3.1.2.1.2";
                                user.log = [user.log stringByAppendingString:@"D: Not in radius\n"];

                                user.current_event.status = PARKED_NOT_IN_RADIUS;
                            }
                            user.current_event.last_significan_location = location.coordinate;
                        }
                    }
                }else if (user.current_event.status == PARKED_NOT_IN_RADIUS || user.current_event.status == PARKED_MOVING_AWAY
                          || user.current_event.status == PARKED_COMING_BACK || user.current_event.status == UNPARKING || user.current_event.status == NOT_MOVING) {
                     condition = @"3.1.2.3";
                    
                    if ([self distanceFrom:location.coordinate to:user.current_event.parking_location] < 0.00003){
                        user.log = [user.log stringByAppendingString:@"D: UNPARKING\n"];
                        
                        condition = @"3.1.2.4.3";
                        user.current_event.status = UNPARKING;
                        user.current_event.last_significan_location = location.coordinate;
                    }else if (![self speedStaysWalking:user.current_event.user_locations pings: 5 * FACTOR] && [self distanceIsIncreasing:user.current_event.user_locations reference: user.current_event.parking_location pings:2 * FACTOR]) {
                        user.current_event.status = NOT_PARKED;
                        [user.current_event.user_locations removeAllObjects];
                        user.current_event.last_significan_location = user.current_event.parking_location = CLLocationCoordinate2DMake(0, 0);
                    }else if ([self distanceFrom:[location coordinate] to:user.current_event.last_significan_location] > DISTANCE_DELTA){
                            if ([self distanceIsDecreasing:user.current_event.user_locations reference: user.current_event.parking_location pings: 2 * FACTOR]) {
                                user.log = [user.log stringByAppendingString:@"D: Distance is decreasing\n"];
                                if ([self isWithinRadius:user.current_event.parking_location userLocation:
                                      [user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate]user:user]) {
                                    user.log = [user.log stringByAppendingString:@"D: In radius\n"];
                                    condition = @"3.1.2.3";
                                    user.current_event.status = PARKED_COMING_BACK;
                                    
                                }else{
                                    user.log = [user.log stringByAppendingString:@"D: Not in radius\n"];
                                    user.current_event.status = PARKED_NOT_IN_RADIUS;
                                }
                            }else{
                                
                                if ([self isWithinRadius:user.current_event.parking_location userLocation:
                                     [user.current_event.user_locations[user.current_event.user_locations.count - 1] coordinate]user:user]) {
                                    user.log = [user.log stringByAppendingString:@"D: In radius\n"];
                                    condition = @"3.1.2.3";
                                    user.current_event.status = PARKED_MOVING_AWAY;
                                }else{
                                    user.log = [user.log stringByAppendingString:@"D: Not in radius\n"];
                                    user.current_event.status = PARKED_NOT_IN_RADIUS;
                                }
                            }
                       
                            user.current_event.last_significan_location = location.coordinate;

                    }else if (user.current_event.status == PARKED_COMING_BACK && ![self distanceIsDecreasing:user.current_event.user_locations reference:user.current_event.parking_location pings:5*FACTOR]){
                        user.log = [user.log stringByAppendingString:@"D: PARKED_COMING_BACK, but the distance is not decreasing\n"];

                        user.current_event.status = NOT_MOVING;
                        user.current_event.last_significan_location = location.coordinate;
                    }else if (user.current_event.status == PARKED_MOVING_AWAY && ![self distanceIsIncreasing:user.current_event.user_locations reference:user.current_event.parking_location pings:5*FACTOR]){
                        user.log = [user.log stringByAppendingString:@"D: PARKED_MOVING_AWAY, but the distance is not increasing\n"];

                        user.current_event.status = NOT_MOVING;
                        user.current_event.last_significan_location = location.coordinate;
                    }
                }else{
                    user.log = [user.log stringByAppendingString:@"D: No condition met\n"];

                }
            }
            
            
        }
        
    }
    return user.current_event.status;
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
    user.log = [user.log stringByAppendingString:[NSString stringWithFormat:@"D: In radius? Distance: %f\n",distance]];

    return inRadius;
}


@end
