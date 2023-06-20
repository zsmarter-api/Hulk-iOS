//
//  NSData+Tools.h
//  HulkSocket
//
//  Created by Liu Fei on 2019/6/11.
//  Copyright © 2019 Hulk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Tools)

- (NSString *)hexadecimalString;
+ (NSData *)dataWithHexString:(NSString *)hexstring;

/**
 数字字符串 转 ASCII 码
 */
+(int )getAscIIWithString:(NSString *)numStr;

/**
 Byte数组 转为 Nsdata
 */
+(NSData *)ByteToNsdataWith:(Byte *)byte;
/**
 Byte数组转为 hex 字符串
 @param byteArray byte数组
 @param space 是否添加空格空格
 @return hex字符串
 */
+(NSString *)BytesToHexString:(Byte *)byteArray isSpace:(BOOL)space;

/**
 十六进制字符串转Data
 */
+(NSData *)HexStrToData:(NSString *)hex;

/**
 传入 data 返回 16进制 字符串 ，是否有空格
 */
+(NSString *)dataToHexString:(NSData *)data isSpace:(BOOL)space;

/**
 普通字符串转换为十六进制
 */
+(NSString *)StringToHexString:(NSString *)string;

/**
 十六进制转换为普通字符串
 */
+(NSString *)HexSrtingToString:(NSString *)hexString;

/**
 根据传入的16进制data 转化成 10进制字符串
 */
+(NSString *)getTenStringWithData:(NSData *)inputData;

/**
 传入的16进制data，Base64编码后，再返回16进制的Nsdata
 */
+(NSData *)getHexDataAfterBase64EncodeWithHexData:(NSData *)inputData;

/*
 传入的16进制data，Base64解码后，再返回16进制的Nsdata
 */
+(NSData *)getHexDataAfterBase64DecodeWithHexData:(NSData *)inputData;


/**
 将传入的uint32数字转换成nsdata
 
 @param val 传入的uint32
 @return NSData
 */
+(NSData *) convertInt32ToData:(UInt32) val;

/**
 NSData转成hexstring
 
 @param data NSData
 @return hexstr
 */
+ (NSString *)convertDataToHexStr:(NSData *)data;

/**
 data to unit8
 
 @param fData fData description
 @return uint18_t
 */
+ (uint8_t)uint8FromBytes:(NSData *)data;

/**
 data to unit16
 
 @param fData fData description
 @return uint16_t
 */
+ (uint16_t)uint16FromBytes:(NSData *)fData;

/**
 将传入的nsdata数字转换成uint32
 
 @param Data NSData
 @return uint32_t
 */
+ (uint32_t)uint32FromBytes:(NSData *)Data;

/**
 convert data to int from range
 */
+ (NSInteger)intFromBytes:(NSData *)data range:(NSRange)range;

/**
 mddata
 */
+ (NSString *)getMD5Data:(NSData *)data;

/**
 
 */
+ (NSData *)generateSocketT1S1Data;

/**
 
 */
+ (NSData *)byteFromUInt8:(uint8_t)val;

/**
 
 */
+ (NSData *)bytesFromUInt16:(uint16_t)val;

/**
 
 */
+ (NSData *)bytesFromUInt32:(uint32_t)val;

@end

NS_ASSUME_NONNULL_END
