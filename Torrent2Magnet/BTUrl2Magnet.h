//
//  BTUrl2Magnet.h
//  Torrent2Magnet
//
//  Created by zBosi on 2017/2/9.
//  Copyright © 2017年 LandOfMystery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTUrl2Magnet : NSObject

//根据bt url 转化为 磁力链
+ (NSString *)btUrlToMagnet:(NSString *)btUrlStr;

@end
