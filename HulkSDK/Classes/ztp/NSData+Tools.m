//
//  NSData+Tools.m
//  HulkSocket
//
//  Created by Liu Fei on 2019/6/11.
//  Copyright © 2019 Hulk. All rights reserved.
//

#import "NSData+Tools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Tools)
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}
+ (NSData *)dataWithHexString:(NSString *)hexstring
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexstring.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//数字转 ASCII 码
+(int )getAscIIWithString:(NSString *)numStr{
    
    int asciiCode = [numStr characterAtIndex:0];
    
    return asciiCode;
}

//Byte -> Nsdata
+(NSData *)ByteToNsdataWith:(Byte *)bytes{
    
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    return data;
}

//byte数组转为 hex 字符串
+(NSString *)BytesToHexString:(Byte *)byteArray isSpace:(BOOL)space{
    
    NSString *hexStr=@"";
    for(int i=0;i<sizeof(byteArray);i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",byteArray[i]&0xff]; ///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@ ",hexStr,newHexStr];
            if (space) {
                hexStr = [hexStr stringByAppendingString:@" "];
            }
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@ ",hexStr,newHexStr];
            if (space) {
                hexStr = [hexStr stringByAppendingString:@" "];
            }
        }
    }
    return hexStr;
}

//16进制字符串转为data
+(NSData *)HexStrToData:(NSString *)hex
{
    char buf[3];
    buf[2] = '\0';
    NSAssert(0 == [hex length] % 2, @"Hex strings should have an even number of digits (%@)", hex);
    unsigned char *bytes = malloc([hex length]/2);
    unsigned char *bp = bytes;
    for (CFIndex i = 0; i < [hex length]; i += 2) {
        buf[0] = [hex characterAtIndex:i];
        buf[1] = [hex characterAtIndex:i+1];
        char *b2 = NULL;
        *bp++ = strtol(buf, &b2, 16);
        NSAssert(b2 == buf + 2, @"String should be all hex digits: %@ (bad digit around %ld)", hex, i);
    }
    
    return [NSData dataWithBytesNoCopy:bytes length:[hex length]/2 freeWhenDone:YES];
}


