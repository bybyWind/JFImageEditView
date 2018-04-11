//
//  JFResizeView.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/8.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "JFResizeView.h"
#define kANIMATIONDURATION (0.27)
#define kDOTWH (10.0)
#define kSCOPEWH (50.0)
#define kMINRESIZEWH (100.0)
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
    NSTimeInterval _animationDuration;
    CGFloat _dotWH;//八个方向边框顶点圆形的宽高
    CGFloat _arrLineW;//线条的宽度
    CGFloat _arrLength;//四个方向边框的线条长度
    CGFloat _scopeWH;//顶点圆形四周范围宽高
    CGFloat _minResizeWH;//可以缩小的最小的剪裁区域
    JFResizerRotationDirection _resizerRotationDirection;//图片当前方向
    CGSize _imgOrignSize;//记录原始图片大小
    CGRect _reSizeFrame;//裁剪边框的坐标
    CGRect _imgFrame;//用来记录图片的frame;
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    NSString *_kCAMediaTimingFunction;
    DotPoint _witchDotPoint;//拖拉剪裁框时，存储哪一个点被点击
    
    
    
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
                  resizeFrame:(CGRect)resizeFrame
                 imgOrignSize:(CGSize)imgOrignSize
                    frameType:(JFResizerFrameType)frameType
                resizeWHScale:(CGFloat)resizeWHScale
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView{
    if (self = [super initWithFrame:frame]) {
        
   
        _dotWH = kDOTWH;
        _arrLineW = 2.5;
        _arrLength = 20.0;
        _scopeWH = kSCOPEWH;
        _minResizeWH = kMINRESIZEWH;
        _resizerRotationDirection = JFResizerRotationDirectionUp;
        _imgOrignSize = imgOrignSize;
        _scrollView = scrollView;
        _imageView = imageView;
        _reSizeFrame = resizeFrame;
        _imgFrame =resizeFrame;
        
        
        
        [self setResizeUIWithFrame:_reSizeFrame];
  
        
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        [self addGestureRecognizer:panGR];
       
    }
    return self;
}


#pragma mark - setUI
/**
 初始化设置蒙版和剪裁框
 
 @param resizeFrame <#resizeFrame description#>
 */
-(void)setResizeUIWithFrame:(CGRect)resizeFrame{
    
    self.bgLayer = [self createShapeLayer:0];
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [bgPath appendPath:[UIBezierPath bezierPathWithRect:resizeFrame]];
    self.bgLayer.path = bgPath.CGPath;
    self.bgLayer.fillRule = kCAFillRuleEvenOdd;
    self.bgLayer.fillColor = [UIColor colorWithRed:192/255 green:192/255 blue:192/255 alpha:0.5].CGColor;
    self.frameLayer = [self createShapeLayer:1];
    self.frameLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.frameLayer.fillColor = [UIColor clearColor].CGColor;
    self.frameLayer.path = [UIBezierPath bezierPathWithRect:_reSizeFrame].CGPath;
    
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
    CGFloat dotWH = _dotWH;
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
    [bgPath appendPath:[UIBezierPath bezierPathWithRect:_reSizeFrame]];
    self.bgLayer.path = bgPath.CGPath;
}
/**
 更新背景FrameLayerPath
 */
