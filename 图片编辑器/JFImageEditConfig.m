//
//  JFImageEditConfig.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/17.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "JFImageEditConfig.h"
#define kANIMATIONDURATION (0.5)
#define kSCOPEWH (50.0)
#define kDOTWH (10.0)
#define kMINRESIZEWH (100.0)
static  JFImageEditConfig* _editConfig;
@implementation JFImageEditConfig


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    // 一次函数
    dispatch_once(&onceToken, ^{
        if (_editConfig == nil) {
            _editConfig = [super allocWithZone:zone];
        }
    });
    
    return _editConfig;
}

+ (instancetype)share{
  
    return  [[self alloc] init];
}
-(void)constantConfig{
    self.animationDuration = kANIMATIONDURATION;
    self.dotScopeWH = kSCOPEWH;
    self.dotWH = kDOTWH;
    self.minResizeWH = kMINRESIZEWH;
    self.imageRotationDirection = JFResizerRotationDirectionUp;
}
@end
