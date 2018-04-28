//
//  UIImage+JFExtension.h
//  图片编辑器
//
//  Created by 168licai on 2018/4/16.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JFExtension)
/** 修正图片的方向 */
- (UIImage *)jf_fixOrientation;
/**
 按指定方向旋转
 */
-(UIImage *)jf_rotate:(UIImageOrientation)orientation;

//图片剪裁
//注意这里的rect是相对于 所给图片的真实像素而言的，比如图片的像素是100x100,如果要得到宽度为这个图片宽度一半的新图片，rect应该写成（0, 0, 50, 100）
+ (UIImage *)getPartOfImage:(UIImage *)img rect:(CGRect)partRect;

@end
