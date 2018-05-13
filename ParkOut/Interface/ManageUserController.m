//
//  ManageUserController.m
//  ParkOut
//
//  Created by Leonid on 4/29/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "ManageUserController.h"

@interface ManageUserController ()


@end

@implementation ManageUserController
@synthesize userInfo,delegate,vehicleMakes;

-(id)initWithUserInfo:(UserInfo*)_userInfo{
    self = [super init];
    if (self){
        self.vehicleMakes = @[@"<not set>",@"Alfa Romeo",@"Alpina",@"Aston Martin",@"Audi",@"Bentley",@"BMW",@"Citroen",@"Dacia",@"DS",@"Ferrari",@"Fiat",@"Ford",@"Honda",@"Hyundai",@"Infiniti",@"Jaguar",@"Jeep",@"Kia",@"Lamborghini",@"Land Rover",@"Lexus",@"Lotus",@"Maserati",@"Mazda",@"McLaren",@"Mercedes",@"MG",@"Mini",@"Mitsubishi",@"Nissan",@"Peugeot",@"Porsche",@"Renault",@"Rolls-Royce",@"Seat",@"Skoda",@"Smart",@"SsangYong",@"Subaru",@"Suzuki",@"Tesla",@"Toyota",@"Vauxhall",@"Volkswagen",@"Volvo"];
        self.userInfo = _userInfo;
        
        [self setupView];
        NSString* buttonTitle = @"Register";
        if (self.userInfo.user_id != NULL && ![self.userInfo.user_id isEqualToString:@""]){
            usernameField.text = _userInfo.username;
            passwordField.text = _userInfo.password;
            reenterPasswordField.text = _userInfo.password;
            emailField.text = _userInfo.email_address;
            firstName.text = _userInfo.first_name;
            lastName.text = _userInfo.last_name;
            title.text = _userInfo.title;
            suffix.text = _userInfo.suffix;
            middleName.text = _userInfo.middle_name;
            vehicleMake.text = _userInfo.vehicle_make;
            
            buttonTitle = @"Update";
            newUser = false;
        }else{
            newUser = true;
        }
        UIButton* registerUser = [UIButton buttonWithType:UIButtonTypeCustom];
        [registerUser setTitle:buttonTitle forState:UIControlStateNormal];
        registerUser.frame = CGRectMake(self.view.frame.size.width - 90, self.view.frame.size.height - 60, 80, 50);
        registerUser.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
        [registerUser setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [registerUser addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:registerUser];
        
        customPicker = [[CustomPickerView alloc]initWithArray:self.vehicleMakes frame:CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200)];
        customPicker.delegate = self;
        customPicker.hidden = YES;
        [self.view addSubview:customPicker];
        
    }
    return self;
}
-(void)setupView{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 70)];
    scroll.backgroundColor = [UIColor whiteColor];
    scroll.delegate = self;
    
    if (!self.userInfo.loggedIn){
        UILabel* usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, self.view.frame.size.width - 20, 40)];
        usernameLabel.text = @"Create Account";
        usernameLabel.textAlignment = NSTextAlignmentCenter;
        usernameLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
        [scroll addSubview:usernameLabel];
        
        usernameField = [[UITextField alloc]initWithFrame:CGRectMake(10, usernameLabel.frame.origin.y +  usernameLabel.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
        usernameField.tag = 1;
        usernameField.delegate = self;
        usernameField.placeholder = @"*Username";
        usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
        usernameField.clearButtonMode = YES;
        usernameField.borderStyle = UITextBorderStyleRoundedRect;
        [scroll addSubview:usernameField];
    }
    
    CGRect rect = usernameField.frame;
    if (self.userInfo.loggedIn){
        rect = CGRectMake(10, usernameField.frame.origin.y +  usernameField.frame.size.height + 20, self.view.frame.size.width - 20, 40);

        UILabel* passwordLabel = [[UILabel alloc]initWithFrame:rect];
        passwordLabel.text = @"";
        passwordLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
        [scroll addSubview:passwordLabel];

        UIButton* changePassword = [UIButton buttonWithType:UIButtonTypeCustom];
        changePassword.frame = CGRectMake(self.view.frame.size.width - 120, passwordLabel.frame.origin.y, 110,passwordLabel.frame.size.height);
        [changePassword setTitle:@"Change" forState:UIControlStateNormal];
        [changePassword setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        changePassword.titleLabel.font = [UIFont fontWithName:@"GillSans-BoldItalic" size:16];
        [changePassword addTarget:self action:@selector(setNewPassword) forControlEvents:UIControlEventTouchDown];
        [scroll addSubview:changePassword];
    }
    
    passwordField = [[UITextField alloc]initWithFrame:CGRectMake(10, rect.origin.y +  rect.size.height + 10, self.view.frame.size.width - 20, 40)];
    passwordField.tag = 2;
    passwordField.placeholder = @"*Password";
    passwordField.delegate = self;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.clearButtonMode = YES;
    passwordField.secureTextEntry = YES;
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:passwordField];
 
    
    reenterPasswordField = [[UITextField alloc]initWithFrame:CGRectMake(10, passwordField.frame.origin.y +  passwordField.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    reenterPasswordField.tag = 3;
    reenterPasswordField.placeholder = @"*Re-enter password";
    reenterPasswordField.delegate = self;
    reenterPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    reenterPasswordField.clearButtonMode = YES;
    reenterPasswordField.secureTextEntry = YES;
    reenterPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:reenterPasswordField];
    
   
    
    emailField = [[UITextField alloc]initWithFrame:CGRectMake(10, reenterPasswordField.frame.origin.y +  reenterPasswordField.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    emailField.tag = 4;
    emailField.placeholder = @"*Email Address";
    emailField.delegate = self;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.clearButtonMode = YES;
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:emailField];
    
   
    
    title = [[UITextField alloc]initWithFrame:CGRectMake(10, emailField.frame.origin.y +  emailField.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    title.tag = 5;
    title.placeholder = @"Title";
    title.delegate = self;
    title.autocorrectionType = UITextAutocorrectionTypeNo;
    title.clearButtonMode = YES;
    title.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:title];

    
    firstName = [[UITextField alloc]initWithFrame:CGRectMake(10, title.frame.origin.y +  title.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    firstName.tag = 6;
    firstName.placeholder = @"*First Name";
    firstName.delegate = self;
    firstName.autocorrectionType = UITextAutocorrectionTypeNo;
    firstName.clearButtonMode = YES;
    firstName.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:firstName];
    
  
    middleName = [[UITextField alloc]initWithFrame:CGRectMake(10, firstName.frame.origin.y +  firstName.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    middleName.tag = 7;
    middleName.placeholder = @"Middle Name";
    middleName.delegate = self;
    middleName.autocorrectionType = UITextAutocorrectionTypeNo;
    middleName.clearButtonMode = YES;
    middleName.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:middleName];
    
    lastName = [[UITextField alloc]initWithFrame:CGRectMake(10, middleName.frame.origin.y +  middleName.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    lastName.tag = 8;
    lastName.placeholder = @"*Last Name";
    lastName.delegate = self;
    lastName.autocorrectionType = UITextAutocorrectionTypeNo;
    lastName.clearButtonMode = YES;
    lastName.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:lastName];
    
    
    suffix = [[UITextField alloc]initWithFrame:CGRectMake(10, lastName.frame.origin.y +  lastName.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    suffix.tag = 9;
    suffix.placeholder = @"Suffix";
    suffix.delegate = self;
    suffix.autocorrectionType = UITextAutocorrectionTypeNo;
    suffix.clearButtonMode = YES;
    suffix.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:suffix];
    
    
    vehicleMake = [[UITextField alloc]initWithFrame:CGRectMake(10, suffix.frame.origin.y +  suffix.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    vehicleMake.tag = 10;
    vehicleMake.placeholder = @"Vehicle Make";
    vehicleMake.delegate = self;
    vehicleMake.autocorrectionType = UITextAutocorrectionTypeNo;
    vehicleMake.clearButtonMode = YES;
    vehicleMake.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:vehicleMake];
    
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in scroll.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    contentRect = CGRectUnion(contentRect, CGRectMake(0, contentRect.size.height, self.view.frame.size.width, 160));
    scroll.contentSize = contentRect.size;
    
    [self.view addSubview:scroll];
    
    
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
    
    //Activity indicator
    activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 25, self.view.frame.size.height / 2 - 25, 50, 50)];
    [activity startAnimating];
    activity.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [activity setColor:[UIColor darkTextColor]];
 
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePicker)];
    [self.view addGestureRecognizer:tap];
    
}
-(void)hidePicker{
    customPicker.hidden = YES;
    
}

-(void)customPickerViewDidSelectRow:(NSInteger)row{
    if (row == 0){
        vehicleMake.text = @"";
    }else{
        vehicleMake.text = self.vehicleMakes[row];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row == 0){
        vehicleMake.text = @"";
    }else{
        vehicleMake.text = self.vehicleMakes[row];
    }
}


-(void)dismissThisController{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(manageUserControllerDidCancel)]){
            [self.delegate manageUserControllerDidCancel];
        }
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)registerUser{
    
    [lastName resignFirstResponder];
    [self registerUserWithCompletion:^void(BOOL success, NSString * message) {
        if (success){
            if ([self.delegate respondsToSelector:@selector(manageUserControllerDidRegisterUser:)]){
                [self.delegate manageUserControllerDidRegisterUser:self.userInfo];
            }
            if (!newUser){
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Successfully Updated User!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag = -12;
                [alert show];
            }else{
                [self dismissViewControllerAnimated:YES completion:^{
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Successfully Registered User!" message:@"You will now receive an email with a link to activate your account. Please open that link. After that, you would be able to login, manage your plans and more." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    alert.tag = -13;
                    [alert show];
                }];
            }
        }else{
            NSString* title = @"Something went wrong...";
            if (message != nil){
                title = message;
            }
            [self simpleAlertViewTitle:title message:@"Couldn't register user/update user information. Please try again."];
        }
        
    }];
}
-(void)setNewPassword{
    UIAlertView* textEntryAlert= [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Please enter your current password and the new password"] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    textEntryAlert.tag = -11;
    textEntryAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[textEntryAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [[textEntryAlert textFieldAtIndex:0] setPlaceholder:@"Current Password"];
    [[textEntryAlert textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeDefault];
    [[textEntryAlert textFieldAtIndex:1] setPlaceholder:@"New Password"];
    [textEntryAlert show];
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"Alert View Tag: %ld",(long)alertView.tag);
    if (alertView.tag == -11 && buttonIndex == 1){
        NSString* oldPassword = [alertView textFieldAtIndex:0].text;
        NSString* newPassword = [alertView textFieldAtIndex:1].text;
        NSLog(@"oldPassword: %@ newPassword: %@",oldPassword,newPassword);
        [self updatePasswordWithOldPassword:oldPassword newPassword:newPassword completion:^void(BOOL success, BOOL messageExists, NSString* message) {
            if (success){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [activity removeFromSuperview];
                    [self simpleAlertViewTitle:@"Password Updated Successfully. Please log in with the new password to continue." message:nil];
                });
                if ([self.delegate respondsToSelector:@selector(manageUserControllerDidUpdatePassword:)]){
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self.delegate manageUserControllerDidUpdatePassword:self.userInfo];
                    }];
                }
            }else{
                if (messageExists){
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [activity removeFromSuperview];
                        [self simpleAlertViewTitle:@"Failed to update password" message:message];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [activity removeFromSuperview];
                        [self simpleAlertViewTitle:@"Failed to update password. Please check that the current password was entered correctly." message:nil];
                    });
                }
            }
            
        }];
    }
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"TAG: %ld",(long)textField.tag);
    
    if (textField.tag == 1)
        self.userInfo.username = textField.text;
    if (textField.tag == 2)
        self.userInfo.password = textField.text;
    NSLog(@"-1: %@ 2: %@", textField.text,self.userInfo.password);
    if (textField.tag == 3){
        if (textField.text != NULL && [textField.text isEqualToString:self.userInfo.password]){
            passwordsMatch = YES;
        }else{
            passwordField.text = @"";
            reenterPasswordField.text = @"";
            [self simpleAlertViewTitle:@"Passwords don't match!" message:@"Please re-enter password"];
        }
    }
    if (textField.tag == 4)
        self.userInfo.email_address = textField.text;
    if (textField.tag == 5)
        self.userInfo.title = textField.text;
    if (textField.tag == 6)
        self.userInfo.first_name = textField.text;
    if (textField.tag == 7)
        self.userInfo.middle_name = textField.text;
    if (textField.tag == 8)
        self.userInfo.last_name = textField.text;
    if (textField.tag == 9)
        self.userInfo.suffix = textField.text;
