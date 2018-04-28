//
//  JFResizeView.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/8.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "JFResizeView.h"



//左右边距
#define kSPACE (10)
/** keypath */
#define aKeyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))
typedef NS_ENUM(NSUInteger, DotPoint) {
    LeftTop,
    LeftMid,
    LeftBottom,
    RightTop,
    RightMid,
    RightBottom,
    TopMid,
    BottomMid,
    NotDotPoint
};

@interface JFResizeView(){
  
    CGRect _maxResizeFrame;//剪裁框最大的frame 宽度为self.width-2*kspace
    CGFloat _imgScale;//用来记录图片放大的倍数
    UIScrollView *_scrollView;
    UIImageView *_editImageView;
    DotPoint _witchDotPoint;//拖拉剪裁框时，存储哪一个点被点击
    JFImageEditConfig *_editConfig;
    
    
    BOOL _isPanChangeSelectedSucceed;//用来标志此时是否在pan里面change选中了
    
}

@property(nonatomic,strong)CAShapeLayer *bgLayer;//蒙版layer
@property (nonatomic, weak) CAShapeLayer *frameLayer;//白色宽
@property (nonatomic, weak) CAShapeLayer *leftTopDot;
@property (nonatomic, weak) CAShapeLayer *leftMidDot;
@property (nonatomic, weak) CAShapeLayer *leftBottomDot;
@property (nonatomic, weak) CAShapeLayer *rightTopDot;
@property (nonatomic, weak) CAShapeLayer *rightMidDot;
@property (nonatomic, weak) CAShapeLayer *rightBottomDot;
@property (nonatomic, weak) CAShapeLayer *topMidDot;
@property (nonatomic, weak) CAShapeLayer *bottomMidDot;

@property(nonatomic)CGFloat resizeFrameX;
@property(nonatomic)CGFloat resizeFrameY;
@property(nonatomic)CGFloat resizeFrameW;
@property(nonatomic)CGFloat resizeFrameH;
@property(nonatomic)CGFloat resizeFrameMaxX;
@property(nonatomic)CGFloat resizeFrameMidX;
@property(nonatomic)CGFloat resizeFrameMaxY;
@property(nonatomic)CGFloat resizeFrameMidY;
@end

@implementation JFResizeView

- (instancetype)initWithFrame:(CGRect)frame
                   editConfig:(JFImageEditConfig *)editConfig
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView{
    if (self = [super initWithFrame:frame]) {
        _editConfig = editConfig;
        _maxResizeFrame = CGRectMake(kSPACE, kSPACE, self.bounds.size.width-2*kSPACE, self.bounds.size.height-2*kSPACE);
        _scrollView = scrollView;
        _editImageView = imageView;
        _imgScale = 1.0;
        _editConfig.reSizeViewFrame = _editConfig.origionReSizeViewFrame;
        [self setResizeUIWithFrame: _editConfig.reSizeViewFrame];
   
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        [self addGestureRecognizer:panGR];
    }
    return self;
}

///**
// 初始化剪裁框
//
// @param resizeFrame <#resizeFrame description#>
// */
//-(void)setUpResizeViewWithResizeFrame:(CGRect)resizeFrame{
//   
//
//}

#pragma mark - setUI
/**
 初始化设置蒙版和剪裁框
 
 @param resizeFrame <#resizeFrame description#>
 */
-(void)setResizeUIWithFrame:(CGRect)resizeFrame{
    

    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [bgPath appendPath:[UIBezierPath bezierPathWithRect:resizeFrame]];
    self.bgLayer.path = bgPath.CGPath;

    self.frameLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.frameLayer.fillColor = [UIColor clearColor].CGColor;
    self.frameLayer.path = [UIBezierPath bezierPathWithRect:_editConfig.reSizeViewFrame].CGPath;
    
    [self updateDotLayerPath];
    
}

/**
 初始化创建shapelayer
 
 @param lineWidth <#lineWidth description#>
 @return <#return value description#>
 */
- (CAShapeLayer *)createShapeLayer:(CGFloat)lineWidth {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.lineWidth = lineWidth;
    [self.layer addSublayer:shapeLayer];
    return shapeLayer;
}

/**
 画一个圆形的角点
 
 @param position <#position description#>
 @return <#return value description#>
 */
- (UIBezierPath *)dotPathWithPosition:(CGPoint)position {
    CGFloat dotWH = _editConfig.dotWH;
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(position.x - dotWH * 0.5, position.y - dotWH * 0.5, dotWH, dotWH)];
    return dotPath;
}