-(void)updateFrameLayerPath{
     self.frameLayer.path = [UIBezierPath bezierPathWithRect:_reSizeFrame].CGPath;
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

-(void)updatebgLayerAndFrameLayerAndDotLayer{
    [CATransaction begin];
    [self updateBgPath];
    [self updateFrameLayerPath];
    [self updateDotLayerPath];
    [CATransaction commit];
}


#pragma mark - UIPanGestureRecognizer

- (void)panHandle:(UIPanGestureRecognizer *)panGR {
    
    
    
    CGPoint point =  [panGR locationInView:self];
  
    if (point.x<kSPACE) return;
    if (point.y<kSPACE) return;
    if (point.x>self.bounds.size.width-kSPACE) {
        return;
    }
    if (point.y>(self.bounds.size.height-kSPACE)) {
        return;
    }
    

    
    
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan:{
              NSLog(@"start");
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
                        
                        if ((point.x+kMINRESIZEWH)>self.resizeFrameMaxX) {
                            return;
                        }
                        if ((point.y+kMINRESIZEWH)>self.resizeFrameMaxY) {
                            return;
                        }
                        
                        x = point.x;
                        y = point.y;
                        w = self.resizeFrameMaxX-x;
                        h = self.resizeFrameMaxY - y;
                        
                    }
                        break;
                    case LeftMid:{
                        if ((point.x+kMINRESIZEWH)>self.resizeFrameMaxX) {
                            return;
                        }
                        x = point.x;
                        w = self.resizeFrameMaxX-x;
                    }
                        break;
                    case LeftBottom:{
                        if ((point.x+kMINRESIZEWH)>self.resizeFrameMaxX) {
                            return;
                        }
                        if ((point.y-kMINRESIZEWH)<self.resizeFrameY) {
                            return;
                        }
                        x = point.x;
                        w = self.resizeFrameMaxX-x;
                        h = point.y-self.resizeFrameY;
                    }
                        break;
                    case RightTop:{
                        
                        if ((point.x-kMINRESIZEWH)<self.resizeFrameX) {
                            return;
                        }
                        if ((point.y+kMINRESIZEWH)>self.resizeFrameMaxY) {
                            return;
                        }
                        
                        y = point.y;
                        w = point.x-self.resizeFrameX;
                        h = self.resizeFrameMaxY - y;
                        
                    }
                        break;
                    case RightMid:{
                        if ((point.x-kMINRESIZEWH)<self.resizeFrameX) {
                            return;
                        }
                       
                         w = point.x-self.resizeFrameX;
                    }
                        break;
                    case RightBottom:{
                        if ((point.x-kMINRESIZEWH)<self.resizeFrameX) {
                            return;
                        }
                        if ((point.y-kMINRESIZEWH)<self.resizeFrameY) {
                            return;
                        }
                    
                        w = point.x-self.resizeFrameX;
                        h = point.y-self.resizeFrameY;
                    }
                        break;
                    case TopMid:{
                       
                        if ((point.y+kMINRESIZEWH)>self.resizeFrameMaxY) {
                            return;
                        }
                        y = point.y;
                        h = self.resizeFrameMaxY-point.y;
                    }
                        break;
                    case BottomMid:{
                        
                        if ((point.y-kMINRESIZEWH)<self.resizeFrameY) {
                            return;
                        }
                     
                        h = point.y - self.resizeFrameY;
                    }
                        break;
                    default:
                        break;
                        
                }
                _reSizeFrame = CGRectMake(x, y, w, h);
                [self updatebgLayerAndFrameLayerAndDotLayer];
            }
            
        }
            
            
            break;
        case UIGestureRecognizerStateEnded:{
            
              _isPanChangeSelectedSucceed = NO;
        }
            
            break;
        default:
            break;
    }
    
    
    
}




#pragma mark - private
/**
 判断点击在哪一个dot
 
 @param point <#point description#>
 @return <#return value description#>
 */
-(BOOL)judegPointInDotScopeWithPoint:(CGPoint)point{
    
    if (CGRectContainsPoint(CGRectMake(self.resizeFrameX-_scopeWH/2, self.resizeFrameY-_scopeWH/2, _scopeWH, _scopeWH), point)) {
        _witchDotPoint = LeftTop;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameX-_scopeWH/2, self.resizeFrameMidY-_scopeWH/2, _scopeWH, _scopeWH), point)){
        _witchDotPoint = LeftMid;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameX-_scopeWH/2, self.resizeFrameMaxY-_scopeWH/2, _scopeWH, _scopeWH), point)){
        _witchDotPoint = LeftBottom;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMaxX-_scopeWH/2, self.resizeFrameY-_scopeWH/2, _scopeWH, _scopeWH), point)){
        _witchDotPoint = RightTop;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMaxX-_scopeWH/2, self.resizeFrameMidY-_scopeWH/2, _scopeWH, _scopeWH), point)){
        _witchDotPoint = RightMid;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMaxX-_scopeWH/2, self.resizeFrameMaxY-_scopeWH/2, _scopeWH, _scopeWH), point)){
        _witchDotPoint = RightBottom;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMidX-_scopeWH/2, self.resizeFrameY-_scopeWH/2, _scopeWH, _scopeWH), point)){
        _witchDotPoint = TopMid;
        return YES;
    }else if (CGRectContainsPoint(CGRectMake(self.resizeFrameMidX-_scopeWH/2, self.resizeFrameMaxY-_scopeWH/2, _scopeWH, _scopeWH), point)){
        _witchDotPoint = BottomMid;
        return YES;
    }else{
        _witchDotPoint = NotDotPoint;
        return NO;
    }
}

