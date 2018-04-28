//
//  JFImageMainView.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/10.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "JFImageMainView.h"
#import "JFResizeView.h"
#import "UIImage+JFExtension.h"


//左右边距
#define kSPACE (10)

@interface JFImageMainView()<UIScrollViewDelegate>{

    JFImageEditConfig *_editConfig;
}

@property(nonatomic,strong)UIScrollView *bgScrollView;//底部scrollView
@property(nonatomic,strong)UIImageView *editImageView;//编辑的图片
@property (nonatomic, strong)JFResizeView *resizeView;//蒙版剪裁的视图

@end

@implementation JFImageMainView

- (instancetype)initWithFrame:(CGRect)frame editConfig:(JFImageEditConfig *)editConfig{
    
    if (self = [super initWithFrame:frame]) {
    
        _editConfig = editConfig;
        _editConfig.nowEditImage = _editConfig.originImage;
        [self setUpbgScrollViewAndEditImageViewWithImage:_editConfig.originImage];
        [ _editConfig addObserver:self forKeyPath:@"nowEditImage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

    
    }
    
    return self;
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"nowEditImage"])
    {
          [self setUpbgScrollViewAndEditImageViewWithImage:_editConfig.nowEditImage];
    }
}

/**
 通过image创建bgScrollView和EditImageView

 @param image <#image description#>
 */
-(void)setUpbgScrollViewAndEditImageViewWithImage:(UIImage*)image{
    
    CGSize orignSize = image.size;
    _editConfig.originWHScale = orignSize.width/orignSize.height;
    CGFloat maxH = self.bounds.size.height-2*kSPACE;
    CGFloat maxW = self.bounds.size.width-2*kSPACE;
    CGFloat imageW = maxW;
    CGFloat imageH = imageW/_editConfig.originWHScale;
    if (imageH>maxH) {
        imageH = maxH;
        imageW = imageH * _editConfig.originWHScale;
    }
    self.bgScrollView.frame = CGRectMake(0, 0, imageW, imageH);//scrollView的宽高和剪裁框的宽高一样，初始化就和imageView的宽高一样
    self.bgScrollView.contentSize = CGSizeMake(imageW, imageH);
    self.bgScrollView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.editImageView.image = image;
    self.editImageView.frame = CGRectMake(0, 0, imageW, imageH);
    self.editImageView.center = CGPointMake(imageW/2, imageH/2);
 
}

/**
 创建resizeFrameView
 
 @param image <#image description#>
 */
-(void)setUpResizeFrameWithImage:(UIImage *)image{
    _editConfig.originImageFrame = self.editImageView.frame;
    _editConfig.origionReSizeViewFrame = self.bgScrollView.frame;
    _editConfig.reSizeViewFrame = self.bgScrollView.frame;//初始剪裁区域的坐标就是scrollView的坐标
    
    
    [self.resizeView removeFromSuperview];
    self.resizeView = nil;
    [self addSubview:self.resizeView];//每次都重新生成resizeView
}

#pragma mark - Public
/**
 开始剪裁
 */
-(void)imageMainViewOpenClip{
    self.bgScrollView.userInteractionEnabled = YES;
    [self setUpResizeFrameWithImage:_editConfig.nowEditImage];
}
/**
 取消剪裁
 */
-(void)imageMainViewCancelClip{
    [self.resizeView resizeViewReset];
    self.bgScrollView.userInteractionEnabled = NO;
    [self.resizeView removeFromSuperview];
    self.resizeView = nil;
}
/**
 完成剪裁
 */
-(void)imageMainViewAccomplishClip{
    self.bgScrollView.userInteractionEnabled = NO;
    [self.resizeView removeFromSuperview];
    self.resizeView = nil;
    
    
    //生成剪裁后的UIImage
    CGFloat xScale = _editConfig.nowEditImage.size.width/_editImageView.frame.size.width;//获取x方向的比例
    CGFloat yScale = _editConfig.nowEditImage.size.height/_editImageView.frame.size.height;//获取y方向的比例
    CGRect cropRect = [self convertRect:_editConfig.reSizeViewFrame toView:_bgScrollView];//获取resizeViewFrame在scrollView上的坐标系
    _editConfig.nowEditImage = [UIImage getPartOfImage:_editConfig.nowEditImage rect:CGRectMake(cropRect.origin.x*xScale, cropRect.origin.y*yScale, cropRect.size.width*xScale, cropRect.size.height*yScale)];
}

