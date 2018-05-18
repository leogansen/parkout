//
//  Utils.m
//  ParkOut
//
//  Created by Leonid on 5/2/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (UIImage *)drawCircle:(double)distance status:(int)status{
    
    UIImage *mapCircle = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(32.f,32.f), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGRect rect_shadow = CGRectMake(10, 10, 12.f, 12.f);
    CGRect rect_base = CGRectMake(5, 5, 22.f, 22.f);
    CGRect rect = CGRectMake(6, 6, 20.f, 20.f);
        
    //Get Color
    UIColor* color;
    UIColor* baseColor = [UIColor whiteColor];
    UIColor* shadowColor;

    BOOL frameIsWhite = YES;
    if (status == 6){
        color = [UIColor redColor];
        shadowColor = color;
    }else if (status == -1){
        frameIsWhite = NO;
        UIImage* colors_image =[UIImage imageNamed:@"colors.png"];
        NSArray* colors = [Utils getRGBAsFromImage:colors_image atX:1 andY:1 count:1];
        baseColor = [colors objectAtIndex:0];
        color = [UIColor whiteColor];
        rect = CGRectMake(8, 8, 16.f, 16.f);
        shadowColor = [UIColor clearColor];
    }else{
        UIImage* colors_image =[UIImage imageNamed:@"colors.png"];
        CGImageRef imageRef = [colors_image CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSLog(@"Colors: %d",(int)width);
        float x = (width / MAX_WALKING_DISTANCE) * distance;
        if (x >= width){
            x = width - 2;
        }
        NSArray* colors = [Utils getRGBAsFromImage:colors_image atX:x andY:1 count:1];
        color = [colors objectAtIndex:0];
        shadowColor = color;
    }

    
    CGContextSetShadowWithColor(ctx, CGSizeMake(1, 1), 4, shadowColor.CGColor);
    CGContextFillEllipseInRect(ctx, rect_shadow);
    CGContextSetFillColorWithColor(ctx, baseColor.CGColor);
    CGContextFillEllipseInRect(ctx, rect_base);
    CGContextRestoreGState(ctx);

    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);

    CGContextRestoreGState(ctx);
    mapCircle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return mapCircle;
}

+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     )  / 255.0f;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] )  / 255.0f;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] )  / 255.0f;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}
+ (void)addToLog:(UserInfo*)user message:(NSString*)message{
    if (user.log.count > 100){
        [user.log removeObjectAtIndex:0];
    }
    NSLog(@"MESSAGE: %@",message);
    
    [user.log addObject:message];
    [[NSUserDefaults standardUserDefaults]setObject:user.log forKey:@"user_log"];
}
@end
