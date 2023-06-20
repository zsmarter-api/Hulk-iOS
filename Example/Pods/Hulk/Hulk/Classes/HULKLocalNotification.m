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


@implementation HULKLocalNotification

- (void)addNotification:(NSDictionary *)param {
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
            
            content.userInfo = dic;
            content.badge = nil;
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:CGFLOAT_MIN repeats:NO];
            NSString *identifier = mId;
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
            [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
                NSLog(@"本地通知error = :%@",error.localizedDescription);
            }];
            
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
            NSLog(@"本地通知error = :%@",error.localizedDescription);
        }];
    } else {
        for(UILocalNotification *notification in notificationArray) {
            NSDictionary *userInfo = notification.userInfo;
            if ([userInfo containsObjectForKey:@"m_id"]) {
                NSString *mId = userInfo[@"m_id"];
                if ([mId isEqualToString:taskId]) {
                    // delete this notification
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                    NSLog(@"删除成功");
                }
            }
        }
    }
}

@end
