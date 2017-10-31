//
//  ViewController.m
//  RunTime
//
//  Created by ice on 2017/10/31.
//  Copyright © 2017年 ice. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Person.h"
#import <objc/message.h>

/*
 *  使用 objc_msgSend 方法之前 【查找build setting -> 搜索msg -> objc_msgSend（YES --> NO）】
 *
*/
@interface ViewController ()

@end

@implementation ViewController

int cStyleFunc(id receiver, SEL sel, const void *arg1, const void *arg2) {
    NSLog(@"%s was called, arg1 is %@, and arg2 is %@",
          __FUNCTION__,
          [NSString stringWithUTF8String:arg1],
          [NSString stringWithUTF8String:arg1]);
    return 1;
}

int cFunc(id receiver, SEL sel,int a,int b){
    return a + b;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *p = objc_msgSend(objc_getClass("Person"),sel_registerName("alloc"));
    p = objc_msgSend(p, sel_registerName("init"));
    
    // 无参数无返回值的函数
    objc_msgSend(p, @selector(eat));
    
    // 带一个参数无返回值的函数调用
    ((void (*)(id,SEL,id))objc_msgSend)(p, @selector(run:),@"Jack");
    
    // 不带参数带返回值的函数
    NSString *retStr = ((id (*)(id,SEL))objc_msgSend)(p, @selector(cry));
    NSLog(@"retStr = %@ \n",retStr);
    
    // 带参数带返回值的函数
    retStr = ((id (*)(id,SEL,id,id))objc_msgSend)(p, @selector(haha:age:),@"Nick",@"25");
    NSLog(@"retStr = %@ \n",retStr);
    
    // 为Person动态添加一个C函数方法    i代表返回值int，@代表id类型对象，:代表选择子
    class_addMethod(p.class, NSSelectorFromString(@"cStyleFunc"), (IMP)cStyleFunc, "i@:r^vr^v");
    int value = ((int (*)(id, SEL, const void *, const void *))
                 objc_msgSend)((id)p,
                               NSSelectorFromString(@"cStyleFunc"),
                               "参数1",
                               "参数2");
    NSLog(@"value = %d",value);
    
    class_addMethod(p.class, NSSelectorFromString(@"cFunc"), (IMP)cFunc, "");
    value = ((int (*)(id, SEL,int,int))
             objc_msgSend)((id)p,
                           NSSelectorFromString(@"cFunc"),
                           100,
                           200);
    NSLog(@"value = %d",value);
    // 返回结构体的函数
    CGRect frame = ((CGRect (*)(id,SEL))objc_msgSend_stret)(p, @selector(cStruct));
    NSLog(@"frame = %@",NSStringFromCGRect(frame));
   
}


@end
