//
//  ParkEvent.h
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ParkingSession : NSObject

@property (readwrite) BOOL on_feet;
@property (readwrite) BOOL in_radius;
@property (readwrite) int status;
@property (readwrite) int interval;
@property (readwrite) double distance_from_car;
@property (readwrite) double time_from_car;
@property (readwrite) double speed;
@property (readwrite) int departing_in;
@property (readwrite) long departure_plan_timestamp;

@property (readwrite) CLLocationCoordinate2D parking_location;
@property (readwrite) CLLocationCoordinate2D user_location;
@property (readwrite) CLLocationCoordinate2D last_significant_location;

@property (strong, nonatomic) NSMutableArray* user_locations;
@property (readwrite) long timestamp;

@property (copy, nonatomic) NSString* user_id;

@property (readwrite) int prevStatus;

-(BOOL)isSet;
-(NSDictionary*)dictionary_frontend_calculation;
-(id)initWithPSDictionary:(NSDictionary*)dict;
-(id)initWithParkingSession:(ParkingSession*)session;

@end
