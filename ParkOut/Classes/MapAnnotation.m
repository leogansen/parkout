//
//  MapAnnotation.m
//  ParkOut
//
//  Created by Leonid on 5/2/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation
@synthesize coordinate,title,place,image,tag,description,selected,user_id,status,departing_in;

-(id)initWithPlace:(Place*)_place{
    self = [super init];
    if (self != nil) {
        coordinate.latitude = _place.latitude;
        coordinate.longitude = _place.longitude;
        self.place = _place;
    }
    return self;
}


-(float)latitude
{
    return self.coordinate.latitude;
}
-(float)longitude
{
    return self.coordinate.longitude;
}
- (NSString *)subtitle
{
   return self.description;
}

@end