/**
 初始化创建dot
 
 */
-(void)createDotLayer:(CAShapeLayer *)layer dotWithDotPoint:(CGPoint)point{
    layer.path =  [self dotPathWithPosition:point].CGPath;
}



/**
 更新背景bgPath
 */
-(void)updateBgPath{
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [bgPath appendPath:[UIBezierPath bezierPathWithRect:_editConfig.reSizeViewFrame]];
    self.bgLayer.path = bgPath.CGPath;
}
/**
 更新背景FrameLayerPath
 */
-(void)updateFrameLayerPath{
     self.frameLayer.path = [UIBezierPath bezierPathWithRect:_editConfig.reSizeViewFrame].CGPath;
}

/**
 更新生存dot
 */
-(void)updateDotLayerPath{
    [self createDotLayer:self.leftTopDot dotWithDotPoint:CGPointMake(self.resizeFrameX, self.resizeFrameY)];
    [self createDotLayer:self.rightTopDot dotWithDotPoint:CGPointMake(self.resizeFrameMaxX, self.resizeFrameY)];
    [self createDotLayer:self.leftBottomDot dotWithDotPoint:CGPointMake(self.resizeFrameX, self.resizeFrameMaxY)];
    [self createDotLayer:self.rightBottomDot dotWithDotPoint:CGPointMake(self.resizeFrameMaxX, self.resizeFrameMaxY)];
    [self createDotLayer:self.leftMidDot dotWithDotPoint:CGPointMake(self.resizeFrameX, self.resizeFrameMidY)];
    [self createDotLayer:self.rightMidDot dotWithDotPoint:CGPointMake(self.resizeFrameMaxX, self.resizeFrameMidY)];
    [self createDotLayer:self.topMidDot dotWithDotPoint:CGPointMake(self.resizeFrameMidX, self.resizeFrameY)];
    [self createDotLayer:self.bottomMidDot dotWithDotPoint:CGPointMake(self.resizeFrameMidX, self.resizeFrameMaxY)];
}


/**
    panChange时候的更新
 */
-(void)updatebgLayerAndFrameLayerAndDotLayer{
    [CATransaction begin];
    [self updateBgPath];
    [self updateFrameLayerPath];
    [self updateDotLayerPath];
    [CATransaction commit];
}

/**
 pan结束后，再调整resizeView为居中形式
 */
-(void)adjustResizeFrame{
    
    CGFloat scalewh = _maxResizeFrame.size.width/self.resizeFrameW;
    _imgScale = _scrollView.zoomScale*scalewh;
    CGFloat w = _maxResizeFrame.size.width;
    CGFloat h  = self.resizeFrameH*scalewh;
    
    if (h>_maxResizeFrame.size.height) {
        h = _maxResizeFrame.size.height;
        scalewh = h/self.resizeFrameH;
        w = scalewh*self.resizeFrameW;
 
    }
      _editConfig.reSizeViewFrame = CGRectMake((self.bounds.size.width-w)/2, (self.bounds.size.height-h)/2, w, h);
    
    
    
    //计算scrollView放大的倍数
    if (w>_scrollView.frame.size.width||h>_scrollView.frame.size.height) {
        CGFloat scaleW = 1.0;
          CGFloat scaleH = 1.0;
        if (w>_scrollView.frame.size.width) {
            scaleW = w/_scrollView.frame.size.width;
        }
        if (h>_scrollView.frame.size.height) {
            scaleH = h/_scrollView.frame.size.height;
        }
        scalewh = scaleW>scaleH?scaleW:scaleH;
    }
    
     _imgScale = _scrollView.zoomScale*scalewh;


}
/**
 pan结束后，调整scrollView大小
 */
-(void)adjustMainView{
    [UIView animateWithDuration:_editConfig.animationDuration animations:^{
        _scrollView.frame = _editConfig.reSizeViewFrame;
    }];
    
}
/**
 动画调整resizeView视图
 */
