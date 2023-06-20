//
//  HulkExtSDK.h
//  HulkExtensionSDK
//
//  Created by Jessica mini on 2022/8/31.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface HulkExtSDK : NSObject

+ (void)handelNotificationServiceRequest:(UNNotificationRequest *)request withAttachmentsComplete:(void (^)(NSArray *attachments, NSArray *errors))completeBlock;

@end

NS_ASSUME_NONNULL_END
