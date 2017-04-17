//
//  BTUrl2Magnet.m
//  Torrent2Magnet
//
//  Created by zBosi on 2017/2/9.
//  Copyright © 2017年 LandOfMystery. All rights reserved.
//

#import "BTUrl2Magnet.h"
#import "bencode.h"
#import <CommonCrypto/CommonDigest.h>

@implementation BTUrl2Magnet

+ (NSString *)btUrlToMagnet:(NSString *)btUrlStr{
    NSURL *url = [[NSURL alloc] initWithString:btUrlStr];
    if (!url) {
        return @"";
    }

    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    const char *c = [data bytes];
    
    bencode_t ben,ben2;
    const char *key;
    int klen;
    
    const char *tr;
    int trLength;
    
    const char *name;
    int nameLength;
    
    long int lengthL;
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    NSMutableString *nameStr = [[NSMutableString alloc] init];
    NSMutableString *trStr = [[NSMutableString alloc] init];
    bencode_init(&ben, c, data.length);
    
    //格式有问题
    if (!bencode_is_dict(&ben)){
        return @"";
    }
    
    
    while (bencode_dict_get_next(&ben, &ben2, &key, &klen)) {
        if (strncmp("announce", key, klen) == 0) {
            if (bencode_is_string(&ben2)) {
                bencode_string_value(&ben2, &tr, &trLength);
            }
        }
        
        if (strncmp("info", key, klen) == 0) {
            
            //hash info内容
            NSMutableData *data = [[NSMutableData alloc] init];
            [data appendBytes:ben2.start length:(ben.str - ben2.start)];
            
            uint8_t digest[CC_SHA1_DIGEST_LENGTH];
            //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
            CC_SHA1(data.bytes, data.length, digest);
            
            
            for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++){
                [output appendFormat:@"%02x", digest[i]];
            }
            
            if (bencode_is_dict(&ben2)) {
                bencode_t ben3;
                const char *innerKey;
                int innerKeyLen;
                
                while (bencode_dict_get_next(&ben2, &ben3, &innerKey, &innerKeyLen)) {
                    if (strncmp("name", innerKey, innerKeyLen) == 0) {
                        bencode_string_value(&ben3, &name, &nameLength);
                    }
                    
                    if (strncmp("length", innerKey, innerKeyLen) == 0) {
                        if (bencode_is_int(&ben3)) {
                            bencode_int_value(&ben3, &lengthL);
                        }
                    }
                    
                }
            }
        }
    }
    
    
    for (NSInteger i = 0; i < trLength; i++) {
        [trStr appendFormat:@"%c", *(tr+i)];
    }
    
    for (NSInteger i = 0; i < nameLength; i++) {
        [nameStr appendFormat:@"%c", *(name+i)];
    }
    
    NSString *magnet = [NSString stringWithFormat:@"magnet:?xt=urn:btih:%@&tr=%@&xl=%lu",output,trStr,lengthL];

    return magnet;
}

@end
