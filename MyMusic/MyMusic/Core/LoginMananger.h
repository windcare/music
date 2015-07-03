//
//  LoginMananger.h
//  MyMusic
//
//  Created by sjjwind on 7/2/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginMananger : NSObject

+ (instancetype) sharedManager;

- (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
                 complete:(void (^)(BOOL success))completion;

- (void)autoLoginWithComplete:(void (^)(BOOL success))completion;

@end
