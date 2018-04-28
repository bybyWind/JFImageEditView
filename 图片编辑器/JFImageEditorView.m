//
//  JFImageEditorView.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/3.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "JFImageEditorView.h"
#import "JFImageMainView.h"
#import "JFImageEditConfig.h"
//编辑器的编辑部分的高度
#define kMAINVIEWHEIGHT (self.bounds.size.height-kBUTTONVIEWHEIGHT*2)
#define kBUTTONVIEWHEIGHT (80)
#define kBUTTONHEIGHT (40)
#define kMENGBANCOLOR ([UIColor colorWithRed:192/255 green:192/255 blue:192/255 alpha:0.5])


@interface JFImageEditorView()

@property(nonatomic,strong)JFImageMainView *mainView;//主视图
@property(nonatomic,strong)UIView *topButtonView;//顶部按钮UIView
@property(nonatomic,strong)UIView *bottomButtonView;//底部按钮UIView
@property(nonatomic,strong)UIButton *editFinishBtn;//完成按钮
@property(nonatomic,strong)UIButton *editCancelBtn;//取消按钮
@property(nonatomic,strong)UIButton *editResetBtn;//重置按钮
@property(nonatomic,strong)UIButton *editRotateBtn;//旋转按钮
@property(nonatomic,strong)UIButton *editClipBtn;//剪裁按钮
@property(nonatomic,strong)UIButton *editDownloadBtn;//保存到相册按钮

//剪裁页面按钮
@property(nonatomic,strong)UIButton *clipCancelBtn;//剪裁取消按钮
@property(nonatomic,strong)UIButton *clipFinishBtn;//剪裁完成按钮
@property(nonatomic,strong)UIButton *clipResetBtn;//剪裁重置按钮

@property(nonatomic,strong)JFImageEditConfig *editConfig;
@end

@implementation JFImageEditorView


- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image{
    
    if (self = [super initWithFrame:frame]) {
        [self editConfig];
        self.editConfig.originImage = image;
        
        [self mainView];
        [self topButtonView];
        [self bottomButtonView];
        [self editCancelBtn];
        [self editFinishBtn];
        [self editResetBtn];
        [self editRotateBtn];
        [self editDownloadBtn];
        [self editClipBtn];
    }
    
    return self;
    
}

#pragma mark - private

#pragma mark - event
/**
 完成按钮点击
 */
-(void)editFinishBtnClick{
    NSLog(@"完成");
    if (self.editConfig.isEditClip) {
        self.editConfig.isEditClip = NO;
        [self changeButtonState];
    }

}
/**
 取消按钮点击
 */
-(void)editCancelButtonClick{
    
    if (self.editConfig.isEditClip) {
        self.editConfig.isEditClip = NO;
        [self changeButtonState];
        [self.mainView imageMainViewCancelClip];
    }

}

/**
 重置按钮点击
 */
-(void)editResetButtonClick{
    if (self.editConfig.isEditClip) {
        [self.mainView imageMainViewResetClip];
    }else{
        [self.mainView imageMainViewResetRotate];
    }
    
}
/**
 旋转按钮点击
 */
-(void)editRotateButtonClick{
    switch (_editConfig.imageRotationDirection) {
        case JFResizerRotationDirectionUp:
            _editConfig.imageRotationDirection = JFResizerRotationDirectionLeft;
            break;
        case JFResizerRotationDirectionLeft:
            _editConfig.imageRotationDirection = JFResizerRotationDirectionDown;
            break;
        case JFResizerRotationDirectionDown:
            _editConfig.imageRotationDirection = JFResizerRotationDirectionRight;
            break;
        case JFResizerRotationDirectionRight:
            _editConfig.imageRotationDirection = JFResizerRotationDirectionUp;
            break;
        default:
            break;
    }
    [self.mainView imageMainViewRotate];
    
}
/**
 剪裁按钮点击
 */
-(void)editClipButtonClick{
    [self.mainView imageMainViewOpenClip];
    self.editConfig.isEditClip = YES;
    [self changeButtonState];
}
/**
 下载保存到相册
 */
-(void)editDownloadButtonClick{
    NSLog(@"保存到相册");
}

/**
 剪辑取消按钮点击
 */
-(void)clipCancelButtonClick{
    self.editConfig.isEditClip = NO;
    [self changeButtonState];
    [self.mainView imageMainViewCancelClip];
}
/**
 剪辑完成按钮点击
 */
