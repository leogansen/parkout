//
//  ManageUserController.h
//  ParkOut
//
//  Created by Leonid on 4/29/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "Constants.h"
#import "Color.h"
#import "CustomPickerView.h"

@protocol ManageUserControllerDelegate <NSObject>

-(void)manageUserControllerDidCancel;
-(void)manageUserControllerDidRegisterUser:(UserInfo*)userInfo;
-(void)manageUserControllerDidUpdatePassword:(UserInfo*)userInfo;

@end
@interface ManageUserController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UIPickerViewDelegate,CustomPickerViewDelegate>{
    UITextField* usernameField;
    UITextField* passwordField;
    UITextField* reenterPasswordField;
    UITextField* emailField;
    UITextField* title;
    UITextField* firstName;
    UITextField* middleName;
    UITextField* lastName;
    UITextField* suffix;
    UITextField* vehicleMake;
    UIActivityIndicatorView *activity;
    UIScrollView* scroll;
    BOOL passwordsMatch;
    UserInfo* userInfo;
    BOOL newUser;
    CustomPickerView* customPicker;
    
}
@property (strong, nonatomic) UserInfo* userInfo;
@property (assign, nonatomic) id <ManageUserControllerDelegate> delegate;
//@property (retain, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) NSArray* vehicleMakes;
-(id)initWithUserInfo:(UserInfo*)_userInfo;

@end
