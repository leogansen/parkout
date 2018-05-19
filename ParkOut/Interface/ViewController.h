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
#import "DeveloperController.h"
#import "Constants.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate,SlideMenuDelegate,UIGestureRecognizerDelegate,LoginControllerDelegate,SlideUpDrawerDelegate,ManageUserControllerDelegate,UISearchBarDelegate,UITextFieldDelegate> {
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
    UITextField* search;
    
    DeveloperController* d;
    
    BOOL mapShouldFollowUser;
    
    CLLocation* lastRegionLocation;
    UIView* setParkingView;
    UIImageView* personImageView;
    UILabel* personCountLabel;
    
    BOOL signalStarted;
    
    NSMutableArray* addedPins;
    NSMutableArray* previouslyAddedPins;
    float iPhoneXDeltaCorrection;
    
    UIActivityIndicatorView *activity;
}
//@property (nonatomic, strong) UISearchBar* searchBar;
@property (strong, nonatomic) UserInfo* userInfo;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionManager *motionManager;

-(void)updateIntentions;
-(void)setUpView;
@end

