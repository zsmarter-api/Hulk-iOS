//
//  HulkSocketConfig.h
//  HulkZSBird
//
//  Created by Jessica mini on 2021/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HULKSocketConfig : NSObject

+ (NSString *)getVersion;

+ (NSString *)platform;

+ (NSString *)platformString:(NSString *)platform;

@end

NS_ASSUME_NONNULL_END
