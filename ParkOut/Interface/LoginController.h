//
//  LoginController.h
//  ParkOut
//
//  Created by Leonid on 4/30/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "SlideMenu.h"
#import "Communicator.h"
#import "InfoViewController.h"
#import "ManageUserController.h"

@protocol LoginControllerDelegate <NSObject>

-(void)loginControllerDidLogIn:(UserInfo*)userInfo;

@end

@interface LoginController : UIViewController<UITextFieldDelegate,SlideMenuDelegate,UIGestureRecognizerDelegate,ManageUserControllerDelegate>{
    UIScrollView* scroll;
    UITextField* username;
    UITextField* password;
    SlideMenu* slideMenu;
}

@property(assign,nonatomic) id <LoginControllerDelegate> delegate;

@property(strong,nonatomic) UserInfo* userInfo;

@end
