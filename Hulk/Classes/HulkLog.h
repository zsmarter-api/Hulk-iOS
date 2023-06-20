//
//  HulkLog.h
//  Hulk
//
//  Created by Jessica mini on 2021/11/9.
//

#import <Foundation/Foundation.h>

//#define HulkLog(fmt, ...) ([HulkLog defaultLog].isSetOn ? nil : NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__));
//#define HulkLog(fmt, ...)

#define HulkLog(fmt, ...) \
if ([HulkLog defaultLog].isSetOn) \
do { \
NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);} \
while (0); \
else { \
printf("");  }

NS_ASSUME_NONNULL_BEGIN

@interface HulkLog : NSObject

+ (instancetype)defaultLog;

@property (nonatomic, assign) BOOL isSetOn;

@end

NS_ASSUME_NONNULL_END
