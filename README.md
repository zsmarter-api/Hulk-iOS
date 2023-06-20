# Hulk SDK接入文档



## Hulk介绍

<img src="https://p.ipic.vip/a73655.jpg" alt="10631675414981_.pic" style="zoom:50%;" />

从上图可以看出，Hulk 包括 2 个部分，APNs 推送（代理），与 Hulk 应用内消息。

红色部分是 APNs 推送，Hulk 代理开发者的应用（需要基于开发者提供的应用证书），向苹果 APNs 服务器推送。由 APNs Server 推送到 iOS 设备上。

蓝色部分是 Hulk 应用内推送部分，即 App 启动时，内嵌的 Hulk SDK 会开启长连接到 Hulk Server，从而 Hulk Server 可以推送消息到 App 里。

### APNs 通知

APNs 通知：是指通过向 Apple APNs 服务器发送通知，到达 iOS 设备，由 iOS 系统提供展现的推送。用户可以通过 IOS 系统的 “设置” >> “通知” 进行设置，开启或者关闭某一个 App 的推送能力。

Hulk SDK 不负责 APNs 通知的展现，只是向 Hulk 服务器端上传 Device Token 信息，Hulk 服务器端代理开发者向 Apple APNs 推送通知。

### 应用内消息

应用内消息：HulkSDK 提供的应用内消息功能，在 App 在前台时能够收到推送下来的消息。App 可使用此功能来做消息下发动作。

此消息不经过 APNs 服务器，完全由 Hulk 提供功能支持。

### APNs 通知与应用内消息对比

Hulk支持应用在打开状态时优先默认通过自建通道推送，当应用在后台或退出情况，则通过系统的 APNs 提醒。

