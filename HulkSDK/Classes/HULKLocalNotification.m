//
//  HulkLocalNotification.m
//  Hulkank
//
//  Created by singers on 2019/12/25.
//  Copyright © 2019 Hulk. All rights reserved.
//

#import "HULKLocalNotification.h"
#import "NSDictionary+HULKAdd.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#import "YYCategories/YYCategories.h"
#endif
#import <AudioToolbox/AudioServices.h>
#import "HulkLog.h"

@implementation HULKLocalNotification

- (void)addNotification:(NSDictionary *)param {
    NSLog(@"addNotification==11==%@", param);
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = param[@"title"];
            content.body = param[@"alert"];
            if (param[@"voice"] && [[NSString stringWithFormat:@"%@", param[@"voice"]] isEqualToString:@"0"]) {
                content.sound = nil;
            } else {
                content.sound = UNNotificationSound.defaultSound;
            }
            //震动
            if (param[@"vibrate"] && [[NSString stringWithFormat:@"%@", param[@"vibrate"]] isEqualToString:@"1"]) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSString *mId = @"";
            if ([param containsObjectForKey:@"m_id"]) {
                [dic setValue:param[@"title"] forKey:@"title"];
                [dic setValue:param[@"alert"] forKey:@"alert"];
                mId = [NSString stringWithFormat:@"%@", param[@"m_id"]];
                [dic setValue:mId forKey:@"m_id"];
            }
            
            if ([param containsObjectForKey:@"extras"]) {
                [dic setValue:param[@"extras"] forKey:@"extras"];
            }
            
            content.userInfo = dic;
            content.badge = nil;
            
            if ([param containsObjectForKey:@"small_icon_url"] && ((NSString *)param[@"small_icon_url"]).length > 0) {
                NSURL *fileURL = [NSURL URLWithString:param[@"small_icon_url"]];
                NSURLSession * session = [NSURLSession sharedSession];
                NSURLSessionDownloadTask *task = [session downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  lastObject];
                    NSString *filePath = [cache stringByAppendingPathComponent:response.suggestedFilename];
                    NSURL *toURL = [NSURL fileURLWithPath:filePath];
                    [[NSFileManager defaultManager] moveItemAtURL:location toURL:toURL error:nil];
                    NSLog(@"filePath = %@",toURL.path);
                    UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"myAttachment1" URL:toURL options:nil error:nil];
                    content.attachments = attachment ? @[attachment] : @[];
                    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:CGFLOAT_MIN repeats:NO];
                    NSString *identifier = mId;
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
                    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
                        HulkLog(@"本地通知error = :%@",error.localizedDescription);
                    }];
                }];
                [task resume];
            } else {
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:CGFLOAT_MIN repeats:NO];
                NSString *identifier = mId;
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
                [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
                    HulkLog(@"本地通知error = :%@",error.localizedDescription);
                }];
            } 
        } else {
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            notif.alertBody = param[@"alert"];
            notif.alertTitle =  param[@"title"];
            notif.userInfo = param;
            notif.applicationIconBadgeNumber = -1;
            if (param[@"voice"] && [[NSString stringWithFormat:@"%@", param[@"voice"]] isEqualToString:@"0"]) {
                notif.soundName = @"";
            } else {
                notif.soundName = UILocalNotificationDefaultSoundName;
            }
            //震动
            if (param[@"vibrate"] && [[NSString stringWithFormat:@"%@", param[@"vibrate"]] isEqualToString:@"1"]) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            notif.repeatInterval = 0;
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            NSMutableArray *oldLocal = [NSMutableArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
            [oldLocal addObject:notif];
            [UIApplication sharedApplication].scheduledLocalNotifications = oldLocal;
        }
}
    
- (void)downloadAndSave:(NSURL *)fileURL handler:(void (^)(NSString *))handler {
    NSURLSession * session = [NSURLSession sharedSession];
  NSURLSessionDownloadTask *task = [session downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      NSString *localPath = nil;
      NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  lastObject];
      NSString *filePath = [cache stringByAppendingPathComponent:response.suggestedFilename];
      NSLog(@"filePath = %@",filePath);
      NSURL *toURL = [NSURL fileURLWithPath:filePath];
      [[NSFileManager defaultManager] moveItemAtURL:location toURL:toURL error:nil];
    handler(toURL.path);
  }];
  [task resume];
  
}

- (void)cancleNotification:(NSString *)taskId {
    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"消息已被撤回";
        content.body = @"";
        content.sound = nil;
        content.badge = nil;
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:CGFLOAT_MIN repeats:NO];
        NSString *identifier = taskId;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            HulkLog(@"本地通知error = :%@",error.localizedDescription);
        }];
    } else {
        for(UILocalNotification *notification in notificationArray) {
            NSDictionary *userInfo = notification.userInfo;
            if ([userInfo containsObjectForKey:@"m_id"]) {
                NSString *mId = userInfo[@"m_id"];
                if ([mId isEqualToString:taskId]) {
                    // delete this notification
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                    HulkLog(@"删除成功");
                }
            }
        }
    }
}

@end
