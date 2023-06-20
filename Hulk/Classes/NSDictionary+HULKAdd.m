//
//  NSDictionary+HulkZSBirdAdd.m
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/29.
//

#import "NSDictionary+HULKAdd.h"

@implementation NSDictionary (HULKAdd)


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        return nil;
    }
    return dic;
}

@end