/**
 旋转
 */
-(void)imageMainViewRotate{
    _editConfig.nowEditImage =  [_editConfig.nowEditImage jf_rotate:UIImageOrientationLeft];
}
/**
 剪裁重置
 */
-(void)imageMainViewResetClip{
    
    [self.resizeView resizeViewReset];
    
}
/**
 旋转重置
 */
-(void)imageMainViewResetRotate{
    switch (_editConfig.imageRotationDirection) {
        case JFResizerRotationDirectionUp:
            return;
            break;
        case JFResizerRotationDirectionLeft:
             _editConfig.nowEditImage = [_editConfig.nowEditImage jf_rotate:UIImageOrientationRight];
            break;
        case JFResizerRotationDirectionDown:
             _editConfig.nowEditImage = [_editConfig.nowEditImage jf_rotate:UIImageOrientationDown];
            break;
        case JFResizerRotationDirectionRight:
            _editConfig.nowEditImage = [_editConfig.nowEditImage jf_rotate:UIImageOrientationLeft];
            break;
        default:
            break;
    }
    _editConfig.imageRotationDirection = JFResizerRotationDirectionUp;
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
    
    
    CGFloat resizeW = _editConfig.reSizeViewFrame.size.width;
    CGFloat resizeH = _editConfig.reSizeViewFrame.size.height;
    //当原始图片的宽高小于resizeView的时候就要限制minScale ，让图片的大小始终大于等于剪裁框的大小
    if ((_editConfig.originImageFrame.size.width<resizeW)||(_editConfig.originImageFrame.size.height<resizeH)) {
        CGFloat scaleW = 1.0;
        CGFloat scaleH = 1.0;
        if(_editConfig.originImageFrame.size.width<resizeW) scaleW = resizeW/_editConfig.originImageFrame.size.width;
        if(_editConfig.originImageFrame.size.height<resizeH) scaleH = resizeH/_editConfig.originImageFrame.size.height;
        scrollView.minimumZoomScale = scaleW>scaleH?scaleW:scaleH;
        
    }else{
        
        scrollView.minimumZoomScale = 1.0;
        
    }
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    scrollView.contentSize = view.frame.size;
}

#pragma mark - getter

-(JFResizeView *)resizeView{
    if (!_resizeView) {
        _resizeView = [[JFResizeView alloc] initWithFrame:self.bounds editConfig:_editConfig scrollView:self.bgScrollView imageView:self.editImageView];
        
    }
    return _resizeView;
}

-(UIScrollView *)bgScrollView{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc] init];
        _bgScrollView.delegate = self;
        _bgScrollView.backgroundColor = [UIColor clearColor];
        _bgScrollView.minimumZoomScale = 1.0;
        _bgScrollView.alwaysBounceVertical = YES;
        _bgScrollView.alwaysBounceHorizontal = YES;
        _bgScrollView.userInteractionEnabled = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.autoresizingMask = UIViewAutoresizingNone;
        _bgScrollView.clipsToBounds = NO;
        _bgScrollView.maximumZoomScale = 5.0;
        if (@available(iOS 11.0, *)) _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [self addSubview:_bgScrollView];
    }
    return _bgScrollView;
}

-(UIImageView *)editImageView{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc] init];
        _editImageView.userInteractionEnabled = YES;
        [self.bgScrollView addSubview:  _editImageView];
    }
    
    return _editImageView;
}

/**
 移除观察者
 */
- (void)dealloc
{
    [_editConfig removeObserver:self forKeyPath:@"nowEditImage" context:nil];
}

@end
