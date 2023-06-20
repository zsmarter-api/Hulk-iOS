//
//  HulkSocketConfig.m
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/2.
//

#import "HULKSocketConfig.h"
#include <sys/sysctl.h>

@interface HULKSocketConfig ()

@end

@implementation HULKSocketConfig


#pragma mark - 获取socket url
+ (NSString *) getSocketUrl:(BOOL)isDebug {
    if (isDebug) {
        NSLog(@"url connect: %@", @"47.108.219.214:10639");
        return @"47.108.219.214:10639";
    }
    NSLog(@"url connect: %@", @"47.108.219.214:8443");
    return @"47.108.219.214:8443";
 }

+ (NSString *)getVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)platform {
 
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine
                                            encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)platformString:(NSString *)platform {
 
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone5s";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone6Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone6sPlus";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone7Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone8";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone8Plus";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone8Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhoneX";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhoneX";
    if ([platform  isEqualToString:@"iPhone11,8"])  return @"iPhoneXR";
    if ([platform  isEqualToString:@"iPhone11,2"])  return @"iPhoneXS";
    if ([platform  isEqualToString:@"iPhone11,4"])  return @"iPhoneXSMax";
    if ([platform  isEqualToString:@"iPhone11,6"])  return @"iPhoneXSMax";
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhoneXR";
    if ([platform isEqualToString:@"iPhone12,1"])   return @"iPhone11";
    if ([platform isEqualToString:@"iPhone12,3"])   return @"iPhone11Pro";
    if ([platform isEqualToString:@"iPhone12,5"])   return @"iPhone11ProMax";
    if ([platform isEqualToString:@"iPhone13,1"])   return @"iPhone12Mini";
    if ([platform isEqualToString:@"iPhone13,2"])   return @"iPhone12";
    if ([platform isEqualToString:@"iPhone13,3"])   return @"iPhone12Pro";
    if ([platform isEqualToString:@"iPhone13,4"])   return @"iPhone12ProMax";
    if ([platform isEqualToString:@"i386"])         return @"iPhoneSimulator";
    if ([platform isEqualToString:@"x86_64"])       return @"iPhoneSimulator";

    return @"iOS";
}


@end
