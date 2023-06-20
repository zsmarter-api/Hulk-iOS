# Hulk SDK接入文档



## Hulk介绍

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h2ludlakd9j211q0iidh9.jpg" alt="IMG_4448" style="zoom:50%;" />

从上图可以看出，Hulk 包括 2 个部分，APNs 推送（代理），与 Hulk 应用内消息。

红色部分是 APNs 推送，Hulk 代理开发者的应用（需要基于开发者提供的应用证书），向苹果 APNs 服务器推送。由 APNs Server 推送到 iOS 设备上。

蓝色部分是 Hulk 应用内推送部分，即 App 启动时，内嵌的 Hulk SDK 会开启长连接到 Hulk Server，从而 Hulk Server 可以推送消息到 App 里。

### APNs 通知

APNs 通知：是指通过向 Apple APNs 服务器发送通知，到达 iOS 设备，由 iOS 系统提供展现的推送。用户可以通过 IOS 系统的 “设置” >> “通知” 进行设置，开启或者关闭某一个 App 的推送能力。

Hulk SDK 不负责 APNs 通知的展现，只是向 Hulk 服务器端上传 Device Token 信息，Hulk 服务器端代理开发者向 Apple APNs 推送通知。

### 应用内消息

应用内消息：Hulk  SDK 提供的应用内消息功能，在 App 在前台时能够收到推送下来的消息。App 可使用此功能来做消息下发动作。

此消息不经过 APNs 服务器，完全由 Hulk 提供功能支持。

### APNs 通知与应用内消息对比

如果只需要发送通知，则可以忽略应用内消息的处理。对于两种消息的代码处理可以参考 API 部分的描述。

Hulk 支持同时一次调用同时推送 APNs 通知与 Hulk 应用内消息。这在某些应用场景里是有意义的。

