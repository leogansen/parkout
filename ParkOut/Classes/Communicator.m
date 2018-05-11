//
//  Communicator.m
//  ParkOut
//
//  Created by Leonid on 4/30/18.
//  Copyright © 2018 Leonid. All rights reserved.
//

#import "Communicator.h"

@implementation Communicator
+(void)validateRegistrationToken:(NSString*)token completion:(void (^)(BOOL))completion{
    NSDictionary* queryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,@"token",
                               nil];
    
    NSError* jsonerror;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:queryDict
                                                       options:NSJSONWritingPrettyPrinted error:&jsonerror];
    NSLog(@"queryDict: %@", queryDict);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        NSURL *url = [NSURL URLWithString:ValidateRegistrationToken];
        NSLog(@"URL: %@",ValidateRegistrationToken);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setTimeoutInterval:60];
        NSError* error = nil;
        NSURLResponse *response =[[NSURLResponse alloc]init];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSError *jsonParsingError = nil;
        NSDictionary *responseDict;
        if (data != nil){
            responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSLog(@"responseDict: %@",responseDict);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion([[responseDict objectForKey:@"success"]boolValue]);
            });
            
        }else{
            NSLog(@"data is nil");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(NO);
            });
            
        }
        
    });
}
+(void)logInWithUsername:(NSString*)username password:(NSString*)password completion:(void (^)(NSDictionary*,BOOL))completion{
    UserInfo* ui = [[UserInfo alloc]init];
    ui.username = username;
    ui.password = password;
    NSDictionary* queryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               ui.userinfo_dictionary,@"userInfo",
                               nil];
    
    NSError* jsonerror;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:queryDict
                                                       options:NSJSONWritingPrettyPrinted error:&jsonerror];
    NSLog(@"queryDict: %@", queryDict);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        NSURL *url = [NSURL URLWithString:LogIn];
        NSLog(@"URL: %@",LogIn);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setTimeoutInterval:60];
        NSError* error = nil;
        NSURLResponse *response =[[NSURLResponse alloc]init];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSError *jsonParsingError = nil;
        NSDictionary *responseDict;
        if (data != nil){
            responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSLog(@"responseDict: %@",responseDict);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if ([responseDict objectForKey:@"message"] != [NSNull null]){
                    completion(responseDict,NO);
                }else{
                    completion(responseDict,YES);
                }
            });
        }else{
            NSLog(@"data is nil");
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(NULL,NO);
            });
            
        }
        
    });
}
+(void)recoverPasswordWithUserInfo:(UserInfo*)ui completion:(void (^)(BOOL,NSError*))completion{
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  ui.userinfo_dictionary,@"userInfo",
                                  nil];
    
    NSError* jsonerror;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:userInfoDict
                                                       options:NSJSONWritingPrettyPrinted error:&jsonerror];
    NSLog(@"Recover Password: %@",userInfoDict);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        NSURL *url = [NSURL URLWithString:RecoverPassword];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setTimeoutInterval:60];
        NSError* error = nil;
        NSURLResponse *response =[[NSURLResponse alloc]init];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSError *jsonParsingError = nil;
        NSDictionary *responseDict;
        if (data != nil){
            responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSLog(@"Recover PW responseDict: %@",responseDict);
            if (responseDict != nil){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(YES,nil);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(NO,jsonParsingError);
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(NO,error);
            });
        }
        
    });
}
+(void)reportStatus:(ParkingSession*)session completion:(void (^)(BOOL,BOOL,NSString*))completion{
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  session.dictionary_frontend_calculation,@"parking_session",
                                  nil];
    [self makePostRequest:userInfoDict url:UpdateStatus completion:^(NSDictionary*responseDict) {
        if (responseDict != nil){
            if ([[responseDict objectForKey:@"message_exists"]boolValue] == NO){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(YES,NO,nil);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(NO,NO,[responseDict objectForKey:@"message"]);
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(NO,NO,@"ERROR");
            });
        }
    }];
  
}
+(void)fetchParkingLocations:(CLLocationCoordinate2D)location userId:(NSString*)user_id latDelta:(float)latDelta lngDelta:(float)lngDelta completion:(void (^)(NSDictionary* ))completion{
    NSDictionary* coord = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithDouble:location.latitude],@"latitude",
                         [NSNumber numberWithDouble:location.longitude],@"longitude",
                         nil];
    NSDictionary* loc = [NSDictionary dictionaryWithObjectsAndKeys:coord,@"coordinate", nil];
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  loc,@"location",
                                  [NSNumber numberWithDouble:latDelta],@"delta_lat",
                                  [NSNumber numberWithDouble:lngDelta],@"delta_lng",
                                  user_id,@"user_id",
                                  nil];
    [self makePostRequest:userInfoDict url:FetchParkingLocations completion:^(NSDictionary* responseDict) {
        NSLog(@"fetchParkingLocations: %@",responseDict);
        if (responseDict != nil){
            if ([[responseDict objectForKey:@"message_exists"]boolValue] == NO){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(responseDict);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(responseDict);
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(nil);
            });
        }
        
    }];
}
+(void)resendConfirmationEmail:(UserInfo*)ui completion:(void (^)(BOOL,BOOL,NSString*))completion{
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  ui.userinfo_dictionary,@"userInfo",
                                  nil];
    [self makePostRequest:userInfoDict url:ResendEmail completion:^(NSDictionary*responseDict) {
        if (responseDict != nil){
            NSLog(@"responseDict: %@",responseDict);
            if ([[responseDict objectForKey:@"message_exists"] boolValue] == NO){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(YES,NO,nil);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(NO,NO,[responseDict objectForKey:@"message"]);
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(NO,NO,@"ERROR");
            });
        }
    }];
}
+(void)postNotification:(NSString*)requested_user_id message:(NSString*)message completion:(void (^)(BOOL,BOOL,NSString*))completion{
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  requested_user_id,@"user_id",
                                  message,@"message",
                                  nil];
    [self makePostRequest:userInfoDict url:PostNotification completion:^(NSDictionary*responseDict) {
        if (responseDict != nil){
            if ([[responseDict objectForKey:@"message_exists"]boolValue] == NO){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(YES,NO,nil);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    completion(NO,NO,[responseDict objectForKey:@"message"]);
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(NO,NO,@"ERROR");
            });
        }
    }];
}

+(void)makePostRequest:(NSDictionary*)dict url:(NSString*)url_path completion:(void (^)(NSDictionary* ))completion{
    NSError* jsonerror;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&jsonerror];
    NSLog(@"POST dict to %@: %@",url_path,dict);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        NSURL *url = [NSURL URLWithString:url_path];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setTimeoutInterval:60];
        NSError* error = nil;
        NSURLResponse *response =[[NSURLResponse alloc]init];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSError *jsonParsingError = nil;
        NSDictionary *responseDict;
        if (data != nil){
            responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            completion(responseDict);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(nil);
            });
        }
        
    });
}
@end
