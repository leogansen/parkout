//
//  LoginController.m
//  ParkOut
//
//  Created by Leonid on 4/30/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "LoginController.h"

@interface LoginController ()

@end

@implementation LoginController
@synthesize userInfo,delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    userInfo = [[UserInfo alloc]init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50)];
    
    UILabel* titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 40)];
    titleLabel.text = @"Login or Register";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    [scroll addSubview:titleLabel];

    
    username = [[UITextField alloc]initWithFrame:CGRectMake(20, titleLabel.frame.origin.y + titleLabel.frame.size.height + 20, self.view.frame.size.width - 40, 30)];
    username.placeholder = @"Username";
    username.delegate = self;
    username.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:username];
    
    password = [[UITextField alloc]initWithFrame:CGRectMake(20, username.frame.origin.y + username.frame.size.height + 20, self.view.frame.size.width - 40, 30)];
    password.placeholder = @"Password";
    password.secureTextEntry = YES;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    password.delegate = self;
    password.borderStyle = UITextBorderStyleRoundedRect;
    [scroll addSubview:password];
    
    UIButton* login = [UIButton buttonWithType:UIButtonTypeCustom];
    login.frame = CGRectMake(20, password.frame.origin.y + password.frame.size.height + 20, self.view.frame.size.width - 40, 30);
    [login setTitle:@"Continue" forState:UIControlStateNormal];
    [login setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [login addTarget:self action:@selector(continueLogin) forControlEvents:UIControlEventTouchDown];
    [scroll addSubview:login];
    
    UIButton* forgotPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    forgotPassword.frame = CGRectMake(20, login.frame.origin.y + login.frame.size.height + 20, self.view.frame.size.width - 40, 30);
    [forgotPassword setTitle:@"Forgot Password" forState:UIControlStateNormal];
    [forgotPassword.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:12]];
    [forgotPassword setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [forgotPassword addTarget:self action:@selector(recoverPassword) forControlEvents:UIControlEventTouchDown];
    [scroll addSubview:forgotPassword];
   
    UIButton* createAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    createAccount.frame = CGRectMake(20, forgotPassword.frame.origin.y + forgotPassword.frame.size.height + 20, self.view.frame.size.width - 40, 30);
    [createAccount setTitle:@"Or Tap to Create an Account" forState:UIControlStateNormal];
    createAccount.titleLabel.font = [UIFont fontWithName:@"Avenir" size:18];
    [createAccount addTarget:self action:@selector(createNewAccount) forControlEvents:UIControlEventTouchDown];
    [createAccount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [scroll addSubview:createAccount];
    
    activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 25, self.view.frame.size.height / 2 - 25, 50, 50)];
    [activity startAnimating];
    activity.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [activity setColor:[Color appColorMedium]];
    
    UITapGestureRecognizer* touch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeKeyboard)];
    [scroll addGestureRecognizer:touch];
    
    float size = 170;
    for (UIView* view in scroll.subviews){
        size+=view.frame.size.height;
    }
//    scroll.frame = CGRectMake(0, 0, self.view.frame.size.width, size);
    [scroll setContentSize:CGSizeMake(self.view.frame.size.width, size)];
    [self.view addSubview:scroll];
    
    UIScreenEdgePanGestureRecognizer* panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(sidePanDetected:)];
    [panGesture setEdges:UIRectEdgeLeft];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    
    UILabel* bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.frame.size.width, 70)];
    bottomLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomLabel];
    
    UIButton *dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    dismiss.frame = CGRectMake(14, self.view.frame.size.height-54, 80, 38);
    [dismiss setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dismiss setTitle:@"Menu" forState:UIControlStateNormal];
    dismiss.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
    [dismiss addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:dismiss];
    // Do any additional setup after loading the view.
}

