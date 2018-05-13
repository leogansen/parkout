//
//  Place.m
//  ParkOut
//
//  Created by Leonid on 5/2/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "Place.h"

@implementation Place
@synthesize name,exit,description,latitude,longitude,tag,user_intention_set;

-(id)init{
    self = [super init];
    if (self){
        
    }
    return self;
}
-(id)initWithLatitude:(float)lat longitude:(float)lng{
    self = [super init];
    if (self){
        self.latitude = lat;
        self.longitude = lng;
    }
    return self;
}

-(NSString*)getCoordsAsString{
    NSString* coordString = [NSString stringWithFormat:@"%f,%f",self.latitude,self.longitude];
    return coordString;
}


@end
