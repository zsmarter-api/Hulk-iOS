//
//  HulkAppDelegate.m
//  Hulk
//
//  Created by ztzh_xuj on 11/02/2021.
//  Copyright (c) 2021 ztzh_xuj. All rights reserved.
//

#import "HulkAppDelegate.h"
#import <Hulk/HulkSDK.h>

@interface HulkAppDelegate ()

@end

@implementation HulkAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [HulkService registerForLocalNotification:^(BOOL success) {
        
    }];
    [HulkLog defaultLog].isSetOn = YES;
    [[HulkService defaultHULK] initWithAppId:@"hulk4015d" appSecret:@"4b15fbce858f42489b7d5f2d75062047" completionHandler:^(NSString * _Nullable tid) {
        NSLog(@"tid = %@", tid);
        }];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
