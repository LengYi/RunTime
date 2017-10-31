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
    
    // 为Person动态添加一个C函数方法
    //class_addMethod([Person class], NSSelectorFromString(@"cFunc"),(IMP)cFunc), <#const char * _Nullable types#>)
}

int cFunc(int arg1,int arg2) {
    return arg1 + arg2;
}

@end
