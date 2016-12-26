//
//  NSData+AES256.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/10/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

-(NSData *)AES256EncryptWithKey:(NSString *)key;
-(NSData *)AES256DecryptWithKey:(NSString *)key;

@end
