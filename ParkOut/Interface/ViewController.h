//
//  ViewController.h
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//
#import "LoginController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SlideMenu.h"
#import "Algorithms.h"
#import "Communicator.h"
#import "Place.h"
#import "MapAnnotation.h"
#import "Utils.h"
#import "SlideUpDrawer.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate,SlideMenuDelegate,UIGestureRecognizerDelegate,LoginControllerDelegate,SlideUpDrawerDelegate> {
    Algorithms* algo;
    MKMapView* map;
    CLLocationCoordinate2D carLocation;
    int badSignalCount;
    NSTimer* timer;
    int pinTag;
    int locationCount;
    NSString* selectedAnnotationId;
    NSMutableDictionary* currentAnnotations;
    
    SlideUpDrawer* slider;
}

@property (strong, nonatomic) UserInfo* userInfo;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

