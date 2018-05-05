//
//  SlideUpDrawer.m
//  Pocupon
//
//  Created by Leonid on 10/8/16.
//  Copyright © 2016 Leonid Iogansen. All rights reserved.
//

#import "SlideUpDrawer.h"

@implementation SlideUpDrawer
@synthesize delegate,fontSize,textItems,tempTextItems;

-(id)initWithFrame:(CGRect)frame{
    viewHeight = 280;
    shiftSpacer = 0;
    CGRect hiddenFrame = CGRectMake(0, frame.size.height, frame.size.width, viewHeight);
    self = [super initWithFrame:frame];
    if (self){
        self.frame = hiddenFrame;
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, viewHeight)];
        table.delegate = self;
        table.dataSource = self;
        table.separatorColor = [UIColor clearColor];
        swipe = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRegistered:)];
        swipe.delegate = self;
        [self addGestureRecognizer:swipe];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetected:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        table.backgroundColor = [UIColor whiteColor];
        
        view = [[UIView alloc]initWithFrame:hiddenFrame];
        [view addSubview:table];
        [view addSubview:listViewButton];
        
        [self addSubview:view];
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = .6;
        
        
        [UIView animateWithDuration:.25
                         animations:^{
                             //Animate
                             self.frame = CGRectMake(0, frame.size.height - 60, frame.size.width, frame.size.height);
                             view.frame = CGRectMake(0, 0, frame.size.width, viewHeight);
                             
                             
                         } completion:^(BOOL finished) {
                             //Finished
                             [table reloadData];
                             table.scrollEnabled = NO;
                             
                         }];
        
        
    }
    return self;
}
-(void)tapDetected:(UITapGestureRecognizer*)tap{
    pts[0] = [tap locationInView:table];
    CGPoint p = [self convertPoint:pts[0] toView:self.superview];
    float tapPoint = p.y;
    NSLog(@"tapPoint: %f ",self.superview.frame.size.height - tapPoint);
    if (isOpen){
        [self removeSelf];
    }else{
        [self slideBack];
    }
}

-(void)setButton:(UIButton*)button{
    listViewButton = button;
}

-(void)setTableText:(NSMutableArray*)_textItems fontSize:(float)_fontSize{
    self.textItems = [_textItems mutableCopy];
    self.tempTextItems = [_textItems mutableCopy];
    if (self.textItems.count > 2){
        shiftSpacer = 20;
    }else{
        shiftSpacer = 0;
    }
    NSLog(@"textItems: %@",self.textItems);
    self.fontSize = _fontSize;
    [self updateHeight];
    [table reloadData];
}
-(void)removeSelfCompletely{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
}

