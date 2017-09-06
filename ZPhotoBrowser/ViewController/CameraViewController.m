//
//  CameraViewController.m
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/8/29.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImage.h"

#import "GPUImageBeautifyFilter.h"

#define kScreenBounds   [UIScreen mainScreen].bounds
#define WIDTH  kScreenBounds.size.width*1.0
#define HEIGHT kScreenBounds.size.height*1.0

@interface CameraViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) GPUImageStillCamera *camera;

@property (nonatomic, strong) GPUImageBeautifyFilter *filter;

@property (nonatomic, strong) GPUImageView *imageView;

@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) UIImageView *cameraIamgeView;

@property (nonatomic, strong) UIButton *roteCameraBtn;

@property (nonatomic, strong) UIButton *exitCameraBtn;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *chooseButton;

@end

@implementation CameraViewController
- (void)dealloc{
    NSLog(@"相机界面销毁");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.camera addTarget:self.filter];
    [self.filter addTarget:self.imageView];
    [self.view addSubview:self.imageView];
    [self.camera startCameraCapture];
    [self.view addSubview:self.cameraBtn];
    [self.view addSubview:self.roteCameraBtn];
    [self.view addSubview:self.exitCameraBtn];
}
#pragma mark - 拍照
-(void)cameraBtnAction:(UIButton *)button{
    self.cameraBtn.hidden = YES;
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (error) {
            return ;
        }
        //成功了
        [self successCutPic:processedImage];
    }];
}
- (void)successCutPic:(UIImage *)image{
    //停止相机捕捉对象
    [self.camera stopCameraCapture];
    self.cameraIamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    self.cameraIamgeView.image = image;
    [self.view insertSubview:self.cameraIamgeView aboveSubview:self.imageView];
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH / 2 - 37, HEIGHT - 80 - 37, 74, 74)];
    [self.cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.view addSubview:self.cancelButton];
    
    self.chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH / 2 - 37, HEIGHT - 80 - 37, 74, 74)];
    [self.chooseButton setImage:[UIImage imageNamed:@"white_circle"] forState:UIControlStateNormal];
    [self.view addSubview:self.chooseButton];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.cancelButton.frame = CGRectMake(WIDTH / 4 - 37, HEIGHT - 80 - 37, 74, 74);
        self.chooseButton.frame = CGRectMake(WIDTH / 4 * 3 - 37, HEIGHT - 80 - 37, 74, 74);
    } completion:^(BOOL finished) {
        [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.chooseButton addTarget:self action:@selector(chooseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }];
}
- (void)cancelButtonClicked:(UIButton *)sender {
    
    [UIView animateWithDuration:0.15 animations:^{
        self.chooseButton.frame = CGRectMake((WIDTH-60)/2, HEIGHT-80, 60, 60);
        self.cancelButton.frame = CGRectMake((WIDTH-60)/2, HEIGHT-80, 60, 60);
    } completion:^(BOOL finished) {
        [self.chooseButton removeFromSuperview];
        [self.cancelButton removeFromSuperview];
        self.cameraBtn.hidden = NO;
        [self.cameraIamgeView removeFromSuperview];
        [self.camera startCameraCapture];
    }];
}
- (void)chooseButtonClicked:(UIButton *)sender {
    [UIView animateWithDuration:0.15 animations:^{
        self.cancelButton.frame = CGRectMake((WIDTH-60)/2, HEIGHT-80, 60, 60);
        self.chooseButton.frame = CGRectMake((WIDTH-60)/2, HEIGHT-80, 60, 60);
    } completion:^(BOOL finished) {
        [self.cancelButton removeFromSuperview];
        [self.chooseButton removeFromSuperview];
        self.cameraBtn.hidden = NO;
        UIImageWriteToSavedPhotosAlbum(self.cameraIamgeView.image, nil, nil, nil);
        [self.cameraIamgeView removeFromSuperview];
        [self.camera startCameraCapture];
    }];
}
#pragma mark - 切换摄像头
-(void)roteCameraBtnAction:(UIButton *)button{
    [self.camera rotateCamera];
}
#pragma mark - 退出相机
-(void)exitCameraBtnAction:(UIButton *)button{
    [self.camera stopCameraCapture];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Lazy Load
//AVCaptureDevicePositionBack为后摄像头 front为前置摄像头
//AVCaptureSessionPreset1920x1080为分辨率 另外还支持多种分辨率
//AVCaptureSessionPreset1280x720 等等等等
- (GPUImageStillCamera *)camera{
    if (!_camera) {
        _camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        //设置前置摄像头镜像问题
        _camera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _camera;
}
//滤镜
- (GPUImageBeautifyFilter *)filter{
    if (!_filter) {
        _filter = [[GPUImageBeautifyFilter alloc]init];
    }
    return _filter;
}
- (GPUImageView *)imageView{
    if (!_imageView) {
        _imageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        //显示模式
        _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    }
    return _imageView;
}
//拍照按钮
- (UIButton *)cameraBtn{
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
        _cameraBtn.frame = CGRectMake((WIDTH-60)/2, HEIGHT-80, 60, 60);
        [_cameraBtn addTarget:self action:@selector(cameraBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn;
}
//旋转摄像头
- (UIButton *)roteCameraBtn{
    if (!_roteCameraBtn) {
        _roteCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_roteCameraBtn setImage:[UIImage imageNamed:@"change_direction"] forState:UIControlStateNormal];
        [_roteCameraBtn addTarget:self action:@selector(roteCameraBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _roteCameraBtn.frame = CGRectMake(WIDTH - 20 - 27, 20, 27, 22);
    }
    return _roteCameraBtn;
}
//退出相机
- (UIButton *)exitCameraBtn{
    if (!_exitCameraBtn) {
        _exitCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH / 4 * 3 - 12, HEIGHT - 60, 25, 14)];
        [_exitCameraBtn setBackgroundImage:[UIImage imageNamed:@"pull_down"] forState:UIControlStateNormal];
        [_exitCameraBtn addTarget:self action:@selector(exitCameraBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitCameraBtn;
}
@end
