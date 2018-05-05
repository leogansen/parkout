//
//  SlideMenu.m
//  Pocupon
//
//  Created by Leonid Iogansen on 9/13/16.
//  Copyright © 2016 Leonid Iogansen. All rights reserved.
//

#import "SlideMenu.h"

@implementation SlideMenu
@synthesize items,userInfo,loggedIn,delegate;

-(id)initWithFrame:(CGRect)frame userInfo:(UserInfo*)_userInfo loggedIn:(BOOL)_loggedIn expand:(BOOL)expand{
    CGRect hiddenFrame = CGRectMake(-279, 0, 280, frame.size.height);
    self = [super initWithFrame:frame];
    if (self){
        self.loggedIn = _loggedIn;
        if (self.loggedIn){
            self.items = @[@"Find My Car",@"Update Status",@"About",@"Update Info",@"Logout",@"Cancel"];
        }else{
            self.items = @[@"About ParkOut", @"Cancel"];
        }
        self.userInfo = _userInfo;
        self.frame = frame;
        
        darkView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width * 2, frame.size.height)];
        [self addSubview:darkView];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 280, self.frame.size.height - 200)];
        table.delegate = self;
        table.dataSource = self;
        table.separatorColor = [UIColor clearColor];
        
        UIPanGestureRecognizer* swipe = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRegistered:)];
        swipe.delegate = self;
        [table addGestureRecognizer:swipe];
        
        view = [[UIView alloc]initWithFrame:hiddenFrame];
        if (_loggedIn){
            view.backgroundColor = [Color appColorLight];
        }else{
            view.backgroundColor = [Color appColorMedium1];
        }
        UILabel* businessName = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, table.frame.size.width - 20, 90)];
        businessName.textAlignment = NSTextAlignmentCenter;
        businessName.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:30];
        if (!self.loggedIn){
            businessName.text = @"Please sign in or register";
        }else{
            businessName.text = self.userInfo.username;
        }
        businessName.adjustsFontSizeToFitWidth = YES;
        businessName.textColor = [UIColor whiteColor];
        [view addSubview:businessName];
        
        UIImageView* logoView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 260, 60)];
        logoView.contentMode = UIViewContentModeScaleAspectFit;
        //        logoView.image = self.business.business_logo;
        [view addSubview:logoView];
        
        UIButton* login = [UIButton buttonWithType:UIButtonTypeCustom];
        login.frame = CGRectMake(0, 160, table.frame.size.width, 40);
        [login addTarget:self action:@selector(manageUser) forControlEvents:UIControlEventTouchDown];
        login.titleLabel.font = [UIFont fontWithName:@"Avenir" size:17];
        login.titleLabel.adjustsFontSizeToFitWidth = YES;
        if (!self.loggedIn){
            [login setTitle:@"Sign in or register >" forState:UIControlStateNormal];
        }else{
            [login setTitle:[NSString stringWithFormat:@"Welcome, %@! (update/logout)",userInfo.username] forState:UIControlStateNormal];
            [view addSubview:login];
        }
        
        [view addSubview:table];
        
        [self addSubview:view];
        
        darkView.backgroundColor = [UIColor blackColor];
        darkView.alpha = 0;
        
        NSLog(@"Slide View Ready");
        
        if (expand){
            [self slideBack];
        }
        
    }
    return self;
}
-(void)viewTapped:(UITapGestureRecognizer*)tap{
    [self removeSelf];
}

-(void)swipeRegistered:(UIPanGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        pts[0] = [gesture locationInView:self.superview];
        x = view.frame.origin.x - [gesture locationInView:self].x;
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        pts[0] = [gesture locationInView:self.superview];
        float originX = pts[0].x + x;
        if (originX <= 0){
            view.frame = CGRectMake(originX, 0, 280, self.frame.size.height);
        }
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        if (view.frame.origin.x < -100){
            [self removeSelf];
        }else{
            [self slideBack];
        }
    }
}
-(void)adjustFrameForGesture:(UIScreenEdgePanGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        pts[0] = [gesture locationInView:self.superview];
        x = view.frame.origin.x - [gesture locationInView:self].x;
        view.frame = CGRectMake(x, 0, 280, self.frame.size.height);
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        pts[0] = [gesture locationInView:self.superview];
        float originX = pts[0].x + x;
        if (originX <= 0){
            view.frame = CGRectMake(originX, 0, 280, self.frame.size.height);
            darkView.alpha = 0.5 * ((view.frame.origin.x + 280) / 280);
        }
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        if (view.frame.origin.x < -100){
            [self removeSelf];
        }else{
            [self slideBack];
        }
    }
    
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)viewSwiped:(UISwipeGestureRecognizer*)sender{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft){
        [self removeSelf];
    }
}

-(void)removeSelf{
    CGRect hiddenFrame = CGRectMake(-self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    
    [UIView animateWithDuration:.25
                     animations:^{
                         //Animate
                         self.frame = hiddenFrame;
                         darkView.alpha = 0;
                     } completion:^(BOOL finished) {
                         //Finished
                         [darkView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}
-(void)slideBack{
    [UIView animateWithDuration:.25
                     animations:^{
                         //Animate
                         view.frame = CGRectMake(0, 0, 280, self.frame.size.height);
                         darkView.alpha = .5;
                     } completion:^(BOOL finished) {
                         //Finished
                     }];
    
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self.superview];
    float originX = pts[0].x + x;
    if (originX <= 0){
        view.frame = CGRectMake(originX, 0, 280, self.frame.size.height);
        darkView.alpha = 0.5 * ((view.frame.origin.x + 280) / 280);
        
    }
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self.superview];
    x = view.frame.origin.x - [touch locationInView:self].x;
    NSLog(@"Touches began");
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ((pts[0].x == [touch locationInView:self.superview].x && pts[0].y == [touch locationInView:self.superview].y) || view.frame.origin.x < -100){
        [self removeSelf];
    }else{
        [self slideBack];
    }
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *mainCellIdentifier = @"mainCellIdentifier";
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:mainCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentMode = UITableViewCellStateDefaultMask;
        cell.contentMode = UITableViewCellSelectionStyleDefault;
        
    }
    
    if ([self.items[indexPath.row] isEqualToString:@"Send Feedback"]){
        //        cell.textLabel.textColor = [Color pocuponColor:1];
        cell.textLabel.textColor = [UIColor blackColor];
        
    }else if ([self.items[indexPath.row] isEqualToString:@"Share on Facebook"]){
        cell.textLabel.textColor = [UIColor colorWithRed:57/255.0 green:90/255.0 blue:147/255.0 alpha:1];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = self.items[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"INDEX PATH");
    if ([self.delegate respondsToSelector:@selector(slideMenuDidRemoveWithSelection:)]){
        [self.delegate slideMenuDidRemoveWithSelection:indexPath.row];
    }
    [self removeSelf];
}
-(void)manageUser{
    if (self.loggedIn){
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Log Out",@"Update User Info",@"Cancel", nil];
        alert.tag = 2;
        [alert show];
        
    }else{
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Recover Password",@"Cancel", nil];
        alert.tag = 1;
        [alert show];
        
    }
}
-(void)logout{
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1 || alertView.tag == 2){
        NSLog(@"Registering new user");
        if ([self.delegate respondsToSelector:@selector(slideMenuDidRemoveWithTask:loggedIn:)]){
            [self.delegate slideMenuDidRemoveWithTask:buttonIndex loggedIn:(BOOL)self.loggedIn];
        }
        [self removeSelf];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end


