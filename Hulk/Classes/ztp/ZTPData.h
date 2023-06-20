//
//  ZTPData.h
//  HulkSocket
//
//  Created by 胡红星 on 2021/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/***
 *
 * 协议组装数据：
 *
 * Head   Verify    Version    Type    subType    Ack   Encrypt   Seq     Reversed   DataLen     Data
 * 0x7E  (unit32)  (unit8)  (unit16)  (unit16)  (4bit)  (4bit)  (unit16)  (16byte)   (unit32)  (N byte)
 *
 * Head:  协议头，固定为0x7E
 * Verify: 将Type到Data(包含)所有bytes，采用CRC32算法(Table为IEEE 802.3)求得的unit32值
 * Version: 协议头版本，暂时固定为0x01
 * Type: 协议type
 * SubType: 协议subtype
 * ACK: 协议回复标记，0x0为无需回复;0x1需要回复;0x2为回复
 * Encrypt: 0x0不加密，0x1是SM4_CFB_PKCS7加密，0x2是SM4_CBC_PKCS7加密，0x3是SM4_ECB_PKCS7加密，
 *          0x4是SM4_OFB_PKCS7加密，0x5是AES_CBC_PKCS5加密，0x6是AES_ECB加密，0x7是AES_CFB加密
 * Seq: 命令序列号
 * Reserved: 预留位，待扩展。
 * DataLen: 标记Data的长度，Max:2^20
 * Data: 业务数据，使用UTF-8编码的字符串
 *
 * 除Data以外，其他字段在ByteArray中的总长度为1+4+1+2+2+0.5+0.5+2+16+4=33个字节，Data字段N字节
 */
@interface ZTPData : NSObject

@property (nonatomic, assign) uint8_t head;
@property (nonatomic, assign) uint32_t verify;
@property (nonatomic, assign) uint8_t version;
@property (nonatomic, assign) uint16_t type;
@property (nonatomic, assign) uint16_t subType;
@property (nonatomic, assign) uint8_t ack;
@property (nonatomic, assign) uint8_t encrypt;
@property (nonatomic, assign) uint16_t seq;
@property (nonatomic, strong) NSData *reversed;
@property (nonatomic, assign) uint32_t dataLen;
@property (nonatomic, strong) NSData *data;

- (instancetype)initWithData:(NSData *)data;
- (NSData *)generateSocketData;

@end

NS_ASSUME_NONNULL_END