-(void)clipFinishButtonClick{
    self.editConfig.isEditClip = NO;
    [self changeButtonState];
    [self.mainView imageMainViewAccomplishClip];
}
/**
 剪辑重置按钮点击
 */
-(void)clipResetButtonClick{
    [self.mainView imageMainViewResetClip];
}

-(void)changeButtonState{
    if (self.editConfig.isEditClip) {
        self.editRotateBtn.hidden = YES;
        self.editCancelBtn.hidden = YES;
        self.editFinishBtn.hidden = YES;
        self.editResetBtn.hidden = YES;
        self.editClipBtn.hidden = YES;
        self.editDownloadBtn.hidden = YES;
        
        
        self.clipCancelBtn.hidden = NO;
        self.clipFinishBtn.hidden = NO;
        self.clipResetBtn.hidden = NO;
    }else{
        self.editRotateBtn.hidden = NO;
        self.editCancelBtn.hidden = NO;
        self.editFinishBtn.hidden = NO;
        self.editResetBtn.hidden = NO;
        self.editClipBtn.hidden = NO;
        self.editDownloadBtn.hidden = NO;
        
        
        self.clipCancelBtn.hidden = YES;
        self.clipFinishBtn.hidden = YES;
        self.clipResetBtn.hidden = YES;
    }
}


#pragma mark - getter
-(JFImageEditConfig *)editConfig{
    if (!_editConfig) {
        _editConfig = [JFImageEditConfig share];
        [_editConfig constantConfig];
    }
    return _editConfig;
}
-(JFImageMainView *)mainView{
    if (!_mainView) {
        _mainView = [[JFImageMainView alloc] initWithFrame:CGRectMake(0, kBUTTONVIEWHEIGHT, self.bounds.size.width, kMAINVIEWHEIGHT)  editConfig:self.editConfig];
        _mainView.backgroundColor = [UIColor blackColor];
        [self addSubview:_mainView];
    }
    return _mainView;
}

