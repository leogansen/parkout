//
//  CutomPickerView.m
//  ParkOut
//
//  Created by Leonid on 5/13/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "CustomPickerView.h"

@implementation CustomPickerView
@synthesize itemsArray,delegate;

-(id)initWithArray:(NSArray*)array frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.itemsArray = array;
        
        self.backgroundColor = [Color appColorLight];
        self.picker = [[UIPickerView alloc]init];
        self.picker.frame = CGRectMake(0, self.frame.size.height - 170, self.frame.size.width, 170);
        self.picker.delegate = self;
        self.picker.tintColor = [UIColor whiteColor];
        self.picker.backgroundColor = [Color appColorLight];
        [self addSubview:self.picker];        
        
        
        UIButton* donePicking = [UIButton buttonWithType:UIButtonTypeCustom];
        donePicking.frame = CGRectMake(self.frame.size.width - 70, 0, 60, 40);
        [donePicking setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [donePicking addTarget:self action:@selector(hidePicker) forControlEvents:UIControlEventTouchDown];
        [donePicking setTitle:@"Done" forState:UIControlStateNormal];
        [self addSubview:donePicking];
    }
    return self;
}
-(void)scrollToItem:(NSString*)item{
    for (int i = 0; i < itemsArray.count; i++){
        if ([item isEqualToString:itemsArray[i]]){
            [self.picker selectRow:i inComponent:0 animated:NO];
        }
    }
}
-(void)hidePicker{
    if ([self.delegate respondsToSelector:@selector(customPickerShouldCloseWithRow:)]){
        [self.delegate customPickerShouldCloseWithRow:row];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)_row inComponent:(NSInteger)component{
    row = _row;
    if ([self.delegate respondsToSelector:@selector(customPickerViewDidSelectRow:)]){
        [self.delegate customPickerViewDidSelectRow:row];
    }
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.itemsArray count];
}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    return [self.itemsArray objectAtIndex:row];
//}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:self.itemsArray[row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    return sectionWidth;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
