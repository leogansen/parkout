//
//  MapAnnotation.h
//  ParkOut
//
//  Created by Leonid on 5/2/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    Place* place;
}

@property (nonatomic,readwrite) CLLocationCoordinate2D coordinate;
@property (strong, atomic) Place* place;
@property (copy, nonatomic) NSString* title;
@property (copy, nonatomic) NSString* description;
@property (strong, nonatomic) UIImage* image;
@property (readwrite) int tag;
@property (readwrite) BOOL selected;
@property (copy, nonatomic) NSString* user_id;
@property (readwrite) int status;
@property (readwrite) int departing_in;
@property (copy, nonatomic) NSString* driver_id;
@property (readwrite) BOOL user_intention_set;

-(id) initWithPlace: (Place*) place;


@end

