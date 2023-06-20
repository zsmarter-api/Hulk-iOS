//
//  ZTPData.m
//  HulkSocket
//
//  Created by 胡红星 on 2021/3/12.
//

#import "ZTPData.h"
#import "NSData+Tools.h"
#import <YYCategories/YYCategories.h>

#define kHeadLen 1
#define kVerifyLen 4
#define kVersionLen 1
#define kTypeLen 2
#define kSubTypeLen 2
#define kAckEncryptLen 1
#define kSeqLen 2
#define kReversedLen 16
#define kDataLenLen 4

@implementation ZTPData

- (instancetype)init
{
    if (self = [super init]) {
        self.head = 0x7E;
        self.version = 0x03;
        self.ack = 0x0;
        self.encrypt = 0x2;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        self.head = 0x7E;
        self.version = 0x01;
        NSInteger location = kHeadLen + kVerifyLen + kVersionLen;
        self.type = [NSData uint16FromBytes:[data subdataWithRange:NSMakeRange(location, kTypeLen)]];
        location += kTypeLen;
        self.subType = [NSData uint16FromBytes:[data subdataWithRange:NSMakeRange(location, kSubTypeLen)]];
        location += kSubTypeLen;
        self.ack = [[[[data subdataWithRange:NSMakeRange(location, kAckEncryptLen)] hexString] substringToIndex:1] unsignedCharValue];
        self.encrypt = [[[[data subdataWithRange:NSMakeRange(location, kAckEncryptLen)] hexString] substringFromIndex:1] unsignedCharValue];
        location += kAckEncryptLen;
        self.seq = [NSData uint16FromBytes:[data subdataWithRange:NSMakeRange(location, kSeqLen)]];
        location += kSeqLen;
        self.reversed = [[data subdataWithRange:NSMakeRange(location, kReversedLen)] copy];
        location += kReversedLen;
        self.dataLen = [NSData uint32FromBytes:[data subdataWithRange:NSMakeRange(location, kDataLenLen)]];
        self.data = [[data subdataWithRange:NSMakeRange(data.length - self.dataLen, self.dataLen)] copy];
    }
    return self;
}

- (NSData *)generateSocketData
{
    NSString *ackEncryptStr = [NSString stringWithFormat:@"%@%@", @(self.ack), @(self.encrypt)];
    UInt32 length = (UInt32)self.data.length;

    NSData *head = [NSData byteFromUInt8:self.head];
    NSData *version = [NSData byteFromUInt8:self.version];
    NSData *type = [NSData bytesFromUInt16:self.type];
    NSData *subType = [NSData bytesFromUInt16:self.subType];
    NSData *ackEncrypt = [NSData dataWithHexString:ackEncryptStr];
    NSData *seq = [NSData bytesFromUInt16:self.seq];
    NSData *reserved = [[[NSMutableData alloc] initWithLength:kReversedLen] copy];
    NSData *dataLen = [NSData convertInt32ToData:length];
    NSData *data = self.data;
    
    NSMutableData *crc32Data = [NSMutableData new];
    [crc32Data appendData:type];
    [crc32Data appendData:subType];
    [crc32Data appendData:ackEncrypt];
    [crc32Data appendData:seq];
    [crc32Data appendData:reserved];
    [crc32Data appendData:dataLen];
    [crc32Data appendData:data];
    NSData *verify = [NSData convertInt32ToData:[crc32Data crc32]];

    NSMutableData *result = [NSMutableData new];
    [result appendData:head];
    [result appendData:verify];
    [result appendData:version];
    [result appendData:type];
    [result appendData:subType];
    [result appendData:ackEncrypt];
    [result appendData:seq];
    [result appendData:reserved];
    [result appendData:dataLen];
    [result appendData:self.data];
    return result;
}

@end
