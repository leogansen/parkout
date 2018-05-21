//
//  ErrorViewController.h
//  ParkOut
//
//  Created by Leonid Iogansen on 5/20/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"

@protocol ErrorViewControllerDelegate <NSObject>

-(void)errorControllerSignedOut;

@end

@interface ErrorViewController : UIViewController{
    UILabel* face;
    UILabel* info;
}

@property (nonatomic,assign) id <ErrorViewControllerDelegate> delegate;
@end
