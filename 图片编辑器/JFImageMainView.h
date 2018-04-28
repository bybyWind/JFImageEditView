//
//  JFImageMainView.h
//  图片编辑器
//
//  Created by 168licai on 2018/4/10.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFImageEditConfig.h"
@interface JFImageMainView : UIView

- (instancetype)initWithFrame:(CGRect)frame editConfig:(JFImageEditConfig *)editConfig;

/**
 旋转重置
 */
-(void)imageMainViewResetRotate;

/**
 旋转
 */
-(void)imageMainViewRotate;


/**
开始剪裁
 */
-(void)imageMainViewOpenClip;
/**
 取消剪裁
 */
-(void)imageMainViewCancelClip;
/**
 完成剪裁
 */
-(void)imageMainViewAccomplishClip;
/**
 剪裁重置
 */
-(void)imageMainViewResetClip;
@end
