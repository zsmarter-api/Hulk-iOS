//
//  HulkFPS.m
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/29.
//

#import "HulkService.h"
#import "ZTPSocketManager.h"
#import "HULKSocketConfig.h"
#import "YYCategories/YYCategories.h"
#import "HULKLocalNotification.h"
#import "NSDictionary+HULKAdd.h"
#import "HULKConfiguration.h"
#import "HULKSocket.h"

#import <UserNotifications/UserNotifications.h>
#import "HulkLog.h"


const typedef void(^initHandler)(void);
const typedef void(^t1s5Handler)(void);
const typedef void(^t1s6Handler)(void);

@interface HulkService () <ZTPSocketDelegate,UNUserNotificationCenterDelegate>

@property (nonatomic, copy) initHandler initCallBack;
@property (nonatomic, copy) t1s5Handler t1s5CallBack;
@property (nonatomic, copy) t1s6Handler t1s6CallBack;

@end

@implementation HulkService

static HulkService *fps = nil;
#pragma mark - 单例初始化方法
+ (instancetype)defaultHULK
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (fps == nil) {
            fps = [[self alloc] init];
            [fps registerPushtype];
        }
    });
    return fps;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fps = [super allocWithZone:zone];
    });
    return fps;
}

- (id)copyWithZone:(NSZone *)zone
{
    return fps;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return fps;
}

- (void)initWithAppId:(NSString *)appId appSecret:(NSString *)appSecret completionHandler:(hulkInitBlock)completionHandler {
    HULKConfiguration *config = [HULKConfiguration defaultConfiguration];
    config.appId = appId;
    config.appSecret = appSecret;
    [[HULKSocket defaultSocket] initWithZSBridConfiguration:config completionHandler:^(NSString * _Nullable tid) {
        if (completionHandler) {
            completionHandler(tid);
        }
    }];
};

- (void)initWithHulkConfiguration:(HULKConfiguration *)configuration completionHandler:(hulkInitBlock)completionHandler {
    [[HULKSocket defaultSocket] initWithZSBridConfiguration:configuration completionHandler:^(NSString * _Nullable tid) {
        completionHandler(tid);
    }];
}

- (void)updateUserInfo:(HULKConfiguration *)configuration
     completionHandler:(void (^)(void))completionHandler {
    if ([HULKSocket defaultSocket].isConnected) {
        [[HULKSocket defaultSocket] updateUserInfo:configuration completionHandler:completionHandler];
    } else {
        [[HULKSocket defaultSocket] initWithZSBridConfiguration:configuration completionHandler:^(NSString * _Nullable tid) {
            completionHandler();
        }];
    }
}

- (void)registerPushtype {
    [[HULKSocket defaultSocket] registerPushType:1 subType:5 callBack:^(NSString * _Nullable message) {
        self.t1s5CallBack();
    }];
    [[HULKSocket defaultSocket] registerPushType:1 subType:6 callBack:^(NSString * _Nullable message) {
        self.t1s6CallBack();
    }];
    [[HULKSocket defaultSocket] registerPushType:7 subType:4 callBack:^(NSString * _Nullable message) {
        if (self.receivePushHandler) {
            self.receivePushHandler(message);
        }
    }];
    [[HULKSocket defaultSocket] registerPushType:7 subType:2 callBack:^(NSString * _Nullable message) {
        HULKLocalNotification *localNotification = [[HULKLocalNotification alloc] init];
        [localNotification addNotification:[NSDictionary dictionaryWithJsonString:message]];
        if (self.receivePushNotificationHandler) {
            self.receivePushNotificationHandler(message);
        }
    }];
    
    [[HULKSocket defaultSocket] registerPushType:2 subType:1 callBack:^(NSString * _Nullable message) {
        if (self.heartBeatHandler) {
            self.heartBeatHandler();
        }
    }];
    
    [[HULKSocket defaultSocket] setHeartBeatErrorHandler:^{
        if (self.heartBeatErrorHandler) {
            self.heartBeatErrorHandler();
        }
    }];
    
    [[HULKSocket defaultSocket] registerPushType:7 subType:6 callBack:^(NSString * _Nullable message) {
        HULKLocalNotification *localNotification = [[HULKLocalNotification alloc] init];
        NSDictionary *param = [NSDictionary dictionaryWithJsonString:message];
        NSLog(@"t7s6===%@", message);
        if (![param containsObjectForKey:@"task_id"]) {
            return;
        }
        NSString *taskId = [NSString stringWithFormat:@"%@", param[@"task_id"]];
        [localNotification cancleNotification:taskId];
        if (self.cancelhNotificationHandler) {
            self.cancelhNotificationHandler(taskId);
        }
    }];
}

+ (void)setLogOn {
    [HulkLog defaultLog].isSetOn = YES;
}
    
+ (void)registerForRemoteNotification:(void (^)(BOOL success))completionHandler {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                            });
                            if (completionHandler) {
                                completionHandler(YES);
                            }
                        }
                    }];
                }
            }];
        }
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        if (@available(iOS 8.0, *)) {
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            } else {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
            }
        }
    }
}

+ (void)registerForLocalNotification:(void (^)(BOOL success))completionHandler {
    if (@available(iOS 10.0, *)) {
        UNAuthorizationOptions options = UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge;
        UNUserNotificationCenter.currentNotificationCenter.delegate = [HulkService defaultHULK];
        [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {           
                HulkLog(@"允许授权");
                if (completionHandler) {
                    completionHandler(YES);
                }
            } else {
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"deviceToken : %@",hexToken);
    [[NSUserDefaults standardUserDefaults] setObject:hexToken forKey:@"HulkPushDeviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    HULKConfiguration *config = [HULKConfiguration defaultConfiguration];
    if ([config.deviceId isNotBlank] && [config.appId isNotBlank] && [config.appSecret isNotBlank]) {
        [[HulkService defaultHULK] updateUserInfo:config completionHandler:^{
        }];
    }
    if ([HulkService defaultHULK].receiveDeviceTokenHandler) {
        [HulkService defaultHULK].receiveDeviceTokenHandler(config.apnsId);
    }
}

// 在前台时 收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

- (void)setAlias:(NSString *)alias success:(void(^)(id result))successBlock error:(void(^)(NSString *error))errorBlock {
    HULKConfiguration *config = [HULKConfiguration defaultConfiguration];
    
    [[HULKSocket defaultSocket] updateUserInfo:config params:@{@"alias" : alias} completionHandler:^{
        successBlock(@"设置成功");
    }];
}

+ (void)handleRemoteNotification:(NSDictionary *)remoteInfo {
    [[HULKSocket defaultSocket] submitRecevicedMsg:remoteInfo];
}

+ (void)setHulkOff {
    [[HULKSocket defaultSocket] setSocektOff];
}

+ (void)notificationIsOpen:(void(^)(BOOL isOpen))completionHandler {
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusAuthorized:
                    completionHandler(YES);
                    break;
                case UNAuthorizationStatusDenied:{
                    completionHandler(NO);
                    break;
                }
                default:
                    completionHandler(NO);
            }
        }];
    } else {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone == setting.types) {
            completionHandler(NO);
        } else {
            completionHandler(YES);
        }
    }
}


@end
