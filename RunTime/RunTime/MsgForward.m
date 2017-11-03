//
//  MsgForward.m
//  RunTime
//
//  Created by ice on 2017/11/3.
//  Copyright © 2017年 ice. All rights reserved.
//

#import "MsgForward.h"

// 实例消息转发
/* 1.什么都没实现则默认调用  methodSignatureForSelector ->doesNotRecognizeSelector -> 闪退
 * 2.methodSignatureForSelector 实现了方法签名获取 则methodSignatureForSelector->forwardInvocation->新类处理消息(新类必须有方法的实现否则不会转发消息)
 */
@implementation MsgForward

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"获取实例方法签名");
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        A *objc = [[A alloc] init];
        signature = [objc methodSignatureForSelector:aSelector];
    }
    return signature;
}

- (void)doesNotRecognizeSelector:(SEL)aSelector{
    NSLog(@"实例方法没实现");
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"实例消息转发");
    A *objc = [[A alloc] init];
    [anInvocation invokeWithTarget:objc];
}

@end

@implementation A

- (void)test{
    NSLog(@"类A 中的 test 实例方法");
}

@end
