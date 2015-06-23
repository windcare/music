//
//  MainMenuController.h
//  MyMusic
//
//  Created by sjjwind on 5/28/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainMenuController : NSObject

+ (instancetype) sharedController;

- (void)setMenuImage:(NSString *)imageName;

@end
