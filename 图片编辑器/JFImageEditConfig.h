//
//  JFImageEditConfig.h
//  图片编辑器
//
//  Created by 168licai on 2018/4/17.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import <Foundation/Foundation.h>
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


@interface JFImageEditConfig : NSObject

@property(nonatomic,assign)BOOL isEditClip;//用来标记当前是否是在剪裁状态

@property(nonatomic,strong)UIImage *originImage;//用来保存原始图片

@property(nonatomic,strong)UIImage *nowEditImage;//实时保存图片（不论是修改后还是原始的）

@property(nonatomic)CGRect originImageFrame;//原始图片的坐标

@property(nonatomic)CGFloat originWHScale;//原始图片比例

@property(nonatomic,assign)JFResizerRotationDirection imageRotationDirection;//图片的旋转方向

@property(nonatomic,assign)NSTimeInterval animationDuration;//统一动画时长


//resizeView配置
@property(nonatomic)CGRect origionReSizeViewFrame;//用来保存刚开始剪裁的resizeView剪裁区域的坐标，是原始的第一次
@property(nonatomic)CGRect reSizeViewFrame;//实时用来保存resizeView剪裁区域的坐标
@property(nonatomic)CGFloat dotScopeWH;//顶点圆形四周范围宽高
@property(nonatomic)CGFloat dotWH;//八个方向边框顶点圆形的宽高
@property(nonatomic)CGFloat minResizeWH;//可以缩小的最小的剪裁区域的宽和高 正方形

+ (instancetype)share;

-(void)constantConfig;

@end