-(void)adjustResizeView{
    
    void (^layerPathAnimate)(CAShapeLayer *layer, UIBezierPath *newPath) = ^(CAShapeLayer *layer, UIBezierPath *path) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:aKeyPath(layer, path)];
        anim.fillMode = kCAFillModeBackwards;
        anim.fromValue = [UIBezierPath bezierPathWithCGPath:layer.path];
        anim.toValue = path;
        anim.duration = _editConfig.animationDuration;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [layer addAnimation:anim forKey:@"path"];
    };
    UIBezierPath *leftTopPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameX, self.resizeFrameY)];
     UIBezierPath *rightTopPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameMaxX, self.resizeFrameY)];
    
    UIBezierPath *leftBottomPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameX, self.resizeFrameMaxY)];
    UIBezierPath *rightBottomPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameMaxX, self.resizeFrameMaxY)];
    
    UIBezierPath *leftMidPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameX, self.resizeFrameMidY)];
    UIBezierPath *rightMidPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameMaxX, self.resizeFrameMidY)];
    UIBezierPath *topMidPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameMidX, self.resizeFrameY)];
    UIBezierPath *bottomMidPath =  [self dotPathWithPosition:CGPointMake(self.resizeFrameMidX, self.resizeFrameMaxY)];
    
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [bgPath appendPath:[UIBezierPath bezierPathWithRect:_editConfig.reSizeViewFrame]];
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRect:_editConfig.reSizeViewFrame];
    layerPathAnimate(self.leftTopDot,leftTopPath);
    layerPathAnimate(self.rightTopDot,rightTopPath);
    layerPathAnimate(self.leftBottomDot,leftBottomPath);
    layerPathAnimate(self.rightBottomDot,rightBottomPath);
    layerPathAnimate(self.leftMidDot,leftMidPath);
    layerPathAnimate(self.rightMidDot,rightMidPath);
    layerPathAnimate(self.topMidDot,topMidPath);
    layerPathAnimate(self.bottomMidDot,bottomMidPath);
    layerPathAnimate(self.bgLayer, bgPath);
    layerPathAnimate(self.frameLayer, framePath);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.leftTopDot.path = leftTopPath.CGPath;
    self.rightTopDot.path = rightTopPath.CGPath;
    self.leftBottomDot.path = leftBottomPath.CGPath;
    self.rightBottomDot.path = rightBottomPath.CGPath;
  
        self.leftMidDot.path = leftMidPath.CGPath;
        self.rightMidDot.path = rightMidPath.CGPath;
        self.topMidDot.path = topMidPath.CGPath;
        self.bottomMidDot.path = bottomMidPath.CGPath;
 
   
    _bgLayer.path = bgPath.CGPath;
    _frameLayer.path = framePath.CGPath;
    [CATransaction commit];
}



#pragma mark - UIPanGestureRecognizer

