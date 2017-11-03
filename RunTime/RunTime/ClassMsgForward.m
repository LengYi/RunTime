//
//  ClassMsgForward.m
//  RunTime
//
//  Created by ice on 2017/11/3.
//  Copyright © 2017年 ice. All rights reserved.
//

#import "ClassMsgForward.h"
#import <objc/runtime.h>

/* 1.什么都没实现则默认调用  methodSignatureForSelector ->doesNotRecognizeSelector -> 闪退
 * 2.methodSignatureForSelector 实现了方法签名获取 则methodSignatureForSelector->forwardInvocation->新类处理消息(新类必须有方法的实现否则不会转发消息)
 */

@implementation ClassMsgForward

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"获取类方法签名");
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        Class bMeta = objc_getMetaClass(class_getName([B class]));
        signature = [[bMeta class] instanceMethodSignatureForSelector:aSelector];
    }
    return signature;
}

+ (void)doesNotRecognizeSelector:(SEL)aSelector{
    NSLog(@"类方法没实现");
}

+ (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"类消息转发");
    [anInvocation invokeWithTarget:[B class]];
}
@end


@implementation B
+ (void)test{
    NSLog(@"类B 中的 test 类方法");
}
@end
