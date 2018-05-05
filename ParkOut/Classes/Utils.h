//
//  Utils.h
//  ParkOut
//
//  Created by Leonid on 5/2/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (UIImage *)drawCircle:(double)distance status:(int)status;
+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count;

@end
