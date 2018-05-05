//
//  SlideUpDrawer.h
//  Pocupon
//
//  Created by Leonid on 10/8/16.
//  Copyright © 2016 Leonid Iogansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"
#import "TableCellLabel.h"
#import "Utils.h"
@protocol SlideUpDrawerDelegate <NSObject>



@end

@interface SlideUpDrawer : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>{
    UITableView* table;
    CGPoint pts[5];
    float x;
    float y;
    UIView* view;
    UIPanGestureRecognizer* swipe;
    
    float viewHeight;
    UIButton* listViewButton;
    BOOL isOpen;
    float shiftSpacer;
    
}

@property (assign, nonatomic) id <SlideUpDrawerDelegate> delegate;
@property (readwrite) float fontSize;
@property (strong, nonatomic) NSMutableArray* textItems;
@property (strong, nonatomic) NSMutableArray* tempTextItems;

-(id)initWithFrame:(CGRect)frame;
-(void)setTableText:(NSArray*)textItems fontSize:(float)fontSize;
-(void)slideBack;
-(void)setButton:(UIButton*)button;

@end

