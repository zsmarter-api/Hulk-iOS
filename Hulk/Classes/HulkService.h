//
//  HulkFPS.h
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/29.
//

#import <Foundation/Foundation.h>
@class HulkConfiguration;
typedef void(^ __nullable hulkInitBlock)(NSString * _Nullable tid);

NS_ASSUME_NONNULL_BEGIN

@interface HulkService : NSObject

+ (instancetype)defaultHULK;

/// 初始化
/// @param appId 开发者网站App的AppId
/// @param appSecret 开发者网站App的AppSecret
/// @param completionHandler 初始化回调
- (void)initWithAppId:(NSString *)appId
            appSecret:(NSString *)appSecret
    completionHandler:(hulkInitBlock)completionHandler;

/// 注册远程推送方法
/// @param completionHandler 回调
+ (void)registerForRemoteNotification:(void (^ __nullable)(BOOL success))completionHandler;

/// 注册本地推送：注册后，当在前台收到推送时，SDK内部将自动新增成本地通知
+ (void)registerForLocalNotification:(void (^ __nullable)(BOOL success))completionHandler;

/// application:didRegisterForRemoteNotificationsWithDeviceToken: 中调用
/// @param deviceToken deviceToken
+ (void)registerDeviceToken:(NSData *)deviceToken;

/// 收到推送透传消息
@property (nonatomic, copy) void (^receivePushHandler)(NSString *pushInfo);

/// 收到推送消息
@property (nonatomic, copy) void (^receivePushNotificationHandler)(NSString *pushInfo);

/// 收到撤销推送消息
@property (nonatomic, copy) void (^cancelhNotificationHandler)(NSString *taskId);

/// 心跳
@property (nonatomic, copy) void (^heartBeatHandler)(void);

@property (nonatomic, copy) void (^heartBeatErrorHandler)(void);

/// 收到DeviceToken
@property (nonatomic, copy) void (^receiveDeviceTokenHandler)(NSString *deviceToken);

/// 更新用户信息
/// @param configuration 配置信息
/// @param completionHandler 更新回调
- (void)updateUserInfo:(HulkConfiguration *)configuration
     completionHandler:(void (^)(void))completionHandler;

//处理收到的 APNs 消息，用于统计用户消息送达、消息点击事件
+ (void)handleRemoteNotification:(NSDictionary *)remoteInfo;

/**
 设置别名
 @param alias 别名
 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
- (void)setAlias:(NSString *)alias success:(void(^)(id result))successBlock error:(void(^)(NSString *error))errorBlock;

/// 关闭推送:建议不要使用，否则会断开Hulk自建通道，可能会影响推送性能
+ (void)setHulkOff;


/// 检测设置中推送功能是否开启
+ (void)notificationIsOpen:(void(^)(BOOL isOpen))completionHandler;

/// 打开日志
+ (void)setLogOn;

@end

NS_ASSUME_NONNULL_END
