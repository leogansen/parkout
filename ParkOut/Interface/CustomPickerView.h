//
//  CutomPickerView.h
//  ParkOut
//
//  Created by Leonid on 5/13/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"

@protocol CustomPickerViewDelegate <NSObject>

-(void)customPickerViewDidSelectRow:(NSInteger)row;
-(void)customPickerShouldCloseWithRow:(NSInteger)row;

@end

@interface CustomPickerView : UIView<UIPickerViewDelegate>{
    NSInteger row;
}

@property (retain, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) NSArray* itemsArray;
@property (assign, nonatomic) id <CustomPickerViewDelegate> delegate;

-(id)initWithArray:(NSArray*)array frame:(CGRect)frame;
-(void)scrollToItem:(NSString*)item;

@end
