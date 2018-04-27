//
//  Constants.m
//  MotionDetector
//
//  Created by Leonid on 4/24/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "Constants.h"

int const UNASSIGNED = 0;
int const NOT_PARKED = -1;
int const PARKING = 1;
int const PARKED_MOVING_AWAY = 2;
int const PARKED_NOT_IN_RADIUS = 3;
int const PARKED_COMING_BACK = 4;
int const UNPARKING = 5;
int const NOT_MOVING = 6;

int const FACTOR = 3;
float const DISTANCE_DELTA = 0.0001;
float const IN_RADIUS = 0.002;
float const MAX_RADIUS = 0.06;
