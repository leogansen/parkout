//
//  ParkEvent.h
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ParkEvent : NSObject

@property (readwrite) BOOL parked;
@property (readwrite) BOOL walking;
@property (readwrite) BOOL in_radius;
@property (readwrite) int status;
@property (readwrite) double distance_from_car;
@property (readwrite) double time_from_car;
@property (readwrite) double speed;

@property (readwrite) CLLocationCoordinate2D parking_location;
@property (readwrite) CLLocationCoordinate2D last_significan_location;

@property (strong, nonatomic) NSMutableArray* user_locations;
@property (readwrite) long timestamp;
@property (readwrite) long timestamp_unparking;

@property (copy, nonatomic) NSString* unique_id;

-(BOOL)isSet;

@end
