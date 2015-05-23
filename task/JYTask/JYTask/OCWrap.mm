//
//  OCWrap.m
//  OCWrap
//
//  Created by wxqdev on 14-11-12.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

#import "OCWrap.h"
#include "cppwrap.h"

@implementation OCWrap
+(void)initDB:(NSString*)path
{
    std::string spath([path cStringUsingEncoding:NSASCIIStringEncoding]);
    initDB(spath);
}

+(NSString*)getMessage:(NSString*)sMsg
{
    std::string strIn([sMsg cStringUsingEncoding:NSASCIIStringEncoding]);
    std::string strOut;
    
    strOut = getMessage(strIn);
    return [[NSString alloc] initWithCString:strOut.c_str() encoding:NSASCIIStringEncoding];
    
}
+(NSString*)getTaskDetailHtml:(NSString*)sIn1 sLang:(NSString*)sIn2
{
    std::string strIn1([sIn1 cStringUsingEncoding:NSASCIIStringEncoding]);
    std::string strIn2([sIn2 cStringUsingEncoding:NSASCIIStringEncoding]);
    std::string strOut;
    
    strOut = getTaskDetailHtml(strIn1,strIn2);
    return [[NSString alloc] initWithCString:strOut.c_str() encoding:NSASCIIStringEncoding];
}

@end