|                | APNs                                                         | 应用内消息                                                   |
| :------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 推送原则       | 由 Hulk 服务器发送至 APNs 服务器，再下发到手机。             | 由 Hulk 直接下发，每次推送都会尝试发送，如果用户在线则立即收到。否则保存为离线。 |
| 离线消息       | 离线消息由 APNs 服务器缓存按照 Apple 的逻辑处理。            | 用户不在线 Hulk server 会保存离线消息，时长默认保留72小时。  |
| 推送与证书环境 | 应用证书和推送指定的 iOS 环境匹配才可以收到。                | 自定义消息与 APNs 证书环境无关。                             |
| 接收方式       | 应用退出，后台以及打开状态都能收到 APNs。                    | 需要应用打开，与 Hulk 建立连接才能收到。                     |
| 展示效果       | 如果应用后台或退出，会有系统的 APNs 提醒。如果应用处于打开状态，则不展示，iOS 10 开始可实现前台展示。 | 非 APNs，默认不展示。可通过注册本地通知按需配置。            |
| 处理函数       | Apple 提供的接口：[详见使用](#使用)                          | Hulk 提供的接口：[详见使用](#使用)                           |



***



## Hulk接入

Hulk支持iOS9及以上系统。

### 导入方式

```一、推荐使用 CocoaPods 接入```
1、在 Podfile 文件中，使用```pod 'Hulk'``` 添加依赖。

```shell
pod 'Hulk'
```

2、执行 `pod install` 即可完成接入。

### 初始化推送服务

#### 添加头文件

```objc
#import <Hulk/HulkSDK.h>
```

#### AppDelegate中配置

- AppDelegate中注册远程通知以及将deviceToken传给Hulk，用于APNs推送。

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 注册远程通知
    [HulkService registerForRemoteNotification:nil];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Hulk SDK注册deviceToken
    [HulkService registerDeviceToken:deviceToken];
}
```

#### 添加初始化代码

```javascript
// appId及appSecret由Hulk后管平台生成
[[HulkService defaultHULK] initWithAppId:@"xxxx" appSecret:@"xxxx" completionHandler:^(NSString * _Nullable tid) {
  NSLog(@"Hulk初始化成功 tid = %@", tid);
}];
```

### 验证推送结果

- 集成完成后，调试该项目，如果控制台输出以下回调日志则代表您已经集成成功。 <img src="https://tva1.sinaimg.cn/large/e6c9d24ely1h52ksikd15j20ne01e3yh.jpg" alt="image-20220811093641896" style="zoom: 67%;" />

- 获取日志中的 tid，并在Hulk后管平台 [创建推送](http://hulk.zsmarter.com/hulkx/#/Mgt/createPush) 体验通知推送服务。

- 推送完成后，你可以在 [消息列表](http://hulk.zsmarter.com/hulkx/#/Mgt/messageList/index) 中查看推送结果、推送渠道、送达率等详细数据。

### 使用

<img src="https://tva1.sinaimg.cn/large/e6c9d24ely1h52mxmnl33j20u00z8wgc.jpg" alt="image-20220811105045769" style="zoom:50%;" />

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



### 其他API

#### 更新用户数据

```objective-c
HulkService *hulk = [HulkService defaultHULK];
HULKConfiguration *config = [HULKConfiguration defaultConfiguration];
config.appId = @"xxxx";// appId，后管平台生成
config.appSecret = @"xxx";// appSecret，后管平台生成
//以下数据均为非必填，用户根据需要配置
config.location = @"成都市";// 位置，“成都市”,如果您需要通过位置筛选推送对象，传此字段
config.uid = @"1234567890";// 用户id，如果您需要通过自定义用户id筛选推送对象，传此字段
config.apnsId = [HulkConfiguration defaultConfiguration].apnsId;//请确保已在AppDelegate中已传给Hulk
config.alias = "alias";
[hulk updateUserInfo:config completionHandler:^{
    //Hulk用户信息成功成功
}];
```

#### 统计消息送达、消息点击

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

#### 获取设置中推送的开关状态

如需检测应用是否开启了推送，可调用以下API:

```objective-c
+ (void)notificationIsOpen:(void(^)(BOOL isOpen))completionHandler;//isOpen为Yes代表已开启
```

#### 自建通道通知展示

自建通道通知（非 APNs），默认不展示。可通过注册本地通知在前台展示。

```objc
[HulkService registerForLocalNotification:nil];
```

#### 自定义通知图标

**支持版本：**

iOS 10 及以上的系统

**客户端设置**：

- 在集成个推SDK时，可以添加 Notification Service Extension，实现[多媒体支持](#附2：多媒体支持)。

  代码示例如下：
  
  ```objc
  - (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
      self.contentHandler = contentHandler;
      self.bestAttemptContent = [request.content mutableCopy];
      [HulkExtSDK handelNotificationServiceRequest:request withAttachmentsComplete:^(NSArray * _Nonnull attachments, NSArray * _Nonnull errors) {
          if (attachments) {
              self.bestAttemptContent.attachments = attachments;
          }
          self.contentHandler(self.bestAttemptContent);
      }];
  }
  ```
  

**服务端设置**:

图片展示需要在 ios 下配置 mutable-content 和 extras 字段。

| 关键字          | 类型        | 选项 |     含义     | 说明                                                         |
| --------------- | ----------- | ---- | -------- | ------------------------------------------------------------ |
| mutable-content | boolean     | 可选 |      通知扩展 | 推送的时候携带 "mutable-content":true 说明是支持 iOS 10 的 UNNotificationServiceExtension，如果不携带此字段则是普通的 Remote Notification |
| extras          | JSON Object | 可选 |    附加字段 | 这里自定义 key / value 信息，这个 key（hulkAttachment）值，需要与客户端的值对应，客户端工程拿到 key 值对应的 url 图标加载出来。 |

```objc
"notification": {
    "ios": {
        "alert": {
            "title": "title",
            "subtitle": "subtitle"  
        },
      "mutable-content": true，
        "extras": {
            // 这个 key（hulkAttachment）值，需要与客户端的值对应，客户端工程拿到 key 值对应的 url 图标加载出来。
            "hulkAttachment": "https://tva1.sinaimg.cn/large/e6c9d24egy1h5s4wcndxxj20ck0cymy0.jpg"
        }
    }
}  
```



## 权限与合规

### 隐私政策

开发者请务必在《隐私政策》中向用户告知应用使用了Hulk推送SDK，参考条款如下：
**SDK名称**：Hulk推送SDK
**服务类型**：消息推送服务
**SDK收集个人信息类型**：

- 设备信息（IMEI）：用于识别唯一用户，保证消息推送的精准送达；优化推送通道资源，我们会根据设备上不同APP的活跃情况，整合消息推送的通道资源，为开发者提高消息送达率；为开发者提供智能标签以及展示业务统计信息的服务
- 网络信息以及位置相关信息：为了最大程度保持网络连接的稳定性，建立长链接，我们需要了解设备的网络状态和变化，从而实现稳定连续的推送服务。我们提供地域推送功能，位置相关信息将有助于我们为您提供相应推送，方便用户划分，减少无用推送消息对您用户的打扰。
- 手机号码：为了能够为用户提供重要信息可以对推送进行短信补发、并发的功能


⚠️ **同意隐私政策再初始化 SDK**

请务必确保终端用户完成同意《隐私政策》操作之后，再调用 SDK 的初始化接口及其他业务接口，进行 SDK 初始化。

 **必选权限**

- 以下为必选权限，必须配置以下权限才能满足APNs基本的推送功能能力

  ```objective-c
  [HulkService registerForRemoteNotification:nil];
  ```



# 附1：iOS 证书设置指南

## 创建应用程序 ID

- 登陆 [苹果开发者网站](https://developer.apple.com/) 进入开发者账户。

![WeChat7edc7fe7f0b4ae3b1da725abe47da2b1](https://p.ipic.vip/xw6m5b.png)
- 从开发者账户页面【证书、标识符和描述文件】入口进入 “Certificates, IDs & Profiles” 页面。

<img src="https://p.ipic.vip/o2bi7n.png" alt="image-20230203163322053" style="zoom: 50%;" />

- Identifiers中创建 App ID，填写 App ID 的 NAME 和 Bundle ID（如果 ID 已经存在可以直接跳过此步骤）。

<img src="https://p.ipic.vip/zot6pi.png" alt="image-20230203163804812" style="zoom:50%;" />

```
    注: 此处需要指定具体的 Bundle ID 不要使用通配符。
