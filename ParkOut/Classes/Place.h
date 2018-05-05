//
//  Place.h
//  ParkOut
//
//  Created by Leonid on 5/2/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject{
    NSString* name;
    NSString* exit;
    NSString* description;
}
@property (strong, atomic) NSString* name;
@property (strong, atomic) NSString* exit;
@property (strong, atomic) NSString* description;
@property (readwrite) float latitude;
@property (readwrite) float longitude;
@property (readwrite) int tag;

-(id)initWithLatitude:(float)lat longitude:(float)lng;
-(id)init;
-(NSString*)getCoordsAsString;

@end
