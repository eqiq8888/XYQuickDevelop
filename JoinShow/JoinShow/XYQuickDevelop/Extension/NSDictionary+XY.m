//
//  NSDictionary+XY.m
//  KeyLinks2
//
//  Created by Heaven on 14-5-27.
//  Copyright (c) 2014年 Heaven. All rights reserved.
//

#import "NSDictionary+XY.h"
#import "XYCommonDefine.h"

@implementation NSDictionary (XY)

+(NSMutableDictionary *) nonRetainDictionary{
    CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
    CFDictionaryValueCallBacks callbacks  = kCFTypeDictionaryValueCallBacks;
    callbacks.retain                      = __XYRetainNoOp;
    callbacks.release                     = __XYReleaseNoOp;
    
    return  (__bridge_transfer NSMutableDictionary*)CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &callbacks);
}

@end
