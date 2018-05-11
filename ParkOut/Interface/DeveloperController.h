//
//  DeveloperController.h
//  ParkOut
//
//  Created by Leonid on 5/9/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "UserInfo.h"
#import "Constants.h"
#import "ParkingSession.h"

@interface DeveloperController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>{
    UILabel* statusLabel;
    UILabel* statusValue;
    MKMapView* map;
    UILabel* infoLabel;
    UITextView* tv;
    int badSignalCount;
    UserInfo* userInfo;
}

-(id)initWithUserInfo:(UserInfo*)userInfo;
-(void)updateLocation:(CLLocation*)location;

@end
