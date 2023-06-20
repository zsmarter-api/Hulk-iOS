//
//  ZSBridSocket.h
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/31.
//

#import <Foundation/Foundation.h>
@class HulkConfiguration;

NS_ASSUME_NONNULL_BEGIN


typedef void(^HulkZSBridSocketBlock)(NSString * _Nullable message);
typedef void(^HulkHulkInitSocketBlock)(NSString * _Nullable tid);
@interface HULKSocket : NSObject

+ (instancetype)defaultSocket;

@property (nonatomic, assign) BOOL isConnected;

- (void)initWithZSBridConfiguration:(HulkConfiguration *)configuration
          completionHandler:(HulkHulkInitSocketBlock)completionHandler;

- (void)updateUserInfo:(HulkConfiguration *)configuration
                  completionHandler:(void (^)(void))completionHandler;

- (void)updateUserInfo:(HulkConfiguration *)configuration
                params:(NSDictionary *)params
     completionHandler:(void (^)(void))completionHandler;

- (void)reuqestAppUpate:(HulkConfiguration *)configuration
      completionHandler:(void (^)(void))completionHandler;

- (void)registerPushType:(NSInteger)type subType:(NSInteger)subType callBack:(HulkZSBridSocketBlock)block;

- (void)submitRecevicedMsg:(NSDictionary *)remoteInfo;

@property (nonatomic, copy) void (^heartBeatErrorHandler)(void);

- (void)setSocektOff;

@end

NS_ASSUME_NONNULL_END
