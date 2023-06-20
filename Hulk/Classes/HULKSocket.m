//
//  ZSBridSocket.m
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/31.
//

#import "HULKSocket.h"
#import "ZTPSocketManager.h"
#import "HulkConfiguration.h"
#import "HULKSocketConfig.h"
#import "YYCategories/YYCategories.h"
#import <MJExtension/MJExtension.h>
#import "ZTPData.h"
#import <GMObjC/GMSm3Utils.h>
#import "NSDictionary+HULKAdd.h"
#import "HulkLog.h"

#define kUUIDKey @"UUID"

const typedef void(^initHandler)(NSString *tid);
@interface HULKSocket () <ZTPSocketDelegate>
@property (nonatomic , copy) initHandler initCallBack;
@property (nonatomic, strong) NSMutableDictionary *registerTypes;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, copy) NSNumber *m_id_temp;

@property (nonatomic, strong) HulkConfiguration *configuration;
@end

@implementation HULKSocket
static HULKSocket *socket = nil;
#pragma mark - 单例初始化方法
+ (instancetype)defaultSocket
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (socket == nil) {
            socket = [[self alloc] init];
            socket.semaphore = dispatch_semaphore_create(1);
            socket.m_id_temp = nil;
        }
    });
    return socket;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [super allocWithZone:zone];
    });
    return socket;
}

- (id)copyWithZone:(NSZone *)zone
{
    return socket;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return socket;
}

- (void)initWithZSBridConfiguration:(HulkConfiguration *)configuration
                  completionHandler:(HulkHulkInitSocketBlock)completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        [[ZTPSocketManager shareManager] disconnect];
        NSString *url = configuration.socketUrl;
//        NSAssert([url isNotBlank], @"socketUrl 为必传字段");
        if (![url isNotBlank]) {
            url = [HULKSocketConfig getSocketUrl:NO];
        }
        [ZTPSocketManager shareManager].server = [url componentsSeparatedByString:@":"].firstObject;
        [ZTPSocketManager shareManager].port = [[url componentsSeparatedByString:@":"].lastObject intValue];
        [ZTPSocketManager shareManager].delegate = self;
        [ZTPSocketManager shareManager].heartBeatInterval = 55;
        [ZTPSocketManager shareManager].setTLS = configuration.setTLS;
        self.configuration = configuration;
        
        [[ZTPSocketManager shareManager] setDeviceInfo:^NSData * _Nonnull{
            NSTimeInterval timeStamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
            NSString *session = [[GMSm3Utils hashWithString:[NSString stringWithFormat:@"%@%@%@", configuration.appSecret, configuration.deviceId, @(timeStamp)]] lowercaseString];
            NSMutableDictionary *param = @{
                @"device_id"    : configuration.deviceId,
                @"bundle"       : configuration.bundle,
                @"session"      : session,
                @"appkey"       : configuration.appId,
                @"platform"     : configuration.platform,
                @"model"        : configuration.model,
                @"version"      : configuration.appVersion,
                @"sys_ver" : configuration.systemVersion,
                @"ts" : @(timeStamp),
                @"third_party" : configuration.third_party ? [HulkThirdPartyModel mj_keyValuesArrayWithObjectArray:configuration.third_party] : @[],
                
            }.mutableCopy;
            NSString *deviceToken = configuration.tokenId;
            if (deviceToken) {
                [param setValue:deviceToken forKey:@"token_id"];
            }
            if (configuration.alias) {
                [param setValue:configuration.alias forKey:@"alias"];
            }
            HulkLog(@"初始化参数:%@", param);
            return [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
        }];
        [[ZTPSocketManager shareManager] connect];
        @weakify(self);
        self.initCallBack = ^(NSString *tid) {
            completionHandler(tid);
            @strongify(self);
            dispatch_semaphore_signal(self.semaphore);
            if (tid.length > 0) {
                [self updateUserInfo:configuration completionHandler:^{
                    
                }];
            }
        };
    });
    
}

- (void)reuqestAppUpate:(HulkConfiguration *)configuration
      completionHandler:(void (^)(void))completionHandler {
    //t12s1
    NSString *timer = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSDictionary *dic = @{@"ts" : timer, @"dt" : configuration.dt ?: @"1"};
    [[ZTPSocketManager shareManager] sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 12;
        data.subType = 1;
        data.ack = 1;
        data.encrypt = NO;
        data.data = [dic mj_JSONData];
    }];
    completionHandler();
}

