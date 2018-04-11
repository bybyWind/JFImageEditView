//
//  JFResizeView.h
//  图片编辑器
//
//  Created by 168licai on 2018/4/8.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 图片方向
 */
typedef NS_ENUM(NSUInteger, JFResizerRotationDirection) {
    JFResizerRotationDirectionUp = 0,
    JFResizerRotationDirectionLeft,
    JFResizerRotationDirectionDown,
    JFResizerRotationDirectionRight
};
/**
 * 边框样式
 * JFResizerFrameTypeEightDirection：简洁样式，可拖拽8个方向（固定比例则4个方向）
 * JFResizerFrameTypeFourDirection：简洁样式，可拖拽4个方向（4角）
 */
typedef NS_ENUM(NSUInteger, JFResizerFrameType) {
    JFResizerFrameTypeEightDirection, // default
    JFResizerFrameTypeFourDirection,
};
/**
 * 是否可以重置的回调
 * 当裁剪区域缩放至适应范围后就会触发该回调
 - YES：可重置
 - NO：不需要重置，裁剪区域跟图片区域一致，并且没有旋转、镜像过
 */
typedef void(^JPImageresizerIsCanRecoveryBlock)(BOOL isCanRecovery);

/**
 * 是否预备缩放裁剪区域至适应范围
 * 当裁剪区域发生变化的开始和结束就会触发该回调
 - YES：预备缩放，此时裁剪、旋转、镜像功能不可用
 - NO：没有预备缩放
 */
typedef void(^JPImageresizerIsPrepareToScaleBlock)(BOOL isPrepareToScale);


@interface JFResizeView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                resizeFrame:(CGRect)resizeFrame
                 imgOrignSize:(CGSize)imgOrignSize
                    frameType:(JFResizerFrameType)frameType
                resizeWHScale:(CGFloat)resizeWHScale
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView;






@end
