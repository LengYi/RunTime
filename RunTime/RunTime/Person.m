//
//  Person.m
//  RunTime
//
//  Created by ice on 2017/10/31.
//  Copyright © 2017年 ice. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

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


// 拦截实例崩溃
void instanceMethod(id self,SEL _cmd){
    NSLog(@"动态添加实例方法实现避免崩溃。");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    class_addMethod([self class], @selector(instanceMethod), (IMP)instanceMethod, "v@:");
    return YES;
}

void classesMethod(id self,SEL _cmd){
    NSLog(@"动态添加类方法实现避免崩溃。");
}

// 拦截类方法奔溃
+ (BOOL)resolveClassMethod:(SEL)sel{
    Class meta = objc_getMetaClass(class_getName([self class]));
    class_addMethod([meta class], @selector(classesMethod), (IMP)classesMethod, "v@:");
    return YES;
}
@end
