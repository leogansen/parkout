//
//  SlideMenu.h
//  Pocupon
//
//  Created by Leonid Iogansen on 9/13/16.
//  Copyright © 2016 Leonid Iogansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"
#import "UserInfo.h"

@protocol SlideMenuDelegate <NSObject>

-(void)slideMenuDidRemoveWithSelection:(NSInteger)selection;
@optional
-(void)slideMenuDidRemoveWithTask:(NSInteger)task loggedIn:(BOOL)loggedIn;

@end

@interface SlideMenu : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>{
    UITableView* table;
    CGPoint pts[5];
    float x;
    float y;
    UIView* view;
    UIView* darkView;
    
}

@property (strong, nonatomic) NSArray* items;
@property (readwrite) BOOL loggedIn;
@property (strong, nonatomic) UserInfo* userInfo;

@property (assign, nonatomic) id <SlideMenuDelegate> delegate;

-(void)adjustFrameForGesture:(UIScreenEdgePanGestureRecognizer*)gesture;

-(id)initWithFrame:(CGRect)frame userInfo:(UserInfo*)userInfo loggedIn:(BOOL)_loggedIn expand:(BOOL)expand;

@end

