//
//  InfoViewController.m
//  TollTracker
//
//  Created by Leonid Iogansen on 4/4/16.
//  Copyright © 2016 Leonid Iogansen. All rights reserved.
//

#import "InfoViewController.h"
#import "Color.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize scrollView,title,content,user_id,token;

-(id)initWithTitle:(NSString*)_title andContent:(NSString*)_content andUserId:(NSString*)userId token:(NSString*)_token enroll:(BOOL)_enroll dict:(NSDictionary*)dict{
    self = [super init];
    if (self){
        self.title = _title;
        self.content = _content;
        self.user_id = userId;
        enroll = _enroll;
        token = _token;
        eDict = dict;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 69)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    
    UILabel* bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.frame.size.width, 70)];
    bottomLabel.backgroundColor = [Color appColorLight];
    [self.view addSubview:bottomLabel];
    
  
    UIButton *dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    dismiss.frame =  CGRectMake(14, self.view.frame.size.height-54, 50, 38);
    dismiss.titleLabel.textColor = [UIColor whiteColor];
    [dismiss setTitle:@"‹⃝" forState:UIControlStateNormal];
    dismiss.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:40];
    [dismiss addTarget:self action:@selector(dismissThisController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:dismiss];
    
    
    int numOfLines = [self numberOfLinesWithFont:20 textLength:(int)self.title.length];
    UILabel* description = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, self.view.frame.size.width-20, numOfLines * 30)];
    description.text = self.title;
    description.numberOfLines = numOfLines;
    NSLog(@"description.numberOfLines: %ld",(long)description.numberOfLines);
    description.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];
    description.textColor = [UIColor darkGrayColor];
    description.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:description];
    
    UITextView* info = [[UITextView alloc]initWithFrame:CGRectMake(20, 10 + 40 + description.frame.size.height, self.view.frame.size.width-40, self.view.frame.size.height)];
    info.text = self.content;
    info.userInteractionEnabled = NO;
    info.font =[UIFont fontWithName:@"AvenirNext-DemiBold" size:16];
    info.textColor = [UIColor lightGrayColor];
    [info sizeToFit];
    [self.scrollView addSubview:info];
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.scrollView.contentSize = contentRect.size;
}
-(void)dismissThisController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(int)numberOfLinesWithFont:(float)font textLength:(int)textLength{
    int lines = 1;
    float width = self.view.frame.size.width - 20;
    float maxLength = width / font;
    lines = textLength / maxLength;
    if (lines == 0){
        lines = 1;
    }
    return lines;
}


- (void)simpleAlertViewTitle:(NSString*)title message:(NSString*)message
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle your yes please button action here
                                   
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


