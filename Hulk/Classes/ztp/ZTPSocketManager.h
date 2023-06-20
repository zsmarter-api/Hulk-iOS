//
//  ZTPSocketManager.h
//  ZTP-iOS
//
//  Created by 胡红星 on 2021/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define SOCKET_LOGIN_MSG_TAG     99

@class ZTPData;
@class GCDAsyncSocket;

typedef void(^ZTPDataConfigBlock)(ZTPData *data);

@protocol ZTPSocketDelegate <NSObject>

@optional

- (void)webSocket:(GCDAsyncSocket *)webSocket didLogin:(NSString *)url;
- (void)webSocketDidReceivedMessage:(NSString *)message type:(NSInteger)type subtype:(NSInteger)subtype;
- (void)webSocket:(GCDAsyncSocket *)webSocket onError:(NSError *)error;

@end

@interface ZTPSocketManager : NSObject

@property (nonatomic, strong, nullable) id <ZTPSocketDelegate> delegate;
@property (nonatomic, copy, readwrite, nonnull) NSString *server;
@property (nonatomic, assign, readwrite) NSInteger port;
@property (nonatomic ,assign) NSTimeInterval retryInterval;
@property (nonatomic, assign) NSTimeInterval heartBeatInterval;
@property (nonatomic, copy) NSData *(^deviceInfo)(void);
@property (nonatomic, assign) BOOL setTLS;
@property (nonatomic, assign, readonly) BOOL isConnected;

+ (instancetype)shareManager;
- (void)connect;
- (void)reconnnect;
- (void)disconnect;
- (void)disconnectByUser;
- (void)sendDataConfigBlock:(ZTPDataConfigBlock)configBlock;
- (void)submitUserInfo:(NSData *)userInfo;

@end

NS_ASSUME_NONNULL_END
