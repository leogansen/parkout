//
//  ErrorViewController.m
//  ParkOut
//
//  Created by Leonid Iogansen on 5/20/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "ErrorViewController.h"

@interface ErrorViewController ()

@end

@implementation ErrorViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    face = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
    face.text = @"🙁";
    face.textAlignment = NSTextAlignmentCenter;
    face.font = [UIFont fontWithName:face.font.fontName size:160];
    [self.view addSubview:face];
    
    info = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height / 2, self.view.frame.size.width - 20, self.view.frame.size.height / 2)];
    info.text = @"It seems that you have not authorized ParkOut to use your location always, so we can't proceed to activate the functionality of the app. To enable ParkOut to use your location, please go to Settings>ParkOut>Location>Always to enjoy the features of the app!";
    info.font = [UIFont fontWithName:@"Avenir" size:15];
    info.numberOfLines = 10;
    [self.view addSubview:info];
    
    UIButton* signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signOutButton.frame = CGRectMake(self.view.frame.size.width - 90, self.view.frame.size.height - 70, 80, 70);
    [signOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    signOutButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    [signOutButton setTitleColor:[Color appColorMedium2] forState:UIControlStateNormal];
    [signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:signOutButton];
    
    // Do any additional setup after loading the view.
}
-(void)signOut{
    if ([self.delegate respondsToSelector:@selector(errorControllerSignedOut)]){
        [self.delegate errorControllerSignedOut];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
