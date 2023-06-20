//
//  HulkLocalNotification.h
//  Hulkank
//
//  Created by singers on 2019/12/25.
//  Copyright © 2019 Hulk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HULKLocalNotification : NSObject

- (void)addNotification:(NSDictionary *)param;

- (void)cancleNotification:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
