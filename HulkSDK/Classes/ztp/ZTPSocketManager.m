//
//  ZTPSocketManager.m
//  ZTP-iOS
//
//  Created by 胡红星 on 2021/3/17.
//

#import "ZTPSocketManager.h"
#import "NSData+Tools.h"
#import "NSData+YYAdd.h"
#import "GCDAsyncSocket.h"
#import "GMSm4Utils.h"
#import "ZTPData.h"
#import "HulkLog.h"

#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
#define NSLog(...)
#endif

#define kIV @"00000000000000000000000000000000"

enum {
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
    SocketOfflineByNetWork,  // 用户主动cut
};

@interface ZTPSocketManager () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSOperationQueue *delegateQueue;
@property (nonatomic, copy) NSString *t1s2Md5Str;
@property (nonatomic, copy) NSData * t1s1RandomData;
@property (nonatomic, copy) NSTimer *pingTimer;
@property (nonatomic, copy) NSDate *lastReceiveMsgTime;
@property (nonatomic, strong) NSData *userInfo;
@property (nonatomic, copy) NSString *encryptKey;

@end

@implementation ZTPSocketManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    static ZTPSocketManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSExtensionHostDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [manager disconnect];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSExtensionHostWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([manager.socket.userData longValue] != SocketOfflineByUser) {
                [manager reconnnect];
            }
        }];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.retryInterval = 5;
        self.heartBeatInterval = 5;
    }
    return self;
}

- (void)connect
{
    HulkLog(@"Hulk socket start connect to %@:%@", self.server, @(self.port));
    if (self.socket.isConnected) {
        return;
    }
    NSError *error = nil;
    if (!self.socket) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    [self.socket connectToHost:self.server onPort:self.port error:&error];
    if(error) {
        HulkLog(@"Hulk socket connect failed, %@", error.localizedDescription);
    }
}

- (void)disconnectByUser {
    [self.socket setUserData:[NSString stringWithFormat:@"%d", SocketOfflineByUser]];
    [self disconnect];
}

-(void)disconnect
{
    if (!self.socket || !self.socket.isConnected) {
        return;
    }
    HulkLog(@"Hulk socket start disconnect");
    [self.socket disconnect];
}

- (BOOL)isConnected {
    return self.socket && self.socket.isConnected;
}

- (void)reconnnect
{
    if (self.socket.isConnected) {
        return;
    }
    [self.socket disconnect];
    HulkLog(@"Hulk socket start reconnect");
    [self connect];
}

#pragma  mark - Send data

/**
 握手，T1S1
 */
- (void)handshake
{
    HulkLog(@"Hulk socket do handshake");
    self.t1s1RandomData = [NSData generateSocketT1S1Data];
    [self sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 0x01;
        data.subType = 0x01;
        data.ack = 0x1;
        data.encrypt = 0x0;
        data.data = self.t1s1RandomData;
    } tag:SOCKET_LOGIN_MSG_TAG];
}

- (void)sendHeartBeat
{
    HulkLog(@"Hulk socket send heartbeat");
    NSDate *currentDate = [NSDate date];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:_lastReceiveMsgTime];
    if(time > self.heartBeatInterval * 2.1) {
        [self reconnnect];
        return;
    }
    [self sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 0x02;
        data.subType = 0x01;
        data.ack = 0x1;
        data.encrypt = 0x0;
        data.data = [NSData new];
    } tag:100];
}

/**
 提交设备信息，T1S3
 */
- (void)submitDeviceInfo:(NSData *)deviceInfo
{
    [self sendDataConfigBlock:^(ZTPData * _Nonnull data) {
        data.type = 0x01;
        data.subType = 0x03;
        data.ack = 0x1;
        data.encrypt = 0x2;
        data.data = deviceInfo;
    } tag:SOCKET_LOGIN_MSG_TAG];
}

/**
 提交用户信息 T1S9
 */
