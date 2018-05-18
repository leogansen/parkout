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
#import <MessageUI/MessageUI.h>

@interface DeveloperController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,MFMailComposeViewControllerDelegate>{
    UILabel* statusLabel;
    UILabel* statusValue;
    MKMapView* map;
    UILabel* infoLabel;
    UITextView* tv;
    UserInfo* userInfo;
    
}

-(id)initWithUserInfo:(UserInfo*)userInfo;
-(void)updateLocation:(CLLocation*)location;

@end
