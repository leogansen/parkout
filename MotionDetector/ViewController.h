//
//  ViewController.h
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
//#import "UserInfo.h"
#import "Algorithms.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>{
    UILabel* statusLabel;
    UILabel* statusValue;    
    Algorithms* algo;
    MKMapView* map;
    UILabel* infoLabel;
    UITextView* tv;
    CLLocationCoordinate2D carLocation;
    int badSignalCount;
}
@property (strong, nonatomic) UserInfo* userInfo;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

