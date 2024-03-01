//
//  BCBaseConverter.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import "BCBaseConverter.h"

@interface BCBaseConverter ()

@property (nonatomic) NSInteger value;

@end

@implementation BCBaseConverter

- (void)setValue:(NSString *)value inBase:(NSInteger)base {
    self.value = [self convertString:value fromBase:base];
}

- (NSString *)getValueForBase:(NSInteger)base {
    NSInteger number, numberOfDigits, exponent, value, divisor;
    NSMutableString *result;
    
    number = self.value;
    
    for (numberOfDigits = 1; powl((long double)base, (long)numberOfDigits) <= number; ++numberOfDigits);

    result = @"".mutableCopy;
    for (exponent = numberOfDigits; exponent > 0; --exponent) {
        divisor = (exponent > 0) ? powl((long double)base, exponent-1) : 0;
        value = number/divisor;
        [result appendString:[self digitForValue:value]];
        number -= value * divisor;
    }
    
    return result;
}

- (NSInteger)valueForDigit:(NSString *)digit {
    char c;
    c = digit.UTF8String[0];
    if (c >= '0' && c <= '9')
        return c - '0';
    else if (c >= 'A' && c <= 'Z')
        return (c - 'A') + 10;
    else if (c >= 'a' && c <= 'z')
        return (c - 'a') + 36;
    return 0;
}

- (NSInteger)convertString:(NSString *)string fromBase:(NSInteger)base {
    NSInteger numberOfDigits, result, index;
    
    for (index = result = 0, numberOfDigits = string.length; numberOfDigits > 0; --numberOfDigits, ++index)
        result += powl((long double)base, (long double)(numberOfDigits > 0) ? numberOfDigits-1 : 0) * [self valueForDigit:[string substringWithRange:NSMakeRange(index, 1)]];
    return result;
}

- (NSString *)digitForValue:(NSInteger)val {
    char c = '0';
    if (val < 10)
        c = '0' + val;
    else if (val >= 10 && val < 36)
        c = 'A' + (val - 10);
    else if (val >= 36)
        c = 'a' + (val - 36);
    return [NSString stringWithFormat:@"%c", c];
}

- (NSString *)nameForBase:(NSInteger)base {
    if (!self.baseNamesDictionary) {
        NSString *JSONFilePath = [[NSBundle mainBundle] pathForResource:@"BaseNames" ofType:@"json"];
        NSData *JSONData = [NSData dataWithContentsOfFile:JSONFilePath];
        
        NSError *error;
        self.baseNamesDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&error];
        if (error)
            NSLog(@"%@", error);
    }
    if (base < 10)
        return self.baseNamesDictionary[@"singles"][base-2];
    else if (base == 11)
        return @"unary";
    return [self.baseNamesDictionary[@"digits"][(base%10)] stringByAppendingString:self.baseNamesDictionary[@"tens"][(base/10)-1]];
}

@end