//    if (textField.tag == 10)
//        self.userInfo.vehicle_make = textField.text;
    [textField resignFirstResponder];
    
}

-(void)customPickerShouldClose{
    [self hidePicker];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 10){
        if (customPicker.hidden){
            [scroll scrollRectToVisible:CGRectMake(0, textField.frame.origin.y, textField.frame.size.width, textField.frame.size.height) animated:YES];
            customPicker.hidden = NO;
            NSLog(@"Showing picker");
        }else{
            customPicker.hidden = YES;
        }
        return NO;
    }else{
        customPicker.hidden = YES;
        return YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"editing");

    [scroll scrollRectToVisible:CGRectMake(0, textField.frame.origin.y + textField.frame.size.height + 240, textField.frame.size.width, textField.frame.size.height) animated:YES];

}


- (void)registerUserWithCompletion:(void (^)(BOOL,NSString*))completion{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.view addSubview:activity];
    });
    self.userInfo.vehicle_make = vehicleMake.text;
    
    if (self.userInfo.password.length >= 5 && self.userInfo.username.length > 0 && (self.userInfo.email_address.length > 3 && [self.userInfo.email_address containsString:@"@"])){
        
        if ([self.userInfo.username containsString:@" "]){
            [self simpleAlertViewTitle:@"A username cannot contain spaces" message:@""];
            return;
        }
        if ([self.userInfo.password containsString:@" "]){
            [self simpleAlertViewTitle:@"A password cannot contain spaces" message:@""];
            return;
        }
        NSMutableDictionary* requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userInfo.userinfo_dictionary,@"userInfo",nil];
        [requestDict setObject:self.userInfo.token forKey:@"token"];
        NSError* jsonerror;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:requestDict
                                                           options:NSJSONWritingPrettyPrinted error:&jsonerror];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            
            NSString *strData = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"strData: %@",strData);
            NSURL *url = [NSURL URLWithString:RegisterUser];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:jsonData];
            [request setTimeoutInterval:20];
            NSError* error = nil;
            NSURLResponse *response =[[NSURLResponse alloc]init];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSError *jsonParsingError = nil;
            NSString* message = @"";
            NSDictionary *dictionary;
            if (data != nil){
                
                dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                if (dictionary != nil){
                    NSLog(@"Register User Dict: %@",dictionary);
                    if ([[dictionary objectForKey:@"userInfo"] objectForKey:@"user_id"] != [NSNull null] && ![[[dictionary objectForKey:@"userInfo"] objectForKey:@"user_id"] isEqualToString:@""]){
                        self.userInfo.user_id = [[dictionary objectForKey:@"userInfo"] objectForKey:@"user_id"];
                        NSLog(@"Successfully registered user");
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [activity removeFromSuperview];
                            completion(YES,nil);
                        });
                    }else if ([dictionary objectForKey:@"message"] != [NSNull null]  && ![[dictionary objectForKey:@"message"] isEqualToString:@""]){
                        message = [dictionary objectForKey:@"message"];
                        NSLog(@"User already exists");
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [activity removeFromSuperview];
                            completion(NO,message);
                        });
                    }else{
                        message = [dictionary objectForKey:@"message"];
                        NSLog(@"Message: %@",[dictionary objectForKey:@"message"]);
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [activity removeFromSuperview];
                            completion(NO,@"Oups, an error occured");
                        });
                    }
                }else{
                    NSLog(@"Dictionary is NULL");
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [activity removeFromSuperview];
                        completion(NO,nil);
                    });
                }
            }else{
                NSLog(@"DATA is NULL");
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [activity removeFromSuperview];
                    completion(NO,nil);
                });
            }
        });
    }else if (self.userInfo.password.length < 5){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [activity removeFromSuperview];
            [self simpleAlertViewTitle:@"Password is too short" message:@"Please enter password with 5 characters or longer"];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [activity removeFromSuperview];
            [self simpleAlertViewTitle:@"Please fill out the required fields!" message:@"One or more fields are not completely filled out."];
        });
    }
}
- (void)updatePasswordWithOldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword completion:(void (^)(BOOL,BOOL,NSString*))completion{
    if (newPassword.length >= 5){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.view addSubview:activity];
        });
        
        self.userInfo.password = oldPassword;
        NSMutableDictionary* cpDictionary = [NSMutableDictionary dictionaryWithDictionary:self.userInfo.userinfo_dictionary];
        [cpDictionary setObject:newPassword forKey:@"new_password"];
        [cpDictionary setObject:self.userInfo.token forKey:@"token"];
        NSError* jsonerror;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:cpDictionary
                                                           options:NSJSONWritingPrettyPrinted error:&jsonerror];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            
            NSString *strData = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"strData to update p-word: %@",strData);
            NSURL *url = [NSURL URLWithString:ChangePassword];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:jsonData];
            [request setTimeoutInterval:20];
            NSError* error = nil;
            NSURLResponse *response =[[NSURLResponse alloc]init];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSError *jsonParsingError = nil;
            NSDictionary *dictionary;
            if (data != nil){
                NSLog(@"Register User Dict: %@",dictionary);
                
                dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                if (dictionary != NULL && [[dictionary objectForKey:@"success"]boolValue]){
                    if ([dictionary objectForKey:@"userInfo"] && [[dictionary objectForKey:@"userInfo"] objectForKey:@"password"]){
                        NSLog(@"Register User Dict: %@",[[dictionary objectForKey:@"userInfo"] objectForKey:@"password"]);
                        self.userInfo.password = [[dictionary objectForKey:@"userInfo"] objectForKey:@"password"];
                        completion(YES,NO,nil);
                    }
                }else{
                    completion(NO,YES,[dictionary objectForKey:@"message"]);
                }
                
                
            }else{
                completion(NO,YES,@"Error");
            }
        });
        
    }else{
        [self simpleAlertViewTitle:@"Password is too short" message:@"Please enter password with 5 characters or longer"];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
