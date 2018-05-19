//
//  Constants.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "Constants.h"
#define domainURL @"parkoutapp.us-west-1.elasticbeanstalk.com"
#define wifihost @"192.168.0.115:8080/api"
#define localhost @"localhost:8080/api"

#define baseURL @"http://"domainURL@"/parkout/functions/"

int const UNASSIGNED = 0;
int const NOT_PARKED = -1;
int const PARKING = 1;
int const PARKED_MOVING_AWAY = 2;
int const PARKED_NOT_IN_RADIUS = 3;
int const PARKED_COMING_BACK = 4;
int const UNPARKING = 5;
int const NOT_MOVING = 6;

int const FACTOR = 3;
float const DISTANCE_DELTA = 0.00015;
float const IN_RADIUS = 0.002;
float const MAX_RADIUS = 0.06;

float const MAX_WALKING_DISTANCE = 160;

float const DRIVING_SPEED = 6;
float const RUNNING_SPEED = 4;

NSString *const LogIn = baseURL@"LogIn";
NSString *const ValidateRegistrationToken = baseURL@"ValidateRegistrationToken";
NSString *const RegisterUser = baseURL@"RegisterUser";
NSString *const ResendEmail = baseURL@"ResendEmail";
NSString *const ChangePassword = baseURL@"ChangePassword";
NSString *const RecoverPassword = baseURL@"RecoverPassword";
NSString *const UpdateStatus = baseURL@"UpdateStatus";
NSString *const FetchParkingLocations = baseURL@"FetchParkingLocations";
NSString *const PostNotification = baseURL@"PostNotification";
NSString *const UpdateDeviceToken = baseURL@"UpdateDeviceToken";

