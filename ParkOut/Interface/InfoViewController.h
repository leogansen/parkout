//
//  InfoViewController.h
//  ParkOut
//
//  Created by Leonid on 4/30/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Communicator.h"

@interface InfoViewController : UIViewController{
    BOOL enroll;
    NSDictionary* eDict;
}

@property (strong, atomic) UIScrollView* scrollView;
@property (copy, nonatomic) NSString* title;
@property (copy, nonatomic) NSString* content;
@property (copy, nonatomic) NSString* user_id;
@property (copy, nonatomic) NSString* token;

-(id)initWithTitle:(NSString*)_title andContent:(NSString*)_content andUserId:(NSString*)userId token:(NSString*)token enroll:(BOOL)_enroll dict:(NSDictionary*)dict;

@end