|                | APNS                                                         | 应用内消息                                                   |
| :------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 推送原则       | 由 Hulk 服务器发送至 APNs 服务器，再下发到手机。             | 由 Hulk 直接下发，每次推送都会尝试发送，如果用户在线则立即收到。否则保存为离线。 |
| 离线消息       | 离线消息由 APNs 服务器缓存按照 Apple 的逻辑处理。            | 用户不在线 Hulk server 会保存离线消息，时长默认保留一天。离线消息保留 5 条。 |
| 推送与证书环境 | 应用证书和推送指定的 iOS 环境匹配才可以收到。                | 自定义消息与 APNs 证书环境无关。                             |
| 接收方式       | 应用退出，后台以及打开状态都能收到 APNs。                    | 需要应用打开，与 Hulk 建立连接才能收到。                     |
| 展示效果       | 如果应用后台或退出，会有系统的 APNs 提醒。如果应用处于打开状态，则不展示，iOS 10 开始可实现前台展示。 | 非 APNs，默认不展示。可通过后管平台按需配置。                |
| 处理函数       | Apple 提供的接口：[详见使用](#使用)                          | Hulk 提供的接口：[详见使用](#使用)                           |



***



## Hulk接入

### 导入方式

```一、推荐使用 CocoaPods 接入```
1、在 Podfile 文件中，使用```pod 'Hulk'``` 添加依赖。

由于目前Hulk未发到github上，目前需要接入阿里云源，如下：

```shell
source 'https://codeup.aliyun.com/zsmarter/iOS/Spec.git'
pod 'Hulk'
```

2、执行 `pod install` 即可完成接入。

```二、手动集成```

1、下载 *[Hulk.framework]()*

2、修改配置General中修改Frameworks,Libraries,and Embedded Content中Hulk.framework为*Embed & Sign*如下图：

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h2ltp0djc3j214y0u0jty.jpg" alt="image-20220523165046233" style="zoom:40%;" />

### 初始化推送服务

#### 添加头文件

```objc
#import <Hulk/HulkSDK.h>
```

#### AppDelegate中配置

- AppDelegate中注册本地通知、远程通知以及将deviceToken传给Hulk，用于APNs推送。

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [HulkService registerForRemoteNotification:nil];
    [HulkService registerForLocalNotification:nil];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [HulkService registerDeviceToken:deviceToken];
}
```

#### 添加初始化代码

```objc
HulkService *hulk = [HulkService defaultHULK];
NSLog(@"HulkService_初始化");
HULKConfiguration *config = [HULKConfiguration defaultConfiguration];
config.appKey = @"xxxx";// appKey，后管平台生成
config.appSecret = @"xxx";// appSecret，后管平台生成
[hulk initWithHulkConfiguration:config completionHandler:^(NSString * _Nullable tid) {
    NSLog(@"Hulk初始化成功==%@", tid);
}];
```

#### 更新用户数据

```objective-c
HulkService *hulk = [HulkService defaultHULK];
HULKConfiguration *config = [HULKConfiguration defaultConfiguration];
config.appKey = @"xxxx";// appKey，后管平台生成
config.appSecret = @"xxx";// appSecret，后管平台生成
//以下数据均为非必填，用户根据需要配置
config.location = @"成都市";// 位置，“成都市”,如果您需要通过位置筛选推送对象，传此字段
config.uid = @"1234567890";// 用户id，如果您需要通过自定义用户id筛选推送对象，传此字段
config.apnsId = [HULKConfiguration defaultConfiguration].apnsId;//请确保已在AppDelegate中已传给Hulk
config.alias = "alias";
[hulk updateUserInfo:config completionHandler:^{
    //Hulk用户信息成功成功
}];
```

### 验证推送结果

- 集成完成后，真机调试该项目，如果控制台输出以下回调日志则代表您已经集成成功。

  ```objc
  [hulk initWithHulkConfiguration:config completionHandler:^(NSString * _Nullable tid) {
    NSLog(@"Hulk初始化成功==%@", tid);
  }];
  ```

- 获取日志中的 tid，并在Hulk后管平台 [创建推送](http://hulk.zsmarter.com/hulkx/#/Mgt/createPush) 体验通知推送服务。

- 推送完成后，你可以在 [消息列表](http://hulk.zsmarter.com/hulkx/#/Mgt/messageList/index) 中查看推送结果、推送渠道、送达率等详细数据。

### 使用

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h2beiezcllj210o0u0ac3.jpg" alt="image-20220517143824652" style="zoom: 33%;" />

上图为后管平台单条推送界面

- 当用户选择“通知消息”时，如果App在前台，Hulk会通过Hulk server下达推送，客户端以本地通知形式通知；如果App在后台，则通过APNs通道推送，在这两种情况如果您需要处理推送消息，请在系统回调方法中进行处理:

```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;//iOS 7 及以上的系统版本

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler//iOS 10 及以上的系统版本
```

- 当用户选择“透传消息”，App在前台时会在回调方法中收到消息：

```objc
[HulkService defaultHULK].receivePushHandler = ^(NSString * _Nonnull pushInfo) {
    //收到推送透传消息
};
```



### 统计消息送达、消息点击

如需统计消息送达、消息点击，需要调用	```+ (void)handleRemoteNotification:(NSDictionary *)remoteInfo;```

```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [HulkService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    [HulkService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [HulkService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    [HulkService handleRemoteNotification:notification.userInfo];
}
```

### 获取设置中推送的开关状态

如需检测应用是否开启了推送，可调用以下API:

```objective-c
+ (void)notificationIsOpen:(void(^)(BOOL isOpen))completionHandler;//isOpen为Yes代表已开启
```



## 权限与合规

### 隐私政策

开发者请务必在《隐私政策》中向用户告知应用使用了Hulk SDK，参考条款如下：
**SDK名称**：Hulk SDK
**服务类型**：消息推送服务
**SDK收集个人信息类型**：

- 设备信息（IMEI）：用于识别唯一用户，保证消息推送的精准送达；优化推送通道资源，我们会根据设备上不同APP的活跃情况，整合消息推送的通道资源，为开发者提高消息送达率；为开发者提供智能标签以及展示业务统计信息的服务


⚠️ **同意隐私政策再初始化 SDK**

请务必确保终端用户完成同意《隐私政策》操作之后，再调用 SDK 的初始化接口及其他业务接口，进行 SDK 初始化。

 **必选权限**

- 以下为必选权限，必须配置以下权限才能满足基本的推送功能能力

  ```objective-c
  [HulkService registerForRemoteNotification:nil];
  ```



# 附：iOS 证书设置指南

## 创建应用程序 ID

- 登陆 [苹果开发者网站](https://developer.apple.com/) 进入开发者账户。

![截屏2022-01-06 上午11.09.00](https://tva1.sinaimg.cn/large/008i3skNly1gy3s0m35vwj31oe0u0wla.jpg)
- 从开发者账户页面左侧入口进入 “Certificates, IDs & Profiles” 页面。

<img src="https://tva1.sinaimg.cn/large/008i3skNly1gy3s5prcarj30gs18imyn.jpg" alt="截屏2022-01-06 上午11.12.10" style="zoom:40%;" />

- 创建 App ID，填写 App ID 的 NAME 和 Bundle ID（如果 ID 已经存在可以直接跳过此步骤）。

<img src="https://tva1.sinaimg.cn/large/008i3skNly1gy3sbq5f0qj31fu0aigms.jpg" alt="截屏2022-01-06 上午11.17.30" style="zoom:40%;" />

```
    注: 此处需要指定具体的 Bundle ID 不要使用通配符。
```

<img src="https://tva1.sinaimg.cn/large/008i3skNly1gyr5n9439bj31mk0letb5.jpg" alt="008i3skNly1gy3sfcr782j31mk0lejtt" style="zoom:50%;" />

- 为 App 开启 Push Notification 功能。如果是已经创建的 App ID 也可以通过设置开启 Push Notification 功能。

![appid_service](https://tva1.sinaimg.cn/large/008i3skNly1gy3sigo1exj311v0o3abu.jpg)

- 填写好以上属性后，点击 “Continue”，确认 AppId 属性的正确性，点击 “Register”，注册 AppId 成功。

## 鉴权方式的配置

Hulk官网应用的鉴权信息一旦配置，只能用相同 bundleID 的鉴权信息进行更新，无法修改为其他的 bundleID，请在配置前仔细检查 bundleID 是否正确,Hulk平台支持通过 .p12 证书鉴权

- 如果你之前没有创建过 Push 证书或者是要重新创建一个新的，请在证书列表下面新建。

![add_cert](https://tva1.sinaimg.cn/large/008i3skNly1gy3sj5p0xvj311c0ctab5.jpg)

- 新建证书需要注意选择 APNs 证书种类。如图 APNs 证书有开发（Development）和生产（Production）两种。

```
    注：开发证书用于开发调试使用；生产证书用于产品发布。此处我们选择生产证书为例。
```

![cert_type](https://tva1.sinaimg.cn/large/008i3skNly1gy3sjjkjy4j30zz0qkdkj.jpg)

- 点击 "Continue", 之后选择该证书准备绑定的 AppID。

![cert_to_app](https://tva1.sinaimg.cn/large/008i3skNly1gy3skvdeeqj30zg0a675k.jpg)

- 再点 “Continue” 会让你上传 CSR 文件。（ CSR 文件会在下一步创建）

![update_CSR](https://tva1.sinaimg.cn/large/008i3skNly1gy3sl93qk9j30ys09w3zb.jpg)

- 打开系统自带的 KeychainAccess 创建 Certificate Signing Request。

- 填写“用户邮箱”和“常用名称” ，并选择“存储到磁盘”，证书文件后缀为 .certSigningRequest 。

<img src="https://tva1.sinaimg.cn/large/008i3skNly1gy3sq0pmsvj30xw0o6jt1.jpg" alt="截屏2022-01-06 上午11.32.58" style="zoom:50%;" />

- 回到浏览器中 CSR 上传页面，上传刚刚生成的后缀为 .certSigningRequest 的文件。
- 生成证书成功后，点击 “Download” 按钮把证书下载下来，是后缀为 .cer 的文件。

<img src="https://tva1.sinaimg.cn/large/008i3skNly1gy3sv2rx91j31ca0bydgx.jpg" alt="截屏2022-01-06 上午11.38.08" style="zoom:40%;" />

- 双击证书后，会在 “KeychainAccess” 中打开，选择左侧“钥匙串”列表中“登录”，以及“种类”列表中“我的证书”，找到刚才下载的证书，并导出为 .p12 文件。如下图：
- <img src="https://tva1.sinaimg.cn/large/008i3skNly1gy9qb4ho2tj315s0iijv9.jpg" alt="WeChat4254c483ed18abdef4b63743063efdf6" style="zoom:50%;" />

 

- 在Hulk后管平台上，进入你应用的应用设置中 推送配置 ，上传刚才导出的 .p12 证书。Hulk会在后台为你的应用进行鉴权。
