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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:bundleOrNil]))
    {
        userInfo = [[UserInfo alloc]init];
        algo = [[Algorithms alloc]init];
        
        userInfo.current_session.status = UNASSIGNED;
        userInfo.current_session.status = [[[NSUserDefaults standardUserDefaults] objectForKey:@"status"]intValue];

        pinTag = 1;
        currentAnnotations = [NSMutableDictionary dictionary];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
       
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
   
    map = [[MKMapView alloc]initWithFrame:self.view.frame];
    map.delegate = self;
    [self.view addSubview:map];
    [map setShowsUserLocation:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    
    
    //    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    UIScreenEdgePanGestureRecognizer* panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(sidePanDetected:)];
    [panGesture setEdges:UIRectEdgeLeft];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    UIButton* locateMe = [UIButton buttonWithType:UIButtonTypeCustom];
    locateMe.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 110, 40, 40);
    [locateMe setImage:[UIImage imageNamed:@"locate@3x"] forState:UIControlStateNormal];
    [locateMe addTarget:self action:@selector(locate) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:locateMe];
    
    NSArray* sliderArray = @[@"",@"",@"Open Parking:",@"(If the driver is not moving, tap the red icon to see/ask the driver when they are leaving)."];
    slider = [[SlideUpDrawer alloc]initWithFrame:self.view.frame];
    slider.delegate = self;
    [self.view addSubview:slider];
    [slider setTableText:sliderArray fontSize:14];
    [slider setButton:locateMe];
    
    [self addMyParkingLocation];
    

}
-(void)addMyParkingLocation{
    Place* parkingPlace = [[Place alloc]initWithLatitude:[[[NSUserDefaults standardUserDefaults]objectForKey:@"parking_location_lat"]doubleValue] longitude:[[[NSUserDefaults standardUserDefaults]objectForKey:@"parking_location_lng"]doubleValue]];
    parkingPlace.name = [NSString stringWithFormat:@"YOU PARKED HERE"];
    parkingPlace.description = @"";
    MapAnnotation* parkingAnnotation = [[MapAnnotation alloc]initWithPlace:parkingPlace];
    parkingAnnotation.title = parkingPlace.name;
    parkingAnnotation.image = [UIImage imageNamed:@"car-position@3x.png"];
    parkingAnnotation.description = parkingPlace.description;
    parkingAnnotation.user_id = self.userInfo.user_id;
    parkingAnnotation.tag = 0;
    [map addAnnotation:parkingAnnotation];

}
-(void)fetchParkingLocations{
    NSLog(@"Fetching parking locations");
    
    [Communicator fetchParkingLocations:map.camera.centerCoordinate userId:self.userInfo.user_id latDelta:.01 lngDelta:.005 completion:^(NSDictionary* responseDict) {
        if (responseDict != nil){
            if ([responseDict objectForKey:@"success"]){
                [responseDict objectForKey:@"parking"];
                
                for (int i = 0; i < [[responseDict objectForKey:@"parking"] count]; i++){
                    ParkingSession* session = [[ParkingSession alloc]initWithPSDictionary:[[responseDict objectForKey:@"parking"]objectAtIndex:i]];
                    NSLog(@"Location: %f,%f",session.parking_location.latitude,session.parking_location.longitude);
                    Place* parkingPlace = [[Place alloc]initWithLatitude:session.parking_location.latitude longitude:session.parking_location.longitude];
                    parkingPlace.name = [NSString stringWithFormat:@"LEAVING IN"];
                    parkingPlace.description = [NSString stringWithFormat:@"%d SECONDS",(int)session.distance_from_car];
                    MapAnnotation* parkingAnnotation = [[MapAnnotation alloc]initWithPlace:parkingPlace];
                    parkingAnnotation.title = parkingPlace.name;
                    parkingAnnotation.image = [Utils drawCircle:session.distance_from_car status:session.status];
                    parkingAnnotation.description = parkingPlace.description;
                    parkingAnnotation.user_id = session.user_id;
                    parkingAnnotation.tag = pinTag;
                    if (session.status == -1){
                        //if user was 50 meters or more away from car when he unparked, we don't show an empty spot:
                        if (([[NSDate date] timeIntervalSince1970] * (long)1000) - session.timestamp < 30000 && session.distance_from_car < 50){
                            parkingPlace.name = @"DRIVER LEFT";
                            parkingPlace.description = @"(open space)";
                            [map addAnnotation:parkingAnnotation];
                        }
                    }else{
                        
                        [map addAnnotation:parkingAnnotation];
                        if ([selectedAnnotationId isEqualToString:session.user_id]){
                            [map selectAnnotation:parkingAnnotation animated:NO];
                            [currentAnnotations removeAllObjects];
                        }
                    }
                }
                if ([[responseDict objectForKey:@"parking"] count] > 0){
                    pinTag++;
                    NSLog(@"Parking found: %d",pinTag);
                    for (int i = 0; i < map.annotations.count; i++){
                        if (![[map.annotations[i] title] isEqualToString:@"My Location"]
                            && ([(MapAnnotation*)map.annotations[i] tag] == pinTag - 2 || [(MapAnnotation*)map.annotations[i] tag] == -1 * (pinTag - 2))){
                            
                            [map removeAnnotation:map.annotations[i]];
                            
                        }
                    }
                }
                
              
                NSLog(@"map: %d",(int)map.annotations.count);


            }else{
                NSLog(@"Failed to fetch parking locations");
            }
        }else{
             NSLog(@"Failed to fetch parking locations");
        }
    }];
    
    //For Testing:
//    ParkingSession* currentSession = [[ParkingSession alloc]init];
//    currentSession.parking_location = CLLocationCoordinate2DMake(37.13283999999999, -95.78558000000004);
//    currentSession.speed = 0;
//    currentSession.user_location = CLLocationCoordinate2DMake(37.13283999999999, -95.78558000000004);
//    currentSession.status = 1;
//    currentSession.user_id = @"5oYQ5EYLEU";
//    currentSession.distance_from_car = 0;
//    currentSession.time_from_car = 0;
//
//    locationCount++;
//    if (locationCount == 3){
//        locationCount = 0;
//        [Communicator reportStatus:currentSession completion:^(BOOL success, BOOL message_exists, NSString *message) {
//            if (!success){
//                NSLog(@"Failed to update status: %@",message);
//            }
//        }];
//    }
}
-(void)loginControllerDidLogIn:(UserInfo *)userInfo{
    NSLog(@"loginControllerDidLogIn");
    self.userInfo = [[UserInfo alloc]initWithUserInfo:userInfo];
    self.userInfo.current_session.status = UNASSIGNED;
    userInfo.current_session.status = [[[NSUserDefaults standardUserDefaults] objectForKey:@"status"]intValue];

    NSLog(@"status???: %d",self.userInfo.current_session.status);

}