//data 转为 hex 字符串
+(NSString *)dataToHexString:(NSData *)data isSpace:(BOOL)space{
    
    Byte *byteArray = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",byteArray[i]&0xff]; ///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            if (space) {
                hexStr = [hexStr stringByAppendingString:@" "];
            }
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
            if (space) {
                hexStr = [hexStr stringByAppendingString:@" "];
            }
        }
    }
    return hexStr;
}
//普通字符串转换为十六进制的
+(NSString *)StringToHexString:(NSString *)string{
    
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
// 十六进制转换为普通字符串的
+(NSString *)HexSrtingToString:(NSString *)hexString {
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    
    return unicodeString;
}

//根据传入的16进制data 转化成 10进制
+(NSString *)getTenStringWithData:(NSData *)inputData{
    
    //先把data转化为16进制字符串
    NSString *hexStr = [self dataToHexString:inputData isSpace:NO];
    
    NSMutableString *mHexStr = [[NSMutableString alloc]initWithString:hexStr];
    //定义一个可变的字符串
    NSMutableString *string = [NSMutableString string];
    if (hexStr.length >=2) {
        for (int i=0; i<hexStr.length/2; i++) {
            
            NSRange range = NSMakeRange(i*2, 2);
            NSString *subStr = [mHexStr substringWithRange:range];
            NSScanner* pScanner = [NSScanner scannerWithString:subStr];
            
            unsigned int iValue;
            [pScanner scanHexInt: &iValue];
            NSString *ascII = [NSString stringWithFormat:@"%d",iValue];
            [string appendString:ascII];
            
        }
    }
    return string;
}

//传入的16进制data，Base64编码后，再返回16进制的Nsdata
+(NSData *)getHexDataAfterBase64EncodeWithHexData:(NSData *)inputData{
    
    NSString *str = [inputData base64EncodedStringWithOptions:0];
    NSString *hexStr = [self StringToHexString:str];
    NSData *msgData = [self HexStrToData:hexStr];
    return msgData;
    
}
//传入的16进制data，Base64解码后，再返回16进制的Nsdata
+(NSData *)getHexDataAfterBase64DecodeWithHexData:(NSData *)inputData{
    
    NSString *hexStr = [NSString stringWithUTF8String:[inputData bytes]];
    
    NSData *hexData = [[NSData alloc]initWithBase64EncodedString:hexStr options:0];
    
    return hexData;
    
}
+(NSData *) convertInt32ToData:(UInt32) val {
    
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[4];
    valChar[3] = 0xff & val;
    valChar[2] = (0xff00 & val) >> 8;
    valChar[1] = (0xff0000 & val) >> 16;
    valChar[0] = (0xff000000 & val) >> 24;
    [valData appendBytes:valChar length:4];
    
    return [self dataWithReverse:valData];
}
/**
 *  反转字节序列
 *
 *  @param srcData 原始字节NSData
 *
 *  @return 反转序列后字节NSData
 */
+ (NSData *)dataWithReverse:(NSData *)srcData
{
    //    NSMutableData *dstData = [[NSMutableData alloc] init];
    //    for (NSUInteger i=0; i<srcData.length; i++) {
    //        [dstData appendData:[srcData subdataWithRange:NSMakeRange(srcData.length-1-i, 1)]];
    //    }//for
    
    NSUInteger byteCount = srcData.length;
    NSMutableData *dstData = [[NSMutableData alloc] initWithData:srcData];
    NSUInteger halfLength = byteCount / 2;
    for (NSUInteger i=0; i<halfLength; i++) {
        NSRange begin = NSMakeRange(i, 1);
        NSRange end = NSMakeRange(byteCount - i - 1, 1);
        NSData *beginData = [srcData subdataWithRange:begin];
        NSData *endData = [srcData subdataWithRange:end];
        [dstData replaceBytesInRange:begin withBytes:endData.bytes];
        [dstData replaceBytesInRange:end withBytes:beginData.bytes];
    }//for
    
    return dstData;
}


+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

+ (uint8_t)uint8FromBytes:(NSData *)fData
{
    NSAssert(fData.length == 1, @"uint8FromBytes: (data length != 1)");
    NSData *data = fData;
    uint8_t val = 0;
    [data getBytes:&val length:1];
    return val;
}

+ (uint16_t)uint16FromBytes:(NSData *)fData
{
    NSAssert(fData.length == 2, @"uint16FromBytes: (data length != 2)");
    NSData *data = [self dataWithReverse:fData];;
    uint16_t val0 = 0;
    uint16_t val1 = 0;
    [data getBytes:&val1 range:NSMakeRange(0, 1)];
    [data getBytes:&val0 range:NSMakeRange(1, 1)];
    
    uint16_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00);
    return dstVal;
}

+ (uint32_t)uint32FromBytes:(NSData *)Data
{
    NSAssert(Data.length == 4, @"uint32FromBytes: (data length != 4)");
    NSData *data = [self dataWithReverse:Data];
    
    uint32_t val0 = 0;
    uint32_t val1 = 0;
    uint32_t val2 = 0;
    uint32_t val3 = 0;
    [data getBytes:&val3 range:NSMakeRange(0, 1)];
    [data getBytes:&val2 range:NSMakeRange(1, 1)];
    [data getBytes:&val1 range:NSMakeRange(2, 1)];
    [data getBytes:&val0 range:NSMakeRange(3, 1)];
    
    uint32_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00) + ((val2 << 16) & 0xff0000) + ((val3 << 24) & 0xff000000);
    return dstVal;
}

+ (NSString *)getMD5Data:(NSData *)data
{
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5);
    NSMutableString *resultString = [NSMutableString string];    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02x", result[i]];
    }
    return resultString;
}

+ (NSData *)generateSocketT1S1Data
{
    NSMutableData *data = [[NSMutableData alloc] initWithLength:0];
    for (int key=0; key<3; key=key+1) {
        [data appendData:[NSData convertInt32ToData:0]];
    }
    return data;
}

+ (NSData *)byteFromUInt8:(uint8_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[1];
    valChar[0] = 0xff & val;
    [valData appendBytes:valChar length:1];
    return valData;
//    return [self dataWithReverse:valData];
}

+ (NSData *)bytesFromUInt16:(uint16_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[2];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    [valData appendBytes:valChar length:2];
    return valData;
//    return [self dataWithReverse:valData];
}

+ (NSData *)bytesFromUInt32:(uint32_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[4];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    valChar[2] = (0xff0000 & val) >> 16;
    valChar[3] = (0xff000000 & val) >> 24;
    [valData appendBytes:valChar length:4];
    return valData;
//    return [self dataWithReverse:valData];
}

@end