#pragma mark - event
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    NSLog(@"hit");
    CGFloat x = self.resizeFrameX+_scopeWH/2;
    CGFloat y = self.resizeFrameY + _scopeWH/2;
    CGFloat w = self.resizeFrameW-_scopeWH;
    CGFloat h = self.resizeFrameH-_scopeWH;
    CGRect rect =  CGRectMake(x, y, w, h);
    if (CGRectContainsPoint(rect, point)) {
        self.userInteractionEnabled = NO;
    }else{
        self.userInteractionEnabled = YES;
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - getter
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
    return _reSizeFrame.origin.x;
}
- (CGFloat)resizeFrameY {
    return _reSizeFrame.origin.y;
}
- (CGFloat)resizeFrameW {
    return _reSizeFrame.size.width;
}
- (CGFloat)resizeFrameH {
    return _reSizeFrame.size.height;
}
-(CGFloat)resizeFrameMaxX{
    return CGRectGetMaxX(_reSizeFrame);
}
-(CGFloat)resizeFrameMidX{
    return CGRectGetMidX(_reSizeFrame);
}
-(CGFloat)resizeFrameMaxY{
    return CGRectGetMaxY(_reSizeFrame);
}
-(CGFloat)resizeFrameMidY{
    return CGRectGetMidY(_reSizeFrame);
}
-(void)updateUIBezierPathWithresizeFrame:(CGRect)resizeFrame{
    
    CGRect imageresizerFrame = _imageView.frame;
    
    CGFloat imageresizerX = imageresizerFrame.origin.x;
    CGFloat imageresizerY = imageresizerFrame.origin.y;
    CGFloat imageresizerMidX = CGRectGetMidX(imageresizerFrame);
    CGFloat imageresizerMidY = CGRectGetMidY(imageresizerFrame);
    CGFloat imageresizerMaxX = CGRectGetMaxX(imageresizerFrame);
    CGFloat imageresizerMaxY = CGRectGetMaxY(imageresizerFrame);
    
    UIBezierPath *leftTopDotPath;
    UIBezierPath *leftBottomDotPath;
    UIBezierPath *rightTopDotPath;
    UIBezierPath *rightBottomDotPath;
    
    UIBezierPath *leftMidDotPath;
    UIBezierPath *rightMidDotPath;
    UIBezierPath *topMidDotPath;
    UIBezierPath *bottomMidDotPath;
    
    UIBezierPath *horTopLinePath;
    UIBezierPath *horBottomLinePath;
    UIBezierPath *verLeftLinePath;
    UIBezierPath *verRightLinePath;
    
    
    leftTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerY)];
    leftBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMaxY)];
    rightTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerY)];
    rightBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMaxY)];
    
    
    leftMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMidY)];
    rightMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMidY)];
    topMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerY)];
    bottomMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerMaxY)];
    
    
    
    
    UIBezierPath *bgPath;
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRect:resizeFrame];
    bgPath = [UIBezierPath bezierPathWithRect:self.bgLayer.frame];
    [bgPath appendPath:framePath];
    
    
    void (^layerPathAnimate)(CAShapeLayer *layer, UIBezierPath *path) = ^(CAShapeLayer *layer, UIBezierPath *path) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:aKeyPath(layer, path)];
        anim.fillMode = kCAFillModeBackwards;
        anim.fromValue = [UIBezierPath bezierPathWithCGPath:layer.path];
        anim.toValue = path;
        anim.duration = _animationDuration;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [layer addAnimation:anim forKey:@"path"];
    };
    
    layerPathAnimate(self.leftTopDot, leftTopDotPath);
    layerPathAnimate(self.leftBottomDot, leftBottomDotPath);
    layerPathAnimate(self.rightTopDot, rightTopDotPath);
    layerPathAnimate(self.rightBottomDot, rightBottomDotPath);
    layerPathAnimate(self.leftMidDot, leftMidDotPath);
    layerPathAnimate(self.rightMidDot, rightMidDotPath);
    layerPathAnimate(self.topMidDot, topMidDotPath);
    layerPathAnimate(self.bottomMidDot, bottomMidDotPath);
    layerPathAnimate(self.bgLayer, bgPath);
    layerPathAnimate(self.frameLayer, framePath);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _leftTopDot.path = leftTopDotPath.CGPath;
    _leftBottomDot.path = leftBottomDotPath.CGPath;
    _rightTopDot.path = rightTopDotPath.CGPath;
    _rightBottomDot.path = rightBottomDotPath.CGPath;
    
    _leftMidDot.path = leftMidDotPath.CGPath;
    _rightMidDot.path = rightMidDotPath.CGPath;
    _topMidDot.path = topMidDotPath.CGPath;
    _bottomMidDot.path = bottomMidDotPath.CGPath;
    
    
    
    _bgLayer.path = bgPath.CGPath;
    _frameLayer.path = framePath.CGPath;
    [CATransaction commit];
}


@end