- (void)panHandle:(UIPanGestureRecognizer *)panGR {
    
    
    CGPoint point =  [panGR locationInView:self];
    //用来判断 当point超出pan的范围的时候，就自动adjustFrameView
    if ((point.x<kSPACE)||(point.y<kSPACE)||(point.x>self.bounds.size.width-kSPACE)||(point.y>(self.bounds.size.height-kSPACE))){
        if (_isPanChangeSelectedSucceed == YES) {
            [self panEnd];
        }
        return;
    }

    
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan:{
          
            if ([self judegPointInDotScopeWithPoint:point]) {
                _isPanChangeSelectedSucceed = YES;
            }else{
                _isPanChangeSelectedSucceed = NO;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (_isPanChangeSelectedSucceed) {
                CGFloat x = self.resizeFrameX;
                CGFloat y = self.resizeFrameY;
                CGFloat w = self.resizeFrameW;
                CGFloat h = self.resizeFrameH;
                
                switch (_witchDotPoint) {
                    case LeftTop:{
                        
                        if ((point.x+_editConfig.minResizeWH)>self.resizeFrameMaxX) {
                            return;
                        }
                        if ((point.y+_editConfig.minResizeWH)>self.resizeFrameMaxY) {
                            return;
                        }
                        
                        x = point.x;
                        y = point.y;
                        w = self.resizeFrameMaxX-x;
                        h = self.resizeFrameMaxY - y;
                        
                    }
                        break;
                    case LeftMid:{
                        if ((point.x+_editConfig.minResizeWH)>self.resizeFrameMaxX) {
                            return;
                        }
                        x = point.x;
                        w = self.resizeFrameMaxX-x;
                    }
                        break;
                    case LeftBottom:{
                        if ((point.x+_editConfig.minResizeWH)>self.resizeFrameMaxX) {
                            return;
                        }
                        if ((point.y-_editConfig.minResizeWH)<self.resizeFrameY) {
                            return;
                        }
                        x = point.x;
                        w = self.resizeFrameMaxX-x;
                        h = point.y-self.resizeFrameY;
                    }
                        break;
                    case RightTop:{
                        
                        if ((point.x-_editConfig.minResizeWH)<self.resizeFrameX) {
                            return;
                        }
                        if ((point.y+_editConfig.minResizeWH)>self.resizeFrameMaxY) {
                            return;
                        }
                        
                        y = point.y;
                        w = point.x-self.resizeFrameX;
                        h = self.resizeFrameMaxY - y;
                        
                    }
                        break;
                    case RightMid:{
                        if ((point.x-_editConfig.minResizeWH)<self.resizeFrameX) {
                            return;
                        }
                       
                         w = point.x-self.resizeFrameX;
                    }
                        break;
                    case RightBottom:{
                        if ((point.x-_editConfig.minResizeWH)<self.resizeFrameX) {
                            return;
                        }
                        if ((point.y-_editConfig.minResizeWH)<self.resizeFrameY) {
                            return;
                        }
                    
                        w = point.x-self.resizeFrameX;
                        h = point.y-self.resizeFrameY;
                    }
                        break;
                    case TopMid:{
                       
                        if ((point.y+_editConfig.minResizeWH)>self.resizeFrameMaxY) {
                            return;
                        }
                        y = point.y;
                        h = self.resizeFrameMaxY-point.y;
                    }
                        break;
                    case BottomMid:{
                        
                        if ((point.y-_editConfig.minResizeWH)<self.resizeFrameY) {
                            return;
                        }
                     
                        h = point.y - self.resizeFrameY;
                    }
                        break;
                    default:
                        break;
                        
                }
                _editConfig.reSizeViewFrame = CGRectMake(x, y, w, h);
                [self updatebgLayerAndFrameLayerAndDotLayer];
            }
            
        }
            
            
            break;
        case UIGestureRecognizerStateEnded:
             case UIGestureRecognizerStateCancelled:
                case UIGestureRecognizerStateFailed:
       
            [self panEnd];
    
            break;
     

        default:
            break;
    }
    

    
}

-(void)panEnd{
    
    [self adjustResizeFrame];
    [self adjustResizeView];
    [self adjusetImageSize];
    [self adjustMainView];
 
  
    _isPanChangeSelectedSucceed = NO;
}

-(void)adjusetImageSize{
    
    [UIView animateWithDuration:_editConfig.animationDuration animations:^{
          _scrollView.zoomScale = _imgScale;
    }];
  
    
}
#pragma mark - public
-(void)resizeViewReset{
    
    _editConfig.reSizeViewFrame = _editConfig.origionReSizeViewFrame;
     _imgScale = 1.0;
    
    [self updateBgPath];
    [self updateFrameLayerPath];
    [self updateDotLayerPath];
    
    [UIView animateWithDuration:_editConfig.animationDuration animations:^{
        _scrollView.frame = _editConfig.origionReSizeViewFrame;
        _scrollView.contentSize = _editConfig.origionReSizeViewFrame.size;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.zoomScale = _imgScale;
    }];
    
}

#pragma mark - private
/**
 判断点击在哪一个dot
 
 @param point <#point description#>
 @return <#return value description#>
 */
-(BOOL)judegPointInDotScopeWithPoint:(CGPoint)point{
    
    if (CGRectContainsPoint(CGRectMake(self.resizeFrameX-_editConfig.dotScopeWH/2, self.resizeFrameY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)) {
        _witchDotPoint = LeftTop;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameX-_editConfig.dotScopeWH/2, self.resizeFrameMidY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)){
        _witchDotPoint = LeftMid;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameX-_editConfig.dotScopeWH/2, self.resizeFrameMaxY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)){
        _witchDotPoint = LeftBottom;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMaxX-_editConfig.dotScopeWH/2, self.resizeFrameY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)){
        _witchDotPoint = RightTop;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMaxX-_editConfig.dotScopeWH/2, self.resizeFrameMidY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)){
        _witchDotPoint = RightMid;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMaxX-_editConfig.dotScopeWH/2, self.resizeFrameMaxY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)){
        _witchDotPoint = RightBottom;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMidX-_editConfig.dotScopeWH/2, self.resizeFrameY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)){
        _witchDotPoint = TopMid;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMidX-_editConfig.dotScopeWH/2, self.resizeFrameMaxY-_editConfig.dotScopeWH/2, _editConfig.dotScopeWH, _editConfig.dotScopeWH), point)){
        _witchDotPoint = BottomMid;
        return YES;
    }else{
        _witchDotPoint = NotDotPoint;
        return NO;
    }
}

