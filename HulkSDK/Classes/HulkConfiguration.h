//
//  ZSBirdConfiguration.h
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/31.
//

#import <Foundation/Foundation.h>
#import "HulkThirdPartyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HulkConfiguration : NSObject

@property (class, readonly, strong) HulkConfiguration *defaultConfiguration;

@property (nonatomic, copy) NSString *socketUrl;//必填
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, assign) BOOL setTLS;//默认NO
@property (nonatomic, copy) NSString *dt;//发布到appstore是1，企业内2
@property (nonatomic, copy) NSString *location;


//极光推送id
@property (nonatomic, copy) NSString *jpushId;
//apns_id
@property (nonatomic, copy) NSString *apnsId;
//token_id
@property (nonatomic, copy) NSString *tokenId;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *ext;
@property (nonatomic, copy) NSString *appVersion;//app版本
@property (nonatomic, copy) NSString *bundle;//如不传入，则默认获取工程配置中的bundleId
@property (nonatomic, strong) NSArray <HulkThirdPartyModel *>*third_party;


@property (nonatomic, copy, readonly) NSString *via;
@property (nonatomic, copy, readonly) NSString *platform;//平台iOS/android
@property (nonatomic, copy, readonly) NSString *brand;//厂商/品牌;
@property (nonatomic, copy, readonly) NSString *systemVersion;//操作系统版本
@property (nonatomic, copy, readonly) NSString *model;//机型

@end

NS_ASSUME_NONNULL_END
