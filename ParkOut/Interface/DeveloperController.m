//
//  DeveloperController.m
//  ParkOut
//
//  Created by Leonid on 5/9/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "DeveloperController.h"

@interface DeveloperController ()

@end

@implementation DeveloperController


-(id)initWithUserInfo:(UserInfo*)_userInfo{
    self = [super init];
    if (self){
        userInfo = _userInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    // Do any additional setup after loading the view.
    
    UILabel* bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.frame.size.width, 70)];
    bottomLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomLabel];
    
    UIButton *dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    dismiss.frame = CGRectMake(14, self.view.frame.size.height-54, 80, 38);
    [dismiss setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dismiss setTitle:@"Go Back" forState:UIControlStateNormal];
    dismiss.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
    [dismiss addTarget:self action:@selector(dismissThisController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:dismiss];
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateLocation:(CLLocation*)location{
    if (location == nil){
        return;
    }
    NSLog(@"horizontalAccuracy: %f",[location horizontalAccuracy]);
    if ([location horizontalAccuracy] > 20){
        badSignalCount++;
        if (badSignalCount == 30){
            userInfo.current_session.status = NOT_MOVING;
        }
        return;
    }
    badSignalCount = 0;
   
    
    infoLabel.text = [NSString stringWithFormat:@"Speed: %.2f\n Number of Points: %d\n on_feet: %d",location.speed,
                      (int)userInfo.current_session.user_locations.count,userInfo.current_session.on_feet];
    
    if (userInfo.current_session.status == -1){
        statusValue.text = @"NOT_PARKED";
    }else if (userInfo.current_session.status == 1){
        statusValue.text = @"PARKING";
    }else if (userInfo.current_session.status == 2){
        statusValue.text = @"PARKED_MOVING_AWAY";
    }else if (userInfo.current_session.status == 3){
        statusValue.text = @"PARKED_NOT_IN_RADIUS";
    }else if (userInfo.current_session.status == 4){
        statusValue.text = @"PARKED_COMING_BACK";
    }else if (userInfo.current_session.status == 5){
        statusValue.text = @"UNPARKING";
    }else if (userInfo.current_session.status == 6){
        statusValue.text = @"NOT_MOVING";
    }else if (userInfo.current_session.status == 0){
        statusValue.text = @"UNASSIGNED";
    }
    tv.text = userInfo.log;
        NSLog(@"LOG: %@",userInfo.log);
    
}
-(void)dismissThisController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