-(void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - event
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    CGFloat x = self.resizeFrameX+_editConfig.dotScopeWH/2;
    CGFloat y = self.resizeFrameY + _editConfig.dotScopeWH/2;
    CGFloat w = self.resizeFrameW-_editConfig.dotScopeWH;
    CGFloat h = self.resizeFrameH-_editConfig.dotScopeWH;
    CGRect rect =  CGRectMake(x, y, w, h);
    if (CGRectContainsPoint(rect, point)) {
        self.userInteractionEnabled = NO;
    }else{
        self.userInteractionEnabled = YES;
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - getter
- (CAShapeLayer *)frameLayer {
    if (!_frameLayer){
        _frameLayer = [self createShapeLayer:1];
    }
    return _frameLayer;
}

- (CAShapeLayer *)bgLayer {
    if (!_bgLayer){
        _bgLayer = [self createShapeLayer:0];
       _bgLayer.fillRule = kCAFillRuleEvenOdd;
      _bgLayer.fillColor = [UIColor colorWithRed:192/255 green:192/255 blue:192/255 alpha:0.5].CGColor;
    }
    return _bgLayer;
}
- (CAShapeLayer *)leftTopDot {
    if (!_leftTopDot){
        _leftTopDot = [self createShapeLayer:0];
        _leftTopDot.fillColor = [UIColor whiteColor].CGColor;
    }
    return _leftTopDot;
}

- (CAShapeLayer *)leftMidDot {
    if (!_leftMidDot) {
        _leftMidDot = [self createShapeLayer:0];
        _leftMidDot.fillColor = [UIColor whiteColor].CGColor;
    }
    
    return _leftMidDot;
}

- (CAShapeLayer *)leftBottomDot {
    if (!_leftBottomDot) {
        _leftBottomDot = [self createShapeLayer:0];
         _leftBottomDot.fillColor = [UIColor whiteColor].CGColor;
    }
    return _leftBottomDot;
}

- (CAShapeLayer *)rightTopDot {
    if (!_rightTopDot){
         _rightTopDot = [self createShapeLayer:0];
         _rightTopDot.fillColor = [UIColor whiteColor].CGColor;
    }
    return _rightTopDot;
}

- (CAShapeLayer *)rightMidDot {
    if (!_rightMidDot){
         _rightMidDot = [self createShapeLayer:0];
          _rightMidDot.fillColor = [UIColor whiteColor].CGColor;
    }
   
    return _rightMidDot;
}

- (CAShapeLayer *)rightBottomDot {
    if (!_rightBottomDot){
         _rightBottomDot = [self createShapeLayer:0];
         _rightBottomDot.fillColor = [UIColor whiteColor].CGColor;
    }
    return _rightBottomDot;
}

- (CAShapeLayer *)topMidDot {
    if (!_topMidDot) {
        _topMidDot = [self createShapeLayer:0];
         _topMidDot.fillColor = [UIColor whiteColor].CGColor;
    }
    return _topMidDot;
}

- (CAShapeLayer *)bottomMidDot {
    if (!_bottomMidDot) {
        _bottomMidDot = [self createShapeLayer:0];
         _bottomMidDot.fillColor = [UIColor whiteColor].CGColor;
    }
    return _bottomMidDot;
}


- (CGFloat)resizeFrameX {
    return _editConfig.reSizeViewFrame.origin.x;
}
- (CGFloat)resizeFrameY {
    return _editConfig.reSizeViewFrame.origin.y;
}
- (CGFloat)resizeFrameW {
    return _editConfig.reSizeViewFrame.size.width;
}
- (CGFloat)resizeFrameH {
    return _editConfig.reSizeViewFrame.size.height;
}
-(CGFloat)resizeFrameMaxX{
    return CGRectGetMaxX(_editConfig.reSizeViewFrame);
}
-(CGFloat)resizeFrameMidX{
    return CGRectGetMidX(_editConfig.reSizeViewFrame);
}
-(CGFloat)resizeFrameMaxY{
    return CGRectGetMaxY(_editConfig.reSizeViewFrame);
}
-(CGFloat)resizeFrameMidY{
    return CGRectGetMidY(_editConfig.reSizeViewFrame);
}


@end