```

- 为 App 开启 Push Notification 功能。如果是已经创建的 App ID 也可以通过设置开启 Push Notification 功能。
 ![image-20230203164043951](https://p.ipic.vip/umhunz.png)

- 填写好以上属性后，点击 “Continue”，确认 AppId 属性的正确性，点击 “Register”，注册 AppId 成功。

## 鉴权方式的配置

Hulk官网应用的鉴权信息一旦配置，只能用相同 bundleID 的鉴权信息进行更新，无法修改为其他的 bundleID，请在配置前仔细检查 bundleID 是否正确,Hulk平台支持通过 .p12 证书鉴权

- 如果你之前没有创建过 Push 证书或者是要重新创建一个新的，请在证书列表下面新建。

<img src="https://p.ipic.vip/twphqd.png" alt="image-20230203164522861" style="zoom:50%;" />

- 新建证书需要注意选择 APNs 证书种类。如图 APNs 证书有开发（Development）和生产（Production）两种。

```
    注：开发证书用于开发调试使用；生产证书用于产品发布。此处我们选择生产证书为例。
```

<img src="https://p.ipic.vip/k5bvkh.png" alt="image-20230203164654053" style="zoom:50%;" />

- 点击 "Continue", 之后选择该证书准备绑定的 AppID。

![image-20230203164858746](https://p.ipic.vip/b0amfp.png)

- 再点 “Continue” 会让你上传 CSR 文件。（ CSR 文件会在下一步创建）

![image-20230203165052738](https://p.ipic.vip/9h2rt7.png)

- 打开系统自带的 KeychainAccess 创建 Certificate Signing Request。

- 填写“用户邮箱”和“常用名称” ，并选择“存储到磁盘”，证书文件后缀为 .certSigningRequest 。

<img src="https://p.ipic.vip/21xn5x.png" alt="image-20230203165426907" style="zoom:50%;" />

- 回到浏览器中 CSR 上传页面，上传刚刚生成的后缀为 .certSigningRequest 的文件。
- 生成证书成功后，点击 “Download” 按钮把证书下载下来，是后缀为 .cer 的文件。

<img src="https://p.ipic.vip/yt9xh5.png" alt="image-20230203165617957" style="zoom:50%;" />

- 双击证书后，会在 “KeychainAccess” 中打开，选择左侧“钥匙串”列表中“登录”，以及“种类”列表中“我的证书”，找到刚才下载的证书，并导出为 .p12 文件。如下图：

  ![image-20230203170047696](https://p.ipic.vip/9f00ar.png)

- 在Hulk后管平台上，进入你应用的应用设置中 推送配置 ，上传刚才导出的 .p12 证书。Hulk会在后台为你的应用进行鉴权。

# 附2：多媒体支持

- Apple 在 iOS 10 中新增了`Notification Service Extension`机制，可在消息送达时进行业务处理。为实现显示自定义图标，在集成个推SDK时，可以添加 `Notification Service Extension`，并在 Extensions 中添加 HulkExtensionSDK 的下载图片的接口，实现显示图标功能。

### 1 在项目中添加 Notification Service Extension

填写Target信息时需要注意以下两点：

- Extension 的 Bundle Identifier 不能和 Main Target（也就是你自己的 App Target）的 Bundle Identifier 相同，否则会报 BundeID 重复的错误。

- Extension 的 Bundle Identifier 需要在 Main Target 的命名空间下，比如说 Main Target 的 BundleID 为 ent.hulk.xxx，那么Extension的BundleID应该类似与ent.hulk.xxx.yyy这样的格式。如果不这么做，会引起命名错误。

- 添加 Notification Service Extension 后会生成相应的 Target。点`Finish`按钮后会弹出是否激活该 Target 对应 scheme 的选项框，选择 `Activate`，如果没有弹出该选项框，需要自行添加相应的 scheme。

- Notification Service Extension 添加成功后会在项目中自动生成 `NotificationService.h` 和 `NotificationService.m` 两个类，包含以下两个方法：

 ```objc
 - (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler
 ```

```
- (void)serviceExtensionTimeWillExpire
```



### 2 添加 HulkExtensionSDK 依赖库

pod集成：

```js
target 'HulkServiceExtension' do 
    platform :ios, '10.0'
    pod 'HulkExtensionSDK'
end
```

### 3 使用 HulkExtensionSDK 进行多媒体展示

- 1.引用：在 `NotificationService.m` 文件中，导入 HulkExtensionSDK 的头文件:

```objective-c
#import <HulkExtensionSDK/HulkExtensionSDK.h>
```

主要方法如下：

```objc
[HulkExtSDK handelNotificationServiceRequest:request withAttachmentsComplete:^(NSArray * _Nonnull attachments, NSArray * _Nonnull errors) {
        if (attachments) {
            self.bestAttemptContent.attachments = attachments;
        }
        self.contentHandler(self.bestAttemptContent);
   }];
```

错误码如下：

| 10001 | 多媒体地址错误,无法下载 | 请使用正常地址下发                                           |
| ----- | ----------------------- | ------------------------------------------------------------ |
| 10002 | Http URL 不支持         | 支持 ATS 使用 Https 地址或者将 NotificationService 配置为支持 Http 请求，如下图所示 |

