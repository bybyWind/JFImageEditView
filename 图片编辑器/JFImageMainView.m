//
//  JFImageMainView.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/10.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "JFImageMainView.h"
#import "JFResizeView.h"

//左右边距
#define kSPACE (10)

@interface JFImageMainView()<UIScrollViewDelegate>{
    UIImage *_originImage;//用来保存原始图片
    CGRect _originImageFrame;//原始图片的坐标
    CGFloat _whScale;//原始图片比例
    CGRect _reSizeFrame;//用来保存resizeView剪裁区域的坐标
}
@property(nonatomic,strong)UIScrollView *bgScrollView;//底部scrollView
@property(nonatomic,strong)UIImageView *editImageView;//编辑的图片
@property (nonatomic, strong)JFResizeView *resizeView;//蒙版剪裁的视图
@end

@implementation JFImageMainView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image{
    
    if (self = [super initWithFrame:frame]) {
        _originImage = image;
        [self setUpUIWithImage:image];
      
    }
    
    return self;
    
}

-(void)setUpUIWithImage:(UIImage*)image{
    
    CGSize orignSize = image.size;
    _whScale = orignSize.width/orignSize.height;
    CGFloat maxH = self.bounds.size.height;
    CGFloat maxW = self.bounds.size.width-2*kSPACE;
    CGFloat imageW = maxW;
    CGFloat imageH = imageW/_whScale;
    if (imageH>maxH) {
        imageH = maxH;
        imageW = imageH * _whScale;
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    
    scrollView.backgroundColor = [UIColor blueColor];
    
    scrollView.frame = CGRectMake(0, 0, imageW, imageH);//scrollView的宽高和剪裁框的宽高一样，初始化就和imageView的宽高一样
    scrollView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 10.0;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.clipsToBounds = NO;
    if (@available(iOS 11.0, *)) scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self addSubview:scrollView];
    self.bgScrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, imageW, imageH);
    imageView.center = CGPointMake(imageW/2, imageH/2);
    imageView.userInteractionEnabled = YES;
    self.editImageView = imageView;
    [self.bgScrollView addSubview:imageView];
    
    
    _originImageFrame = imageView.frame;
    _reSizeFrame = scrollView.frame;//初始剪裁区域的坐标就是scrollView的坐标
    
    JFResizeView *resizeView = [[JFResizeView alloc] initWithFrame:self.bounds resizeFrame:self.bgScrollView.frame imgOrignSize:self.editImageView.frame.size frameType:JFResizerFrameTypeEightDirection resizeWHScale:_whScale scrollView:self.bgScrollView imageView:self.editImageView];
    
    [self addSubview:resizeView];
    
}
#pragma mark - scrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.editImageView;
}
//让图片居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.editImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                            scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view NS_AVAILABLE_IOS(3_2){
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    scrollView.contentSize = view.frame.size;
}



@end
