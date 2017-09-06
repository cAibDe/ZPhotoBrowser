//
//  CameraCollectionViewCell.m
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/6/22.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "CameraCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
@interface CameraCollectionViewCell ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureSession *_captureSession;
    UIImageView *_outputImageView;
}
@end
@implementation CameraCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        ;
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    AVCaptureDeviceInput *capTureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
    AVCaptureVideoDataOutput *capTureOutPut = [[AVCaptureVideoDataOutput alloc]init];
    capTureOutPut.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [capTureOutPut setSampleBufferDelegate:self queue:queue];
    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSetting = [NSDictionary dictionaryWithObject:value forKey:key];
    [capTureOutPut setVideoSettings:videoSetting];
    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession addInput:capTureInput];
    [_captureSession addOutput:capTureOutPut];
    [_captureSession startRunning];
    _outputImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width , self.bounds.size.height)];
    _outputImageView.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:_outputImageView];
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,width, height, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(newImage);
    [_outputImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}
@end