-(UIView *)topButtonView{
    if (!_topButtonView) {
        _topButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kBUTTONVIEWHEIGHT)];
        _topButtonView.backgroundColor = [UIColor clearColor];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = _topButtonView.frame;
        [_topButtonView.layer addSublayer:shapeLayer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.bounds.size.width, kBUTTONVIEWHEIGHT)];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = kMENGBANCOLOR.CGColor;
        
        [self addSubview:_topButtonView];
    }
    return _topButtonView;
}
-(UIView *)bottomButtonView{
    if (!_bottomButtonView) {
        _bottomButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-kBUTTONVIEWHEIGHT, self.bounds.size.width, kBUTTONVIEWHEIGHT)];
        _bottomButtonView.backgroundColor = [UIColor clearColor];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake(0, 0, self.bounds.size.width, kBUTTONVIEWHEIGHT);
        [_bottomButtonView.layer addSublayer:shapeLayer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.bounds.size.width, kBUTTONVIEWHEIGHT)];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = kMENGBANCOLOR.CGColor;
        
        [self addSubview:_bottomButtonView];
    }
    return _bottomButtonView;
}
//editorView页面按钮
-(UIButton *)editFinishBtn{
    if (!_editFinishBtn) {
        _editFinishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editFinishBtn.frame = CGRectMake(self.bounds.size.width-50, 25, kBUTTONHEIGHT, kBUTTONHEIGHT);
        [_editFinishBtn addTarget:self action:@selector(eidtFinishBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_editFinishBtn setBackgroundImage:[UIImage imageNamed:@"确定"] forState:UIControlStateNormal];
        [self.topButtonView addSubview:_editFinishBtn];
    }
    return _editFinishBtn;
}
-(UIButton *)editCancelBtn{
    if (!_editCancelBtn) {
        _editCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_editCancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_editCancelBtn addTarget:self action:@selector(editCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editCancelBtn.frame = CGRectMake(20, 25, kBUTTONHEIGHT, kBUTTONHEIGHT);
        [_editCancelBtn setBackgroundImage:[UIImage imageNamed:@"取消"] forState:UIControlStateNormal];
        [self.topButtonView addSubview:_editCancelBtn];
    }
    return _editCancelBtn;
}
-(UIButton *)editResetBtn{
    if (!_editResetBtn) {
        _editResetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editResetBtn setBackgroundColor:[UIColor whiteColor]];
        [_editResetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_editResetBtn addTarget:self action:@selector(editResetButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editResetBtn.frame = CGRectMake((self.bounds.size.width/4-kBUTTONHEIGHT)/2, 0, kBUTTONHEIGHT, kBUTTONHEIGHT);
        [_editResetBtn setBackgroundImage:[UIImage imageNamed:@"重置"] forState:UIControlStateNormal];
        [self.bottomButtonView addSubview:_editResetBtn];
    }
    return _editResetBtn;
}
-(UIButton *)editRotateBtn{
    if (!_editRotateBtn) {
        _editRotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editRotateBtn setBackgroundColor:[UIColor whiteColor]];
        [_editRotateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_editRotateBtn addTarget:self action:@selector(editRotateButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editRotateBtn.frame = CGRectMake(self.bounds.size.width/4+(self.bounds.size.width/4-kBUTTONHEIGHT)/2, 0, kBUTTONHEIGHT, kBUTTONHEIGHT);
        [_editRotateBtn setBackgroundImage:[UIImage imageNamed:@"旋转"] forState:UIControlStateNormal];
        [self.bottomButtonView addSubview:_editRotateBtn];
    }
    return _editRotateBtn;
}

-(UIButton *)editClipBtn{
    if (!_editClipBtn) {
        _editClipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editClipBtn setBackgroundColor:[UIColor whiteColor]];
        
        [_editClipBtn addTarget:self action:@selector(editClipButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editClipBtn.frame = CGRectMake(self.bounds.size.width/4*2+(self.bounds.size.width/4-kBUTTONHEIGHT)/2, 0, kBUTTONHEIGHT, kBUTTONHEIGHT);
        [_editClipBtn setBackgroundImage:[UIImage imageNamed:@"剪裁"] forState:UIControlStateNormal];
        [self.bottomButtonView addSubview:_editClipBtn];
    }
    return _editClipBtn;
}
-(UIButton *)editDownloadBtn{
    if (!_editDownloadBtn) {
        _editDownloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editDownloadBtn setBackgroundColor:[UIColor whiteColor]];
        [_editDownloadBtn addTarget:self action:@selector(editDownloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _editDownloadBtn.frame = CGRectMake(self.bounds.size.width/4*3+(self.bounds.size.width/4-kBUTTONHEIGHT)/2, 0, kBUTTONHEIGHT, kBUTTONHEIGHT);
        [_editDownloadBtn setBackgroundImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
        [self.bottomButtonView addSubview:_editDownloadBtn];
    }
    return _editDownloadBtn;
}

//剪裁页面按钮
-(UIButton *)clipCancelBtn{
    if (!_clipCancelBtn) {
        _clipCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_clipCancelBtn setBackgroundColor:[UIColor whiteColor]];
        [_clipCancelBtn addTarget:self action:@selector(clipCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _clipCancelBtn.frame = CGRectMake(20, 20, 80, kBUTTONHEIGHT);
        //        [_clipCancelBtn setBackgroundImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
        [_clipCancelBtn setTitle:@"取消编辑" forState:UIControlStateNormal];
        [self.topButtonView addSubview:_clipCancelBtn];
    }
    return _clipCancelBtn;
}
-(UIButton *)clipFinishBtn{
    if (!_clipFinishBtn) {
        _clipFinishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_clipCancelBtn setBackgroundColor:[UIColor whiteColor]];
        [_clipFinishBtn addTarget:self action:@selector(clipFinishButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _clipFinishBtn.frame = CGRectMake(self.bounds.size.width-80, 20, 80, kBUTTONHEIGHT);
        //        [_clipCancelBtn setBackgroundImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
        [_clipFinishBtn setTitle:@"完成编辑" forState:UIControlStateNormal];
        [self.topButtonView addSubview:_clipFinishBtn];
    }
    return _clipFinishBtn;
}
-(UIButton *)clipResetBtn{
    if (!_clipResetBtn) {
        _clipResetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_clipCancelBtn setBackgroundColor:[UIColor whiteColor]];
        [_clipResetBtn addTarget:self action:@selector(clipResetButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _clipResetBtn.frame = CGRectMake(self.bounds.size.width-80, 20, 80, kBUTTONHEIGHT);
        //        [_clipCancelBtn setBackgroundImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
        [_clipResetBtn setTitle:@"重置按钮" forState:UIControlStateNormal];
        [self.bottomButtonView addSubview:_clipResetBtn];
    }
    return _clipResetBtn;
}
@end
