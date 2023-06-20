//
//  ZSBirdConfiguration.m
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/31.
//

#import "HULKConfiguration.h"
#import "HULKSocketConfig.h"
#import "YYCategories/YYCategories.h"
#import "HulkUUID.h"

@interface HULKConfiguration ()

@property (nonatomic, copy, readwrite) NSString *bundle;
@property (nonatomic, copy, readwrite) NSString *session;
@property (nonatomic, copy, readwrite) NSString *platform;//平台iOS/android
@property (nonatomic, copy, readwrite) NSString *brand;//厂商/品牌;
@property (nonatomic, copy, readwrite) NSString *systemVersion;//操作系统版本
@property (nonatomic, copy, readwrite) NSString *model;//机型
@property (nonatomic, copy, readwrite) NSString *via;//网络

@end

@implementation HULKConfiguration

+ (instancetype )defaultConfiguration {
    static HULKConfiguration *configuration =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (configuration ==nil) {
            configuration = [[self alloc] init];
            configuration.bundle = [[NSBundle mainBundle] bundleIdentifier];
            configuration.platform = @"iOS";
            configuration.brand = [UIDevice currentDevice].systemName;
            configuration.appVersion = [HULKSocketConfig getVersion];
            configuration.systemVersion = [UIDevice currentDevice].systemVersion;
            configuration.model = [HULKSocketConfig platformString:[HULKSocketConfig platform]];
            configuration.via = @"4G";
            configuration.deviceId = [HulkUUID getUUID];
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"HulkPushDeviceToken"];
            if ([deviceToken isNotBlank]) {
                configuration.apnsId = deviceToken;
            }
        }
    });
    return configuration;
}

- (NSString *)apnsId {
    return _apnsId ?: @"";
}

@end
