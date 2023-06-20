//
//  HulkUUID.m
//  Hulk
//
//  Created by Jessica on 2022/4/11.
//

#import "HulkUUID.h"
#import "HulkKeychain.h"

@implementation HulkUUID

+ (NSString *)getUUID {
    NSString *keychainUUID = [HulkKeychain passwordForService:@"hulk" account:@"user"];
    if (keychainUUID && [keychainUUID isKindOfClass:[NSString class]] && keychainUUID.length) {
        return keychainUUID;
    } else {
        NSString *uuid = [NSUUID UUID].UUIDString;
        [HulkKeychain setPassword:uuid forService:@"hulk" account:@"user"];
        return uuid;
    }
}

@end
