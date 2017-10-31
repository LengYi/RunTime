//
//  Person.h
//  RunTime
//
//  Created by ice on 2017/10/31.
//  Copyright © 2017年 ice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

// 无参数无返回值的函数
- (void)eat;

// 带一个参数无返回值的函数
- (void)run:(NSString *)name;

// 不带参数带返回值的函数
- (NSString *)cry;

// 带参数带返回值的函数
- (NSString *)haha:(NSString *)name age:(NSString *)age;

@end
