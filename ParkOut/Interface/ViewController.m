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
        
//        userInfo.current_session.status = UNASSIGNED;
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
    
    
    //Search bar
    
    UILabel* grayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    search = [[UITextField alloc]initWithFrame:CGRectMake(50, 23, self.view.frame.size.width-100, 30)];
    search.delegate = self;
    search.placeholder = @"Search for an address";
    search.autocorrectionType=UITextAutocorrectionTypeNo;
    search.clearButtonMode = YES;
    search.borderStyle = UITextBorderStyleRoundedRect;

    grayLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:grayLabel];
    [self.view addSubview:search];
    
    UIButton* openMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openMenuButton.frame = CGRectMake(15, 27, 20, 20);
    [openMenuButton addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchDown];
    [openMenuButton setImage:[UIImage imageNamed:@"menu@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:openMenuButton];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapReceived:)];
    [map addGestureRecognizer:tap];
    
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
-(void)openMenu{
    SlideMenu* menu = nil;

    map.scrollEnabled = NO;
    map.scrollEnabled = YES;
    BOOL slideViewOpened = NO;
    for (UIView* view in [self.view subviews]){
        if ([view isKindOfClass:[SlideMenu class]]){
            slideViewOpened = YES;
            break;
        }
    }
    NSLog(@"Menu open? %d",slideViewOpened);
    if (!slideViewOpened){
        menu = [[SlideMenu alloc]initWithFrame:self.view.frame userInfo:self.userInfo loggedIn:self.userInfo.loggedIn expand:YES];
        menu.delegate = self;
        [self.view addSubview:menu];
    }
        
   
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
    
    [Communicator fetchParkingLocations:map.camera.centerCoordinate userId:self.userInfo.user_id latDelta:.05 lngDelta:.05 completion:^(NSDictionary* responseDict) {
        if (responseDict != nil){
            if ([responseDict objectForKey:@"success"]){
                [responseDict objectForKey:@"parking"];
                
                for (int i = 0; i < [[responseDict objectForKey:@"parking"] count]; i++){
                    ParkingSession* session = [[ParkingSession alloc]initWithPSDictionary:[[responseDict objectForKey:@"parking"]objectAtIndex:i]];
                    NSLog(@"Location: %f,%f",session.parking_location.latitude,session.parking_location.longitude);
                    Place* parkingPlace = [[Place alloc]initWithLatitude:session.parking_location.latitude longitude:session.parking_location.longitude];
                    if (session.status == 6){
                        parkingPlace.name = [NSString stringWithFormat:@"DRIVER NOT MOVING"];
                        
                        long leavingIn = ([[NSDate date] timeIntervalSince1970] * 1000 - session.departure_plan_timestamp);
                        NSLog(@"LEAVING IN: %ld",leavingIn);
                        NSLog(@"LEAVING IN: %ld",leavingIn/60000);

                        if (session.departing_in == -1){
                            
                        }else if (session.departing_in == 0 || [[NSDate date] timeIntervalSince1970] * 1000 - session.departure_plan_timestamp > session.departing_in * 60 * 1000){
                            parkingPlace.description = @"Ask the driver when they'd be leaving (tap)";
                        }else{
                            NSString* adjustment = @"";
                            if (session.departing_in > 20){
                                adjustment = @"over ";
                            }
                            long minutesLeft = session.departing_in - leavingIn/60000;
                            parkingPlace.description = [NSString stringWithFormat:@"Driver plans on leaving in %@%d minutes",adjustment,(int)minutesLeft];
                        }
                    }else{
                        parkingPlace.name = [NSString stringWithFormat:@"LEAVING IN"];
                        parkingPlace.description = [NSString stringWithFormat:@"%d SECONDS",(int)session.distance_from_car];
                    }
                    MapAnnotation* parkingAnnotation = [[MapAnnotation alloc]initWithPlace:parkingPlace];
                    parkingAnnotation.title = parkingPlace.name;
                    parkingAnnotation.image = [Utils drawCircle:session.distance_from_car status:session.status];
                    parkingAnnotation.description = parkingPlace.description;
                    parkingAnnotation.user_id = session.user_id;
                    parkingAnnotation.tag = pinTag;
                    parkingAnnotation.status = session.status;
                    parkingAnnotation.departing_in = session.departing_in;
                    if (session.status == -1){
                        //This is also handled by the algorithms, but just in case:
                        //if user was 50 meters or more away from car when he unparked, we don't show an empty spot:
                        if (session.parking_location.latitude != 0 &&
                            ([[NSDate date] timeIntervalSince1970] * (long)1000) - session.timestamp < 30000 && session.distance_from_car < 50){
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
    
  
}
-(void)loginControllerDidLogIn:(UserInfo *)userInfo{
    NSLog(@"loginControllerDidLogIn");
    self.userInfo = [[UserInfo alloc]initWithUserInfo:userInfo];
//    self.userInfo.current_session.status = NOT_PARKED;//
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
//                    self.userInfo.current_session.status = NOT_PARKED;//test
                    self.userInfo.current_session.status = [[[NSUserDefaults standardUserDefaults] objectForKey:@"status"]intValue];
                    CLLocationCoordinate2D prevParkingLoc =   CLLocationCoordinate2DMake([[[NSUserDefaults standardUserDefaults]objectForKey:@"parking_location_lat"]doubleValue], [[[NSUserDefaults standardUserDefaults]objectForKey:@"parking_location_lng"]doubleValue]);
                    
                    NSLog(@"CURRENT STATUS AT LOG IN: %d",self.userInfo.current_session.status);
                    userInfo.current_session.parking_location = prevParkingLoc;
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
    NSLog(@"horizontalAccuracy: %f speed: %f",[locations[locations.count - 1] horizontalAccuracy],[locations[locations.count - 1] speed]);
    if ([locations[locations.count - 1] horizontalAccuracy] > 60){
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
        
        MKCoordinateRegion region;
        region.center.latitude     = self.userInfo.current_session.parking_location.latitude;
        region.center.longitude    = self.userInfo.current_session.parking_location.longitude;
        region.span.latitudeDelta  = .01;
        region.span.longitudeDelta = .05;
        [map setRegion:region animated:YES];

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
    currentSession.departure_plan_timestamp = self.userInfo.current_session.departure_plan_timestamp;
    currentSession.departing_in = self.userInfo.current_session.departing_in;
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
    if (selection == 0 && self.userInfo.current_session.parking_location.latitude != 0){
        MKMapCamera *newCamera = [MKMapCamera camera];
        [newCamera setCenterCoordinate:self.userInfo.current_session.parking_location];
        [map setCamera:newCamera];
    }else if (selection == 1){
        //Update Status
        //Here, a user specifies his/her plans to unpark the car.
        if (self.userInfo.current_session.parking_location.latitude == 0){
            [self simpleAlertViewTitle:@"You don't seem to have parked yet!" message:@"For a parking spot to be generated in the system, you need to first drive a bit, then stop and start walking."];
        }else{
            [self departingInAlertViewTitle:@"Help other drivers find a spot - let them know when you plan on leaving your current parking spot!" message:@"Choose one:" tag:0];
        }
    }else if (selection == 2){
        InfoViewController* info = [[InfoViewController alloc]initWithTitle:@"About the ParkOut" andContent:[NSString stringWithFormat:@"ParkOut is a user-driven app in which users can see when other users are about to park out of their street parking spots, thus knowing a few minutes ahead of time that a particular parking spot would become available shortly. When users approaches their cars, the car icons on the map become progressively greener. Users cannot see each other's locations, only the locations of other users' cars. GPS location sharing is required use the app."] andUserId:@"" token:@"" enroll:NO dict:nil];
        [self presentViewController:info animated:YES completion:nil];
    }else if (selection == 3){
        //Update Info
        ManageUserController* muc = [[ManageUserController alloc]initWithUserInfo:self.userInfo];
        muc.delegate = self;
        [self presentViewController:muc animated:YES completion:nil];
    }else if (selection == 4){
        //Logout
        NSLog(@"Logout");
        self.userInfo = [[UserInfo alloc]init];
        LoginController* lc = [[LoginController alloc]init];
        if (!lc.isBeingPresented){
            NSLog(@"Presenting LC");
            lc.delegate = self;
            [self presentViewController:lc animated:NO completion:nil];
        }
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"username"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
        [timer invalidate];
        [self stop];
    }
}
-(void)slideMenuDidRemoveWithTask:(NSInteger)task loggedIn:(BOOL)loggedIn{
    if (loggedIn && task == 0){
        NSLog(@"Logout");
        self.userInfo = [[UserInfo alloc]init];
        LoginController* lc = [[LoginController alloc]init];
        if (!lc.isBeingPresented){
            NSLog(@"Presenting LC");
            lc.delegate = self;
            [self presentViewController:lc animated:NO completion:nil];
        }
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"username"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
        [timer invalidate];
        [self stop];
    }else if (loggedIn && task == 1){
        //Update Info
        ManageUserController* muc = [[ManageUserController alloc]initWithUserInfo:self.userInfo];
        muc.delegate = self;
        [self presentViewController:muc animated:YES completion:nil];
    }
}
-(void)manageUserControllerDidCancel{
    
}
-(void)manageUserControllerDidRegisterUser:(UserInfo *)userInfo{
    
}
-(void)manageUserControllerDidUpdatePassword:(UserInfo *)userInfo{
    
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
            menu = [[SlideMenu alloc]initWithFrame:self.view.frame userInfo:self.userInfo loggedIn:self.userInfo.loggedIn expand:NO];
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
            if ([(MapAnnotation*)annotation status] != 6){
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                rightButton.tag = 1;
                rightButton.frame = CGRectMake(0, 0, 30, 30);
                [rightButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
                pinViewNormal.rightCalloutAccessoryView = rightButton;
            }else{
                if ([(MapAnnotation*)annotation departing_in] == 0){
                    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                    pinViewNormal.rightCalloutAccessoryView = rightButton;
                }
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
    MKCoordinateRegion region;
    region.center.latitude     = map.userLocation.coordinate.latitude;
    region.center.longitude    = map.userLocation.coordinate.longitude;
    region.span.latitudeDelta  = .01;
    region.span.longitudeDelta = .05;
    [map setRegion:region animated:YES];

}
-(void)geocodeAddress:(NSString*)address completion:(void (^)(BOOL,NSError*,CLLocationCoordinate2D))completion
{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        
        CLPlacemark *placemark = placemarks[0];
        
        if (placemark.location.coordinate.latitude != 0 || placemark.location.coordinate.longitude != 0)
        {
            MKCoordinateRegion region;
            region.center.latitude     = placemark.location.coordinate.latitude;
            region.center.longitude    = placemark.location.coordinate.longitude;
            region.span.latitudeDelta  = .01;
            region.span.longitudeDelta = .0005;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [map setRegion:region animated:YES];
                completion(YES,error,placemark.location.coordinate);
            });
        }
    }];
}

-(void)tapReceived:(UITapGestureRecognizer*)recognizer{
    [search resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self geocodeAddress:textField.text completion:^(BOOL success, NSError *error, CLLocationCoordinate2D location) {
        
    }];
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];

}

- (void)departingInAlertViewTitle:(NSString*)title message:(NSString*)message tag:(int)tag
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* button5 = [UIAlertAction
                               actionWithTitle:@"In 5 minutes"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle your yes please button action here
                                   self.userInfo.current_session.departing_in = 5;
                                   NSLog(@"WTF: %d",self.userInfo.current_session.departing_in);
                                   self.userInfo.current_session.departure_plan_timestamp = [[NSDate date] timeIntervalSince1970] * (long)1000;
                                   [self simpleAlertViewTitle:@"Thank you!" message:@" You've set your plan to depart in 5 mins."];
                               }];
    
    [alert addAction:button5];
    
   
    
    UIAlertAction* button15 = [UIAlertAction
                              actionWithTitle:@"In 15 minutes"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  //Handle your yes please button action here
                                   self.userInfo.current_session.departing_in = 15;
                                  self.userInfo.current_session.departure_plan_timestamp = [[NSDate date] timeIntervalSince1970] * (long)1000;
                                  [self simpleAlertViewTitle:@"Thank you!" message:@" You've set your plan to depart in 15 mins."];

                              }];
    
    [alert addAction:button15];
  
    UIAlertAction* button20 = [UIAlertAction
                              actionWithTitle:@"In over 20 minutes"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  //Handle your yes please button action here
                                  self.userInfo.current_session.departing_in = 20;
                                  self.userInfo.current_session.departure_plan_timestamp = [[NSDate date] timeIntervalSince1970] * (long)1000;
                                  [self simpleAlertViewTitle:@"Thank you!" message:@" You've set your plan to depart in over 20 mins."];

                              }];
    
    [alert addAction:button20];
    
    UIAlertAction* cancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  //Handle your yes please button action here
                              }];
    
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)simpleAlertViewTitle:(NSString*)title message:(NSString*)message
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle your yes please button action here
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
