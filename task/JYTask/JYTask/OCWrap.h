//
//  OCWrap.h
//  OCWrap
//
//  Created by wxqdev on 14-11-12.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCWrap : NSObject
+(void)initDB:(NSString*)path;
+(NSString*)getMessage:(NSString*)sMsg;
+(NSString*)getTaskDetailHtml:(NSString*)sIn1 sLang:(NSString*)sIn2;
@end