- (void)submitUserInfo:(NSData *)userInfo
{
    if (!userInfo) return;
    
    self.userInfo = userInfo;
    if(_socket.isConnected) {
        [self sendDataConfigBlock:^(ZTPData * _Nonnull data) {
            data.type = 0x01;
            data.subType = 0x09;
            data.ack = 0x0;
            data.encrypt = 0x2;
            data.data = userInfo;
        } tag:SOCKET_LOGIN_MSG_TAG];
    }
}

- (void)sendDataConfigBlock:(ZTPDataConfigBlock)configBlock
{
    ZTPData *data = [[ZTPData alloc] init];
    configBlock(data);
    NSData *socketData = data.generateSocketData;
    [self.socket writeData:socketData withTimeout:-1 tag:0];
}

- (void)sendDataConfigBlock:(ZTPDataConfigBlock)configBlock tag:(long)tag
{
    ZTPData *data = [[ZTPData alloc] init];
    configBlock(data);
    NSData *socketData = data.generateSocketData;
    [self.socket writeData:socketData withTimeout:-1 tag:tag];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    HulkLog(@"Hulk socket did connect");
    if (self.setTLS) {
        [sock startTLS:nil];
    }
    [self.socket readDataWithTimeout:-1 tag:SOCKET_LOGIN_MSG_TAG];
    [self handshake];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)t
{
    self.lastReceiveMsgTime = [NSDate date];
    [self.socket readDataWithTimeout:-1 tag:t];
    @try {
        ZTPData *message = [[ZTPData alloc] initWithData:data];
        HulkLog(@"Hulk socket did read data type %@ subtype %@ ack %@ seq %@", @(message.type), @(message.subType), @(message.ack), @(message.seq));
        if (message.ack == 1) {
            [self sendDataConfigBlock:^(ZTPData * _Nonnull data) {
                data.type = message.type;
                data.subType = message.subType;
                data.ack = 0x2;
                data.seq = message.seq;
                data.encrypt = 0x0;
                data.data = [NSData new];
            } tag:SOCKET_LOGIN_MSG_TAG];
        }
        if (message.type == 1 && message.subType == 2) {
            self.encryptKey =  [NSData convertDataToHexStr:message.data];
            NSData *deviceInfo = self.deviceInfo? self.deviceInfo() : nil;
            if (deviceInfo) {
                NSData *encryptDeviceInfo = [GMSm4Utils cbcEncryptData:deviceInfo key:self.encryptKey IV:kIV];
                [self submitDeviceInfo:encryptDeviceInfo];
            }
        } else if(message.type == 1 && message.subType == 3) {
            [self sendHeartBeat];
            [self submitUserInfo:self.userInfo];
            if (self.pingTimer) {
                [self.pingTimer invalidate];
                self.pingTimer = nil;
            }
            _pingTimer = [NSTimer timerWithTimeInterval:self.heartBeatInterval target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_pingTimer forMode:NSRunLoopCommonModes];
            if([_delegate respondsToSelector:@selector(webSocket:didLogin:)]){
                NSString *data = [[NSString alloc] initWithData:message.data encoding:NSUTF8StringEncoding];
                [_delegate webSocket:_socket didLogin:data];
                self.socket.userData = [NSString stringWithFormat:@"%d", SocketOfflineByServer];
            }
        } else {
            NSString *data = [[NSString alloc] initWithData:message.data encoding:NSUTF8StringEncoding];
            if([_delegate respondsToSelector:@selector(webSocketDidReceivedMessage:type:subtype:)]){
                [_delegate webSocketDidReceivedMessage:data type:message.type subtype:message.subType];;
            }
        }
    } @catch (NSException *exception) {
        HulkLog(@"Hulk socket exception: %@", exception.description);
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    HulkLog(@"Hulk socket did disconnect");
    if ([_delegate respondsToSelector:@selector(webSocket:onError:)]) {
        [_delegate webSocket:sock onError:err];
    }
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    if ([sock.userData longValue] != SocketOfflineByUser) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reconnnect];
        });
    }
}

@end
