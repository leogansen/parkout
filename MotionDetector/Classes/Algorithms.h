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

@interface Algorithms : NSObject

+(int)determineStatus:(CLLocation*)location userInfo:(UserInfo*)user;
+(NSString*)getCondition;
@end