-(void)continueLogin{
    if (username.text != NULL && username.text.length > 0 && password.text != NULL && password.text.length > 0){
        if (username.text.length < 3){
            [self simpleAlertViewTitle:@"Username too short" message:@"Please enter a username with 4 characters or longer" tag:0];
        }else if (password.text.length < 5){
            [self simpleAlertViewTitle:@"Password too short" message:@"Please enter a password with 5 characters or longer" tag:0];
        }else{
            //Login
            [self.view addSubview:activity];
            [Communicator logInWithUsername:username.text password:password.text completion:^(NSDictionary* responseDict, BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [activity removeFromSuperview];
                });
                if (success){
                    NSLog(@"responseDict: %@",responseDict);
                    self.userInfo = [[UserInfo alloc]initWithDictionary:[responseDict objectForKey:@"userInfo"]];
                    self.userInfo.loggedIn = YES;
                    //Do something
                    
                    [[NSUserDefaults standardUserDefaults]setObject:username.text forKey:@"username"];
                    [[NSUserDefaults standardUserDefaults]setObject:password.text forKey:@"password"];

                    if ([self.delegate respondsToSelector:@selector(loginControllerDidLogIn:)]){
                        [self.delegate loginControllerDidLogIn:self.userInfo];
                        [self.delegate loginControllerDidLogInWithDictionary:responseDict];

                    }
                  
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                       
                    }];
                    
                }else{
                    NSString* message = @"";
                    int tag = 0;
                    if ([responseDict objectForKey:@"message_exists"]){
                        message = [responseDict objectForKey:@"message"];
                        self.userInfo = [[UserInfo alloc]initWithDictionary:[responseDict objectForKey:@"userInfo"]];
                        tag = 1;
                    }
                    [self simpleAlertViewTitle:@"An Error Occured" message:message tag:tag];
                }
            }];
        }
        
    }else{
        [self simpleAlertViewTitle:@"Fields are empty" message:@"Please enter a registration token or login with existing credentials." tag:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    [scroll scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    [textField resignFirstResponder];
    [scroll scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == password){
        [scroll scrollRectToVisible:CGRectMake(0, scroll.frame.size.height + 20, 1, 1) animated:YES];
    }
    
}
-(void)removeKeyboard{
    NSLog(@"Touch");
    [username resignFirstResponder];
    [password resignFirstResponder];
    
}
- (void)simpleAlertViewTitle:(NSString*)title message:(NSString*)message tag:(int)tag
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
    
    if (tag == 1){
        UIAlertAction* emailButton = [UIAlertAction
                                   actionWithTitle:@"Resend Confirmation Email"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                       [Communicator resendConfirmationEmail:self.userInfo completion:^(BOOL success, BOOL message_exists, NSString *message) {
                                           NSLog(@"success: %d",success);
                                           if (success){
                                               [self simpleAlertViewTitle:@"Email Resent" message:nil tag:0];
                                           }else if (message_exists){
                                               [self simpleAlertViewTitle:@"Couldn't resend email..." message:message tag:0];
                                           }else{
                                               [self simpleAlertViewTitle:@"Error Occurred..." message:nil tag:0];
                                           }
                                       }];
                                   }];
        [alert addAction:emailButton];

    }
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)manageUserControllerDidCancel{
    NSLog(@"Username: %@",self.userInfo.username);
}
-(void)manageUserControllerDidRegisterUser:(UserInfo *)userInfo{
    self.userInfo = userInfo;
}
-(void)sidePanDetected:(UIScreenEdgePanGestureRecognizer*)pan{
    
    SlideMenu* menu = nil;
    if (pan.state == UIGestureRecognizerStateBegan) {
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

-(void)recoverPassword{
    UIAlertView* textEntryAlert= [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Please enter your username and the email address associated with your account"] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    textEntryAlert.tag = -12;
    textEntryAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[textEntryAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [[textEntryAlert textFieldAtIndex:0] setPlaceholder:@"Username"];
    [[textEntryAlert textFieldAtIndex:1] setPlaceholder:@"Email Address"];
    [[textEntryAlert textFieldAtIndex:1] setSecureTextEntry:NO];
    [textEntryAlert show];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == -12 && buttonIndex == 1){
        NSString* username = [alertView textFieldAtIndex:0].text;
        NSString* email = [alertView textFieldAtIndex:1].text;
        if (username.length == 0 || email.length < 5){
            [self simpleAlertViewTitle:@"Username or email invalid" message:nil tag:0];
            return;
        }
        UserInfo* ui = [[UserInfo alloc]init];
        ui.username = username;
        ui.email_address = email;
        [Communicator recoverPasswordWithUserInfo:ui completion:^(BOOL success, NSError *error) {
            if (success){
                [self simpleAlertViewTitle:@"Please check your email with the recovered password." message:nil tag:0];
            }else{
                [self simpleAlertViewTitle:@"Something went wrong, please try again." message:nil tag:0];
            }
        }];
        
    }
    
    
}
-(void)openMenu{
//    ParkingSession* currentSession = [[ParkingSession alloc]init];
//    currentSession.parking_location = CLLocationCoordinate2DMake(10.1, -10.1);
//    currentSession.speed = 0;
//    currentSession.user_location = CLLocationCoordinate2DMake(10.1, -10.1);
//    currentSession.status = 1;
//    currentSession.user_id = @"5oYQ5EYLEU";
//    currentSession.distance_from_car = 0.1;
//    currentSession.time_from_car = 0.1;
//    [Communicator reportStatus:currentSession completion:^(BOOL success, BOOL message_exists, NSString *message) {
//        if (!success){
//            NSLog(@"Failed to update status: %@",message);
//        }
//    }];
    
    SlideMenu* menu = [[SlideMenu alloc]initWithFrame:self.view.frame userInfo:nil loggedIn:NO expand:YES];
    menu.delegate = self;
    [self.view addSubview:menu];
}
-(void)slideMenuDidRemoveWithSelection:(NSInteger)selection{
    if (selection == 0){
        InfoViewController* info = [[InfoViewController alloc]initWithTitle:@"About the ParkOut" andContent:AppInfo andUserId:@"" token:@"" enroll:NO dict:nil];
        [self presentViewController:info animated:YES completion:nil];
    }
}
-(void)slideMenuDidRemoveWithTask:(NSInteger)task loggedIn:(BOOL)loggedIn{
    if (!loggedIn){
        if (task == 0){
            UIAlertView* textEntryAlert= [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Please enter your username and the email address associated with your account"] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            textEntryAlert.tag = -12;
            textEntryAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            [[textEntryAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
            [[textEntryAlert textFieldAtIndex:0] setPlaceholder:@"Username"];
            [[textEntryAlert textFieldAtIndex:1] setPlaceholder:@"Email Address"];
            [[textEntryAlert textFieldAtIndex:1] setSecureTextEntry:NO];
            [textEntryAlert show];
        }else{
            
        }
    }
}
-(void)userPlansDidLogout{
    self.userInfo = [[UserInfo alloc]init];
}
-(void)createNewAccount{
    ManageUserController* muc = [[ManageUserController alloc]initWithUserInfo:self.userInfo];
    muc.delegate = self;
    [self presentViewController:muc animated:YES completion:nil];
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
