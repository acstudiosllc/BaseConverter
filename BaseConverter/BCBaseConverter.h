//
//  BCBaseConverter.h
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCBaseConverter : NSObject

@property (strong, nonatomic) NSDictionary *baseNamesDictionary;

- (NSString *)convertNumber:(NSString *)num fromBase:(NSInteger)baseOriginal toBase:(NSInteger)baseFinal;
- (NSString *)nameForBase:(NSInteger)base;

@end
