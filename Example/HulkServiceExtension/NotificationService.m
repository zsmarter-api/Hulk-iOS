//
//  NotificationService.m
//  HulkServiceExtension
//
//  Created by Jessica mini on 2022/8/29.
//  Copyright © 2022 ztzh_xuj. All rights reserved.
//

#import "NotificationService.h"
#import <HulkExtensionSDK/HulkExtensionSDK.h>


@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
//    self.bestAttemptContent.title = @"已修改";
//    [HulkExtSDK handelNotificationServiceRequest:request withAttachmentsComplete:^(NSArray * _Nonnull attachments, NSArray * _Nonnull errors) {
//        if (attachments) {
//            self.bestAttemptContent.attachments = attachments;
//        } else {
//            NSLog(@"===11===%@", errors);
//        }
//        self.contentHandler(self.bestAttemptContent);
//    }];
    NSString *path = request.content.userInfo[@"small_icon_url"];
    if (path && path.length) {
        NSURL *fileURL = [NSURL URLWithString:path];
        NSURLSession * session = [NSURLSession sharedSession];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  lastObject];
            NSString *filePath = [cache stringByAppendingPathComponent:response.suggestedFilename];
            NSURL *toURL = [NSURL fileURLWithPath:filePath];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:toURL error:nil];
            NSLog(@"filePath = %@",toURL.path);
            UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"myAttachment1" URL:toURL options:nil error:nil];
            self.bestAttemptContent.attachments = attachment ? @[attachment] : @[];
            self.contentHandler(self.bestAttemptContent);
        }];
        [task resume];
    } else {
        self.contentHandler(self.bestAttemptContent);
    }
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
