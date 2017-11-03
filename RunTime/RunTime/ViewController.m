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
#import "MsgForward.h"
#import "ClassMsgForward.h"
#import "ATest.h"

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
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
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
//    CGRect frame = ((CGRect (*)(id,SEL))objc_msgSend_stret)(p, @selector(cStruct));
//    NSLog(@"frame = %@",NSStringFromCGRect(frame));
   
    // 使用IMP 函数指针直接调用方法
    SEL sel = @selector(haha:age:);
    Method method = class_getInstanceMethod(p.class, sel);
    IMP imp = method_getImplementation(method);
    NSString *str = ((id(*)(id, SEL,id,id))imp)(self, sel,@"Jack", @"18");
    NSLog(@"str = %@ \n",str);
    
    imp = [p methodForSelector:sel];
    str = ((id(*)(id, SEL,id,id))imp)(self, sel,@"Rouse", @"20");
    NSLog(@"str = %@ \n",str);
    
    // 模拟实例方法未实现导致的奔溃
    [p instanceMethod];

    // 模拟类方法未实现导致的奔溃
    [Person classesMethod];
    
    
    // 实例消息转发
    // 直接调用一个没实现的方法,则最后调用  doesNotRecognizeSelector 
    [[[MsgForward alloc] init] test];
    
    // 类消息转发
    [ClassMsgForward test];
    
    [self testRuntimeAPI];
    
    [self runtimeLibrary];
}

- (void)testRuntimeAPI{
    NSLog(@"\n \n ---------------testRuntimeAPI------------ ");
    // 获取类名
    const char *a = class_getName([ATest class]);
    NSLog(@"类名: %s \n",a);
    
    // 获取父类
    Class aSuper = class_getSuperclass([ATest class]);
    NSLog(@"获取父类: %s", class_getName(aSuper));
    
    // 判断是否是元类
    BOOL aMeta = class_isMetaClass([ATest class]);
    BOOL bMeta = class_isMetaClass(objc_getMetaClass("ATest"));
    NSLog(@"是否元类: %i  %i", aMeta, bMeta);
    
    // 类大小
    size_t aSize = class_getInstanceSize([ATest class]);
    NSLog(@"类大小: %zu", aSize);
    
    // 获取设置类版本
    class_setVersion([ATest class], 10);
    NSLog(@"获取类版本: %d", class_getVersion([ATest class]));
    
    // 获取工程中所有的class，包括系统class
    unsigned int count3 = 0;
    int classNum = objc_getClassList(NULL, count3);
    NSLog(@"%d", classNum);
    
    // 获取工程中所有的class的数量
    objc_copyClassList(&count3);
    NSLog(@"%d", count3);
    
    // 获取类实例成员变量，只能取到本类的，父类的访问不到
    Ivar aInstanceIvar = class_getInstanceVariable([ATest class], "strA");
    NSLog(@"%s",ivar_getName(aInstanceIvar));
    
    // 获取类成员变量，相当于class_getInstanceVariable(cls->isa, name)，感觉除非给metaClass添加成员，否则不会获取到东西
    Ivar aClassIvar = class_getClassVariable([ATest class], "strA");
    NSLog(@"%s", ivar_getName(aClassIvar));
    
    // 添加成员变量
    if (class_addIvar([ATest class], "intA", sizeof(int), log2(sizeof(int)), @encode(int))) {
        NSLog(@"绑定成员变量成功");
    }
    
    // 获取类中的ivar列表，count为ivar总数
    unsigned int count;
    Ivar *ivars = class_copyIvarList([ATest class], &count);
    NSLog(@"%i", count);
    
    // 获取某个名为"uIntA"的属性
    objc_property_t aPro = class_getProperty([ATest class], "uintA");
    NSLog(@"属性名称: %s", property_getName(aPro));
    
    // 获取类的全部属性
    class_copyPropertyList([ATest class], &count);
    NSLog(@"%i", count);
    
    
    // 创建objc_property_attribute_t，然后动态添加属性
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([NSString class])] UTF8String] };
    objc_property_attribute_t ownership0 = { "C", "" }; // C = copy
    objc_property_attribute_t ownership = { "N", "" }; //N = nonatomic
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", @"aNewProperty"] UTF8String] };  //variable name
    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
    if(class_addProperty([ATest class], "aNewProperty", attrs, 4)) {
        // 只会增加属性，不会自动生成set，get方法
        NSLog(@"绑定属性成功");
    }
    
    // 创建objc_property_attribute_t，然后替换属性
    objc_property_attribute_t typeNew = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([NSString class])] UTF8String] }; //type
    objc_property_attribute_t ownership0New = { "C", "" }; // C = copy
    objc_property_attribute_t ownershipNew = { "N", "" }; //N = nonatomic
    objc_property_attribute_t backingivarNew  = { "V", [[NSString stringWithFormat:@"_%@", @"uintA"] UTF8String] };  //variable name
    objc_property_attribute_t attrsNew[] = { typeNew, ownership0New, ownershipNew, backingivarNew };
    class_replaceProperty([ATest class], "uintA", attrsNew, 4);
    // 这有个很大的坑。替换属性指的是替换objc_property_attribute_t，而不是替换name。如果替换的属性class里面不存在，则会动态添加这个属性
    objc_property_t pro = class_getProperty([ATest class], "uintA");
    NSLog(@"123456   %s", property_getAttributes(pro));    // h
    // class_getIvarLayout、class_setIvarLayout、class_getWeakIvarLayout、class_setWeakIvarLayout用来设定和获取成员变量的weak、strong。参见http://blog.sunnyxx.com/2015/09/13/class-ivar-layout/
    
    
    
    // 动态创建一个类和其元类
    Class bClass = objc_allocateClassPair([NSObject class], "BTest", 0);
    // 添加成员变量
    if (class_addIvar(bClass,"intA", sizeof(int), log2(sizeof(int)), @encode(int))) {
        NSLog(@"绑定成员变量成功");
    }
    
    // 注册这个类，之后才能用
    objc_registerClassPair(bClass);
    
    // 销毁这个类和元类
    objc_disposeClassPair(bClass);
    
    
    // 添加protocol到class
    if(class_addProtocol([ATest class], @protocol(AProtocol))) {
        NSLog(@"绑定Protocol成功");
    }
    // 查看类是不是遵循protocol
    if(class_conformsToProtocol([ATest class], @protocol(AProtocol))) {
        NSLog(@"ATest遵循AProtocol");
    }
    
    // 获取类中的protocol
    unsigned int count2;
    Protocol *__unsafe_unretained  *aProtocol = class_copyProtocolList([ATest class], &count2);
    NSLog(@"%s", protocol_getName(aProtocol[0]));
}

- (void)runtimeLibrary{
    // 获取工程中所有的frameworks和dynamic libraries名称
    unsigned int count;
    const char **arr = objc_copyImageNames(&count);
    NSLog(@"%s", arr[0]);
    
    // 获取某个class所在的库名称
    const char *frameworkName = class_getImageName([UIImage class]);
    NSLog(@"%s", frameworkName);
    
    // 根据某个库名，获取该库所有的class
    const char **classArr = objc_copyClassNamesForImage(arr[0], &count);
    NSLog(@"%s", classArr[0]);
}
@end