-(void)swipeRegistered:(UIPanGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began");
        pts[0] = [gesture locationInView:self.superview];
        y = self.superview.frame.origin.y - [gesture locationInView:self.superview].y;
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        pts[0] = [gesture locationInView:self.superview];
        float originY = pts[0].y + y;
        
        float selfOrigin = self.superview.frame.size.height - self.tempTextItems.count * 40 - 50 - shiftSpacer;
        float selfOriginLower = self.superview.frame.size.height - 90;
        
        float deltaSelfHigher = selfOrigin - self.frame.origin.y;
        float deltaSelfLower = selfOriginLower - self.frame.origin.y;
        if (originY > deltaSelfHigher && originY < deltaSelfLower){
            view.frame = CGRectMake(0, originY, self.frame.size.width, viewHeight);
        }
        CGPoint p = [self convertPoint:view.frame.origin toView:self.superview];
        listViewButton.frame =  CGRectMake(listViewButton.frame.origin.x, p.y - 50, 40, 40);
        NSLog(@"Gesture changed: %f",originY);
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        float originY = pts[0].y + y;
        float selfOriginLower = self.superview.frame.size.height - 120;
        float deltaSelfLower = selfOriginLower - self.frame.origin.y;
        NSLog(@"Gesture ended");
        if (originY > deltaSelfLower){
            [self removeSelf];
        }else{
            [self slideBack];
        }
        CGPoint p = [self convertPoint:view.frame.origin toView:self.superview];
        listViewButton.frame =  CGRectMake(listViewButton.frame.origin.x, p.y - 50, 40, 40);
        
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
-(void)updateHeight{
    viewHeight = self.tempTextItems.count * 40 + 50 + shiftSpacer;
}
-(void)removeSelf{
    NSLog(@"Sliding down");
    if (self.textItems.count == 0){
        return;
    }
    [UIView animateWithDuration:.25
                     animations:^{
                         //Animate
                         shiftSpacer = 0;
//                         if (self.textItems.count > 1){
//                             shiftSpacer = 10;
//                         }
                         self.frame = CGRectMake(0, self.frame.size.height - 60, self.frame.size.width, self.frame.size.height);
                         view.frame = CGRectMake(0, 0, self.frame.size.width, viewHeight);
                         CGPoint p = [self convertPoint:view.frame.origin toView:self.superview];
                         listViewButton.frame =  CGRectMake(listViewButton.frame.origin.x, p.y - 50, 40, 40);
                         
                     } completion:^(BOOL finished) {
                         //Finished
                         isOpen = NO;
                         textItems = [@[@"",@""] mutableCopy];
                         [table reloadData];
                     }];
}
-(void)slideBack{
    NSLog(@"Sliding up");
    if (self.textItems.count == 0){
        return;
    }
    [UIView animateWithDuration:.25
                     animations:^{
                         //Animate
                         shiftSpacer = 10;
                         self.frame = CGRectMake(0, self.superview.frame.size.height - viewHeight, self.frame.size.width, self.frame.size.height);
                         view.frame = CGRectMake(0, 0, self.frame.size.width, viewHeight);
                         CGPoint p = [self convertPoint:view.frame.origin toView:self.superview];
                         listViewButton.frame =  CGRectMake(listViewButton.frame.origin.x, p.y - 50, 40, 40);
                     } completion:^(BOOL finished) {
                         //Finished
                         isOpen = YES;
                         self.textItems = self.tempTextItems;
                         [table reloadData];
                     }];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"textItems: %@",self.textItems);
    return self.textItems.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.textItems.count > 1){
        return 10;
    }else{
        return 0;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.textItems.count > 1){
        UILabel* view = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        view.text = @"—";
//        view.font = [UIFont fontWithName:@"Avenir" size:20];
        view.textColor = [UIColor blackColor];
        view.textAlignment = NSTextAlignmentCenter;
        return view;
    }else{
        return nil;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *mainCellIdentifier = @"mainCellIdentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
    TableCellLabel* view = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainCellIdentifier];
        //        cell.contentMode = UITableViewCellSelectionStyleDefault;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        view = [[TableCellLabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        view.textColor = [UIColor blackColor];
        view.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:self.fontSize];
       
        NSLog(@"TABLE text: %@",[self.textItems objectAtIndex:indexPath.row]);
        if (indexPath.row == 0 && ![[self.textItems objectAtIndex:indexPath.row] isEqualToString:@"^"]){
            UILabel* gKey = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, view.frame.size.height)];
            gKey.text = @"Driver Leaving Now";
            gKey.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:self.fontSize];
            [view addSubview:gKey];
            UILabel* rKey = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width - 150, 0, 130, view.frame.size.height)];
            rKey.text = @"Driver Far Away";
            rKey.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:self.fontSize];
            rKey.textAlignment = NSTextAlignmentRight;
            [view addSubview:rKey];
        }
        if (indexPath.row == 1){
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:view.frame];
            imageView.image = [UIImage imageNamed:@"color_cell.png"];
            [view addSubview:imageView];
        }
        view.textAlignment = NSTextAlignmentCenter;
        [view setAdjustsFontSizeToFitWidth:YES];
        view.numberOfLines = 5;
        view.minimumScaleFactor = 0.4;

        if (indexPath.row == 2){
            view.frame = CGRectMake(20, 0, 100, 40);
            [view setAdjustsFontSizeToFitWidth:NO];
            view.textAlignment = NSTextAlignmentLeft;
            view.textColor = [UIColor blackColor];
            view.text = @"Open Parking:";
            UIImageView* emptyParkingView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 7, 25, 25)];
            emptyParkingView.image = [Utils drawCircle:0 status:-1];
            [view addSubview:emptyParkingView];
            
            UILabel* view1 = [[UILabel alloc]initWithFrame:CGRectMake(180, 0, 180, 40)];
            view1.textColor = [UIColor blackColor];
            view1.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:self.fontSize];
            view1.textAlignment = NSTextAlignmentLeft;
            view1.text = @"Driver not moving:";
            UIImageView* driverNotmovingView = [[UIImageView alloc]initWithFrame:CGRectMake(130, 7, 25, 25)];
            driverNotmovingView.image = [Utils drawCircle:0 status:6];
            [view1 addSubview:driverNotmovingView];
            [cell addSubview:view1];

        }else if (indexPath.row == 3){
            view.frame = CGRectMake(20, 0, self.frame.size.width - 40, 50);
            view.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14];

        }
        
        [cell addSubview:view];
    }else{
        for (UIView* v in cell.subviews){
            if ([v isKindOfClass:[TableCellLabel class]]){
                view = (TableCellLabel*)v;
               
            }
        }
        
    }
    for (UIView* v in view.subviews){
        if (!isOpen){
            v.hidden = YES;
        }else{
            v.hidden = NO;
        }
    }
    
    
    NSLog(@"CELL: %ld",(unsigned long)cell.subviews.count);
    NSLog(@"view.text: %@",view.text);
    view.text = [NSString stringWithFormat:@"%@", [textItems objectAtIndex:indexPath.row]];
    
    if (!isOpen && indexPath.row == 0){
        view.text = @"(tap to expand)";
    }
    
    NSLog(@"indentation width: %f, %ld",cell.indentationWidth,(long)cell.indentationLevel);
    //    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
    //    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"INDEX PATH: %ld",(long)indexPath.row);
    if (isOpen){
        [self removeSelf];
    }else{
        [self slideBack];
    }
    
    
}


-(float)estimateRowHeight : (NSString*)string{
    float len = string.length;
    float height = (len * 23) / self.frame.size.width;
    return height * 23 +46;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

