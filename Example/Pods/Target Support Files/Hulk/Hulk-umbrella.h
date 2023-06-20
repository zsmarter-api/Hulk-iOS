#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HulkConfiguration.h"
#import "HULKLocalNotification.h"
#import "HulkLog.h"
#import "HulkSDK.h"
#import "HulkService.h"
#import "HULKSocket.h"
#import "HULKSocketConfig.h"
#import "HulkThirdPartyModel.h"
#import "HulkUUID.h"
#import "HulkKeychain.h"
#import "HulkKeychainQuery.h"
#import "NSDictionary+HULKAdd.h"
#import "NSData+Tools.h"
#import "ZTPData.h"
#import "ZTPSocketManager.h"

FOUNDATION_EXPORT double HulkVersionNumber;
FOUNDATION_EXPORT const unsigned char HulkVersionString[];

