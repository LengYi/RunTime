//
//  ATest.h
//  RunTime
//
//  Created by ice on 2017/11/3.
//  Copyright © 2017年 ice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATest : NSObject
{
    NSString *strA;
}

@property (nonatomic,assign) NSUInteger uintA;
@end

@protocol AProtocol <NSObject>
- (void)aProtocolMethod;
@end
