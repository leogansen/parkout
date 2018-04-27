//
//  UserInfo.h
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ParkEvent.h"

@interface UserInfo : NSObject

@property (strong, nonatomic) ParkEvent* current_event;
@property (readwrite) CLLocationCoordinate2D parking_location;

@property (copy, nonatomic) NSString* log;

@end