-(void)viewDidAppear:(BOOL)animated{
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self setUpView];

}
-(void)setUpView{
    NSLog(@"Logged in? %d",self.userInfo.loggedIn);
    //For Testing:
//    self.userInfo.loggedIn = YES;
    if (!self.userInfo.loggedIn){
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"username"] != nil && [[NSUserDefaults standardUserDefaults]objectForKey:@"password"] != nil){
            [Communicator logInWithUsername:[[NSUserDefaults standardUserDefaults]objectForKey:@"username"]  password:[[NSUserDefaults standardUserDefaults]objectForKey:@"password"]  completion:^(NSDictionary* responseDict, BOOL success) {
                if (success){
                    NSLog(@"Logged IN");
                    NSLog(@"responseDict: %@",responseDict);
                    self.userInfo = [[UserInfo alloc]initWithDictionary:[responseDict objectForKey:@"userInfo"]];
                    self.userInfo.loggedIn = YES;
                    self.userInfo.current_session.status = UNASSIGNED;
                    userInfo.current_session.status = [[[NSUserDefaults standardUserDefaults] objectForKey:@"status"]intValue];

                    [self start];
                    
                    if (timer != nil){
                        [timer invalidate];
                        timer = nil;
                    }
                    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fetchParkingLocations) userInfo:nil repeats:YES];
                    NSLog(@"Location manager: ");

                    //Do something
                }else{
                    LoginController* lc = [[LoginController alloc]init];
                    if (!lc.isBeingPresented){
                        NSLog(@"Presenting LC");
                        lc.delegate = self;
                        [self presentViewController:lc animated:NO completion:nil];
                    }
                }
            }];
        }else{
            LoginController* lc = [[LoginController alloc]init];
            if (!lc.isBeingPresented){
                NSLog(@"Presenting LC");
                lc.delegate = self;
                [self presentViewController:lc animated:NO completion:nil];
            }
        }
        
    }else{
      
        [self start];
        
        if (timer != nil){
            [timer invalidate];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fetchParkingLocations) userInfo:nil repeats:YES];
        NSLog(@"Location manager: ");
    }
    NSLog(@"setUpView status: %d",self.userInfo.current_session.status);

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
            self.userInfo.current_session.status = NOT_MOVING;
        }
        return;
    }
    badSignalCount = 0;
    int status = [Algorithms determineStatus:locations[locations.count - 1] userInfo:self.userInfo];
    
    NSLog(@"status: %d",status);
   
    
    if (carLocation.latitude != self.userInfo.current_session.parking_location.latitude
        && carLocation.longitude != self.userInfo.current_session.parking_location.longitude){
        [map removeAnnotations:map.annotations];
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//        [annotation setCoordinate:self.userInfo.current_session.parking_location];
//        [annotation setTitle:@"Car"]; //You can set the subtitle too
//        [map addAnnotation:annotation];

//        Place* parkingPlace = [[Place alloc]initWithLatitude:carLocation.latitude longitude:carLocation.longitude];
//        parkingPlace.name = [NSString stringWithFormat:@"YOU PARKED HERE"];
//        parkingPlace.description = @"description";
//        MapAnnotation* parkingAnnotation = [[MapAnnotation alloc]initWithPlace:parkingPlace];
//        parkingAnnotation.title = parkingPlace.name;
//        parkingAnnotation.image = [Utils drawCircle:self.userInfo.current_session.distance_from_car];
//        parkingAnnotation.description = @"description";
//        [map addAnnotation:parkingAnnotation];
        
        MKMapCamera *newCamera = [MKMapCamera camera];
        [newCamera setCenterCoordinate:self.userInfo.current_session.parking_location];
        [map setCamera:newCamera];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithDouble:self.userInfo.current_session.parking_location.latitude] forKey:@"parking_location_lat"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithDouble:self.userInfo.current_session.parking_location.longitude] forKey:@"parking_location_lng"];
        [self addMyParkingLocation];
        [self checkIfLocationIsValid:self.userInfo.current_session.parking_location];
        
        
        
    }
    
    carLocation = self.userInfo.current_session.parking_location;

    ParkingSession* currentSession = [[ParkingSession alloc]init];
    currentSession.parking_location = carLocation;
    currentSession.speed = locations[locations.count - 1].speed;
    currentSession.user_location = locations[locations.count - 1].coordinate;
    currentSession.status = status;
    currentSession.user_id = self.userInfo.user_id;
    CLLocation* car = [[CLLocation alloc]initWithLatitude:carLocation.latitude longitude:carLocation.longitude];
    
    if (status == -1){
        //We remember the distance between the user and the car when the user unparked. This help determine if user indeed unparked or not and if we should hold the spot as 'free' for 30 seconds.
        CLLocation* lastSignificantLocation = [[CLLocation alloc]initWithLatitude:self.userInfo.current_session.last_significan_location.latitude longitude:self.userInfo.current_session.last_significan_location.longitude];
        CLLocation* lastParkedLocation = [[CLLocation alloc]initWithLatitude:self.userInfo.current_session.parking_location.latitude longitude:self.userInfo.current_session.parking_location.longitude];
        currentSession.distance_from_car = [lastParkedLocation distanceFromLocation:lastSignificantLocation];
    }else{
        currentSession.distance_from_car = [locations[locations.count - 1] distanceFromLocation:car];
    }
    currentSession.time_from_car = currentSession.distance_from_car;
   
    locationCount++;
    if (locationCount == 3){
        locationCount = 0;
        [Communicator reportStatus:currentSession completion:^(BOOL success, BOOL message_exists, NSString *message) {
            if (!success){
                NSLog(@"Failed to update status: %@",message);
            }
        }];
    }

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
-(void)slideMenuDidRemoveWithSelection:(NSInteger)selection{
    
}
-(void)slideMenuDidRemoveWithTask:(NSInteger)task loggedIn:(BOOL)loggedIn{
    
}

