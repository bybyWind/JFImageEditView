//
//  JFImageEditorView.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/3.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "JFImageEditorView.h"
#import "JFImageMainView.h"

//编辑器的编辑部分的高度
#define kMAINVIEWHEIGHT (self.bounds.size.height-kBUTTONVIEWHEIGHT*2)
#define kBUTTONVIEWHEIGHT (50)


@interface JFImageEditorView(){
    UIImage *_originImage;//用来保存原始图片
   
}


@property(nonatomic,strong)JFImageMainView *mainView;//主视图
@property(nonatomic,strong)UIView *topButtonView;//顶部按钮
@property(nonatomic,strong)UIView *bottomButtonView;//底部按钮

@end

@implementation JFImageEditorView


- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image{
    
    if (self = [super initWithFrame:frame]) {
       
        _originImage = image;
        [self mainView];
        [self topButtonView];
        [self bottomButtonView];
    
     
    }
    
    return self;
    
}

#pragma mark - event

#pragma mark - getter

-(JFImageMainView *)mainView{
    if (!_mainView) {
        _mainView = [[JFImageMainView alloc] initWithFrame:CGRectMake(0, kBUTTONVIEWHEIGHT, self.bounds.size.width, kMAINVIEWHEIGHT) image:_originImage];
        _mainView.backgroundColor = [UIColor blackColor];
        [self addSubview:_mainView];
    }
    return _mainView;
}

-(UIView *)topButtonView{
    if (!_topButtonView) {
        _topButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kBUTTONVIEWHEIGHT)];
        _topButtonView.backgroundColor = [UIColor blackColor];
          [self addSubview:_topButtonView];
    }
    return _topButtonView;
}
-(UIView *)bottomButtonView{
    if (!_bottomButtonView) {
        _bottomButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-kBUTTONVIEWHEIGHT, self.bounds.size.width, kBUTTONVIEWHEIGHT)];
        _bottomButtonView.backgroundColor = [UIColor blackColor];
        [self addSubview:_bottomButtonView];
    }
    return _bottomButtonView;
}
@end
