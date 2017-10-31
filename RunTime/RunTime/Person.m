//
//  Person.m
//  RunTime
//
//  Created by ice on 2017/10/31.
//  Copyright © 2017年 ice. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)eat{
    NSLog(@"吃货来了~~~~");
}

- (void)run:(NSString *)name{
    NSLog(@"%@ 在运动~~~~~",name);
}

- (NSString *)cry{
    return @"JJ";
}

- (NSString *)haha:(NSString *)name age:(NSString *)age{
    return [NSString stringWithFormat:@"%@ 岁的 %@ 笑哈哈~~~",age,name];
}

- (CGRect)cStruct{
     CGRect rect = CGRectMake(0, 0, 200, 200);
    return rect;
}
@end
