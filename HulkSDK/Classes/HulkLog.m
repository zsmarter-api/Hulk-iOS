//
//  HulkLog.m
//  Hulk
//
//  Created by Jessica mini on 2021/11/9.
//

#import "HulkLog.h"

@implementation HulkLog

static HulkLog *hulkLog = nil;
#pragma mark - 单例初始化方法
+ (instancetype)defaultLog
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (hulkLog == nil) {
            hulkLog = [[self alloc] init];
        }
    });
    return hulkLog;
}


@end
