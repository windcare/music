//
//  NSString+Encode.m
//  MyMusic
//
//  Created by sjjwind on 6/24/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "NSString+Encode.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Encode)

-(NSString*)MD5 {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self UTF8String], (unsigned int)[self length], digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    [self length];
    return  output;
}

@end
