//
//  HulkThirdPartyModel.h
//  Hulk
//
//  Created by Jessica mini on 2023/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HulkThirdPartyModel : NSObject

@property (nonatomic, copy) NSString *channel; //目前只支持微信和邮箱，需传入固定的字段：微信（"wechat"），邮箱（"email"）
@property (nonatomic, copy) NSString *token;

@end

NS_ASSUME_NONNULL_END
