//
//  ViewController.m
//  图片编辑器
//
//  Created by 168licai on 2018/4/3.
//  Copyright © 2018年 168licai. All rights reserved.
//

#import "ViewController.h"
#import "JFImageEditorView.h"
@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,strong)UIImageView *imageView;

@property(nonatomic,strong)JFImageEditorView *editView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self imageView];
    [self editView];
    
}

-(JFImageEditorView *)editView{
    if (!_editView) {
        _editView = [[JFImageEditorView alloc]initWithFrame:self.view.bounds image:[UIImage imageNamed:@"蒙娜丽莎"]];
        [self.view addSubview:_editView];
    }
    return _editView;
}



-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width-100, self.view.frame.size.width-100)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

- (IBAction)buttonClick:(id)sender {
    UIImagePickerController *cl = [[UIImagePickerController alloc] init];
    cl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cl.delegate = self;
    [self presentViewController:cl animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    self.imageView.image = image;
    [self editView];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
