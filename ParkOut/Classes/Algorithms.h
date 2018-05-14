//
//  Algorithms.h
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "UserInfo.h"
#import "Constants.h"
#import <CoreMotion/CoreMotion.h>
#import "Utils.h"

@interface Algorithms : NSObject

+(int)determineStatus:(CLLocation*)location userInfo:(UserInfo*)user;
+(NSString*)getCondition;
+(double)distanceFrom:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2;
+ (void)detectShaking:(CMAcceleration)_acceleration userInfo:(UserInfo*)user;


@end
