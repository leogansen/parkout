//
//  ViewController.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize userInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (int i = 0; i > 1; i--){
        NSLog(@"WHAT THE FUCK?");
    }
    
    // Do any additional setup after loading the view, typically from a nib.
    userInfo = [[UserInfo alloc]init];
    algo = [[Algorithms alloc]init];
    
    userInfo.current_event.status = NOT_PARKED;
    
    self.view.backgroundColor = [UIColor whiteColor];
    statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    [self.view addSubview:statusLabel];
    
    statusLabel.text = @"Status: ";
    
    statusValue = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 80)];
    statusValue.textAlignment = NSTextAlignmentCenter;
    statusValue.textColor = [UIColor redColor];
    statusValue.font = [UIFont fontWithName:@"Avenir" size:30];
    [self.view addSubview:statusValue];
    
    statusValue.text = @"Not Parked";
    
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 100)];
    infoLabel.numberOfLines = 4;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:infoLabel];
    
    tv = [[UITextView alloc]initWithFrame:CGRectMake(0, 250, self.view.frame.size.width, 200)];
    tv.editable = NO;
    [self.view addSubview:tv];
    
    map = [[MKMapView alloc]initWithFrame:CGRectMake(0, 450, self.view.frame.size.width, 200)];
    map.delegate = self;
    [self.view addSubview:map];
    [map setShowsUserLocation:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self start];
}

-(void)start{
    [self.locationManager startUpdatingLocation];
}
-(void)stop{
    [self.locationManager stopUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"horizontalAccuracy: %f",[locations[locations.count - 1] horizontalAccuracy]);
    if ([locations[locations.count - 1] horizontalAccuracy] > 20){
        badSignalCount++;
        if (badSignalCount == 30){
            self.userInfo.current_event.status = NOT_MOVING;
        }
        return;
    }
    badSignalCount = 0;
    [Algorithms determineStatus:locations[locations.count - 1] userInfo:self.userInfo];
 
    infoLabel.text = [NSString stringWithFormat:@"Speed: %.2f\n Condition: %@\n Number of Points: %d",locations[locations.count - 1].speed, [Algorithms getCondition],
                          (int)self.userInfo.current_event.user_locations.count];
    
    if (self.userInfo.current_event.status == -1){
        statusValue.text = @"NOT_PARKED";
    }else if (self.userInfo.current_event.status == 1){
        statusValue.text = @"PARKING";
    }else if (self.userInfo.current_event.status == 2){
        statusValue.text = @"PARKED_MOVING_AWAY";
    }else if (self.userInfo.current_event.status == 3){
        statusValue.text = @"PARKED_NOT_IN_RADIUS";
    }else if (self.userInfo.current_event.status == 4){
        statusValue.text = @"PARKED_COMING_BACK";
    }else if (self.userInfo.current_event.status == 5){
        statusValue.text = @"UNPARKING";
    }else if (self.userInfo.current_event.status == 6){
        statusValue.text = @"NOT_MOVING";
    }else if (self.userInfo.current_event.status == 0){
        statusValue.text = @"UNASSIGNED";
    }
    tv.text = userInfo.log;
//    NSLog(@"LOG: %@",userInfo.log);
   
    
    if (carLocation.latitude != self.userInfo.current_event.parking_location.latitude
        && carLocation.longitude != self.userInfo.current_event.parking_location.longitude){
        [map removeAnnotations:map.annotations];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:self.userInfo.current_event.parking_location];
        [annotation setTitle:@"Car"]; //You can set the subtitle too
        [map addAnnotation:annotation];
        
        MKMapCamera *newCamera = [MKMapCamera camera];
        [newCamera setCenterCoordinate:self.userInfo.current_event.parking_location];
        [map setCamera:newCamera];
        
        [self checkIfLocationIsValid:self.userInfo.current_event.parking_location];
        
    }
    carLocation = self.userInfo.current_event.parking_location;
    
}
-(void)checkIfLocationIsValid:(CLLocationCoordinate2D)location{
    CLLocation* loc = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        
        [geocoder reverseGeocodeLocation:loc completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if ([placemarks count] > 0)
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void){
                     
                     MKPlacemark *placemark = placemarks[0];
                     NSString* houseNumber = placemark.subThoroughfare;
                     NSString* street = [NSString stringWithFormat:@"%@, ",placemark.thoroughfare];
                     NSString* city = [NSString stringWithFormat:@"%@, ",placemark.locality];
                     NSString* state = placemark.administrativeArea;
                     NSString* zipCode = placemark.postalCode;

                     if (placemark.subThoroughfare==NULL){
                         houseNumber=@"";
                     }
                     if (placemark.thoroughfare==NULL){
                         street=@"";
                     }
                     if (placemark.locality==NULL){
                         city=@"";
                     }
                     if (placemark.administrativeArea==NULL){
                         state=@"";
                     }
                     if (placemark.postalCode==NULL){
                         zipCode=@"";
                     }
                     
                     NSString* description = @"";
                     if ([houseNumber isEqualToString:@""] && [street isEqualToString:@""] && [city isEqualToString:@""] && [state isEqualToString:@""] && [zipCode isEqualToString:@""]){
                         description =@"";
                     }else{
                         description = [NSString stringWithFormat:@"%@ %@%@%@",houseNumber, street , city, state];
                     }
                     
                 });
             }
         }
         ];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