- (void)updateUserInfo:(HulkConfiguration *)configuration
     completionHandler:(void (^)(void))completionHandler {
    //t1s9
    NSMutableDictionary *param = @{
        @"device_id"    : configuration.deviceId,
        @"via" : configuration.via
    }.mutableCopy;
    configuration.tokenId ? [param setValue:configuration.tokenId forKey:@"token_id"] : nil;
    configuration.jpushId ? [param setValue:configuration.jpushId forKey:@"jpush_id"] : nil;
    configuration.apnsId ? [param setValue:configuration.apnsId forKey:@"apns_id"] : nil;
    configuration.location ? [param setValue:configuration.location forKey:@"location"] : nil;
    configuration.uid ? [param setValue:configuration.uid forKey:@"uid"] : nil;
    configuration.phone ? [param setValue:configuration.phone forKey:@"phone"] : nil;
    configuration.ext ? [param setValue:configuration.ext forKey:@"ext"] : nil;
    configuration.alias ? [param setValue:configuration.alias forKey:@"alias"] : nil;
    configuration.third_party ? [param setValue:[HulkThirdPartyModel mj_keyValuesArrayWithObjectArray:configuration.third_party] forKey:@"third_party"] : nil;
    [[ZTPSocketManager shareManager] sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 1;
        data.subType = 9;
        data.ack = 1;
        data.encrypt = NO;
        data.data = [param mj_JSONData];
        HulkLog(@"更新用户信息参数:%@", param);
    }];
    completionHandler();
}

- (void)updateUserInfo:(HulkConfiguration *)configuration
                params:(NSDictionary *)params
     completionHandler:(void (^)(void))completionHandler {
    //t1s9
    NSMutableDictionary *param = @{
        @"device_id"    : configuration.deviceId?:self.configuration.deviceId,
    }.mutableCopy;
    [param addEntriesFromDictionary:params];
    [[ZTPSocketManager shareManager] sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 1;
        data.subType = 9;
        data.ack = 1;
        data.encrypt = NO;
        data.data = [param mj_JSONData];
    }];
    completionHandler();
}

#pragma mark -- HulkWebSocketDelegate methods

- (void)webSocket:(GCDAsyncSocket *)webSocket didLogin:(NSString *)url {
    self.isConnected = YES;
    NSDictionary *dic = [NSDictionary dictionaryWithJsonString:url];
    NSString *tid = @"";
    if ([dic isKindOfClass:[NSDictionary class]] && [dic containsObjectForKey:@"tid"]) {
        tid = dic[@"tid"];
    }
    self.initCallBack(tid);
    if (self.m_id_temp) {
        [self submitRecevicedMid:self.m_id_temp];
        self.m_id_temp = nil;
    }
    [self submitClosedMsg:[self checkcurrentUserNotificationType]];
}

- (void)webSocketDidReceivedMessage:(NSString *)message type:(NSInteger)type subtype:(NSInteger)subtype {
    HulkLog(@"webSocketDidReceivedMessage = %@ type = %ld ,subtype = %ld", message, type, subtype);
    NSString *key = [NSString stringWithFormat:@"type%ldsubType%ld", type, subtype];
    if ([self.registerTypes.allKeys containsObject:key]) {
        HulkZSBridSocketBlock block = self.registerTypes[key];
        block(message);
    }
}

- (void)webSocket:(GCDAsyncSocket *)webSocket onError:(NSError *)error {
    self.initCallBack(@"");
    if (self.heartBeatErrorHandler) {
        self.heartBeatErrorHandler();
    }
}

- (void)registerPushType:(NSInteger)type subType:(NSInteger)subType callBack:(HulkZSBridSocketBlock)block {
    NSString *key = [NSString stringWithFormat:@"type%ldsubType%ld",(long) type, subType];
    [self.registerTypes setValue:block forKey:key];
}

- (NSMutableDictionary *)registerTypes {
    if (!_registerTypes) {
        _registerTypes = @{}.mutableCopy;
    }
    return _registerTypes;
}

- (void)submitRecevicedMsg:(NSDictionary *)remoteInfo {
    if (remoteInfo && [remoteInfo isKindOfClass:[NSDictionary class]]) {
        if ([remoteInfo containsObjectForKey:@"m_id"]) {
            if ([ZTPSocketManager shareManager].isConnected) {
                [self submitRecevicedMid:remoteInfo[@"m_id"]];
            } else {
                self.m_id_temp = remoteInfo[@"m_id"];
                [[ZTPSocketManager shareManager] reconnnect];
            }
        }
    }
}

//上报t7s1
- (void)submitRecevicedMid:(NSNumber *)m_id {
    //上报t7s1
    NSMutableDictionary *param = @{
        @"m_id"    : [NSString stringWithFormat:@"%@", m_id],
    }.mutableCopy;
    [[ZTPSocketManager shareManager] sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 7;
        data.subType = 1;
        data.ack = 1;
        data.encrypt = NO;
        data.data = [param mj_JSONData];
    }];
    HulkLog(@"上报已送达成功");
}

#pragma mark -- 查看是否关闭了通知 methods

- (BOOL)checkcurrentUserNotificationType {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        BOOL closed = [[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone;
        return closed;
    } else {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        BOOL closed = UIRemoteNotificationTypeNone == type;
        return closed;
    }
}

//上报t7s3
- (void)submitClosedMsg:(BOOL)closed {
    NSMutableDictionary *param = @{
        @"notification"    : closed ? @"false" : @"true",
    }.mutableCopy;
    [[ZTPSocketManager shareManager] sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 7;
        data.subType = 3;
        data.ack = 1;
        data.encrypt = NO;
        data.data = [param mj_JSONData];
    }];
}

- (void)setSocektOff {
    [[ZTPSocketManager shareManager] disconnectByUser];
}

@end