-(void)sidePanDetected:(UIScreenEdgePanGestureRecognizer*)pan{
    NSLog(@"opening menu");
    SlideMenu* menu = nil;
    if (pan.state == UIGestureRecognizerStateBegan) {
        map.scrollEnabled = NO;
        map.scrollEnabled = YES;
        BOOL slideViewOpened = NO;
        for (UIView* view in [self.view subviews]){
            if ([view isKindOfClass:[SlideMenu class]]){
                slideViewOpened = YES;
                break;
            }
        }
        if (!slideViewOpened){
            menu = [[SlideMenu alloc]initWithFrame:self.view.frame userInfo:nil loggedIn:NO expand:NO];
            menu.delegate = self;
            [menu adjustFrameForGesture:pan];
            [self.view addSubview:menu];
        }
        
    }else{
        if ([[[self.view subviews]lastObject] isKindOfClass:[SlideMenu class]]){
            menu = (SlideMenu*)[[self.view subviews]lastObject];
            [menu adjustFrameForGesture:pan];
        }
    }
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)otherGestureRecognizer{
    return YES;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation.title isEqualToString:@"My Location"]){
        return nil;
    }
    NSLog(@"Adding hash: %lu",annotation.hash);
    NSLog(@"use id?: %@",[(MapAnnotation*)annotation user_id]);

   
    [currentAnnotations setObject:(MapAnnotation*)annotation forKey:[NSNumber numberWithUnsignedInteger:annotation.hash]];

    if ([(MapAnnotation*)annotation tag] == 0){
        MKAnnotationView* pinForRoute = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinForRoute"];
        pinForRoute.tag = [(MapAnnotation*)annotation tag];
        pinForRoute.image = [(MapAnnotation*)annotation image];
        pinForRoute.frame = CGRectMake(0, 0, 30, 30);
        [map addAnnotation:pinForRoute.annotation];
        pinForRoute.canShowCallout = YES;

        return pinForRoute;
    }else{
        MKAnnotationView* pinViewNormal = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinViewNormal"];
        pinViewNormal.image = [(MapAnnotation*)annotation image];
        pinViewNormal.tag = [(MapAnnotation*)annotation tag];
        pinViewNormal.center = CGPointMake(pinViewNormal.frame.origin.x,pinViewNormal.frame.origin.y);
        if (pinViewNormal.tag > 0){
            if ([annotation.title containsString:@"LEAVING IN"]){
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                rightButton.tag = 1;
                rightButton.frame = CGRectMake(0, 0, 30, 30);
                [rightButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
                pinViewNormal.rightCalloutAccessoryView = rightButton;
            }else if ([annotation.title containsString:@"DRIVER NOT MOVING"]){
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                pinViewNormal.rightCalloutAccessoryView = rightButton;
            }
        }
        

        pinViewNormal.canShowCallout = YES;
        return pinViewNormal;
    }
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"Retrieving hash: %lu currentAnnotations: %d",view.annotation.hash,(int)currentAnnotations.count);

    NSString* userId = [[currentAnnotations objectForKey:[NSNumber numberWithUnsignedInteger:view.annotation.hash]] user_id];
    NSLog(@"USER ID: %@",userId);
    selectedAnnotationId = userId;
}
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    selectedAnnotationId = @"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if (control.tag == 1){
        NSLog(@"WILL NAVIGATE");
    }else{
        NSLog(@"WILL ASK A QUESTION");
    }
}

-(void)locate{
    MKMapCamera *newCamera = [MKMapCamera camera];
    [newCamera setCenterCoordinate:map.userLocation.coordinate];
    [map setCamera:newCamera];
}
@end
