//
//  JFResizeView.h
//  图片编辑器
//
//  Created by 168licai on 2018/4/8.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFImageEditConfig.h"


@interface JFResizeView : UIView


- (instancetype)initWithFrame:(CGRect)frame
                   editConfig:(JFImageEditConfig *)editConfig
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView;

///**
// 设置剪裁框的frame
//
// @param resizeFrame <#resizeFrame description#>
// */
//-(void)setUpResizeViewWithResizeFrame:(CGRect)resizeFrame;


/**
 重置
 */
-(void)resizeViewReset;

@end
