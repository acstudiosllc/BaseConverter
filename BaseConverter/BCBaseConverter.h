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

- (void)setValue:(NSString *)value inBase:(NSInteger)base;
- (NSString *)getValueForBase:(NSInteger)base;
- (NSString *)nameForBase:(NSInteger)base;
- (NSInteger)valueForDigit:(NSString *)digit;

@end
