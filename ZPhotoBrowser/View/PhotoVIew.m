//
//  PhotoVIew.m
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/9/7.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "PhotoVIew.h"
#import "MBProgressHUD.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#define WeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self
@interface PhotoVIew ()<UIScrollViewDelegate>{
    MBProgressHUD *HUD;
}

@end

@implementation PhotoVIew
- (id)initWithFrame:(CGRect)frame withPhotoUrl:(NSString *)photoUrl{
    self = [super initWithFrame:frame];
    if (self) {
        //添加图片
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        BOOL isCached = [manager cachedImageExistsForURL:[NSURL URLWithString:photoUrl]];
        if (!isCached) {
            //没有缓存
            HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
            HUD.mode = MBProgressHUDModeDeterminate;
            
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                HUD.progress = ((float)receivedSize)/expectedSize;
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.imageView.frame = [self caculateOriginImageSizeWith:image];
                NSLog(@"图片加载完成");
                if (!isCached) {
                    [HUD hide:YES];
                }
            }];
        }else{
            //直接取出缓存图片减少流量消耗
            UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photoUrl];
            self.imageView.frame = [self caculateOriginImageSizeWith:cachedImage];
            self.imageView.image = cachedImage;
        }
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image{
    self = [super initWithFrame:frame];
    if (self) {
        //添加图片
        self.imageView.frame=[self caculateOriginImageSizeWith:image];
        [self.imageView setImage:image];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withPHAsset:(PHAsset *)asset{
    self = [super initWithFrame:frame];
    if (self) {
        WeakSelf(weakSelf);
        if (asset.mediaType == PHAssetMediaTypeImage) {
            if (asset.mediaSubtypes >= PHAssetMediaSubtypePhotoLive) {
                //LivePhoto
                PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc]init];
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.networkAccessAllowed = YES;
                options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                };
                [[PHImageManager defaultManager]requestLivePhotoForAsset:asset targetSize:self.livePhotoView.bounds.size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                    weakSelf.livePhotoView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
                    weakSelf.livePhotoView.livePhoto = livePhoto;
                }];
            }else{
                [[PHImageManager defaultManager]
                 requestImageDataForAsset:asset
                 options:nil
                 resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                     UIImage *selectedImage = [UIImage imageWithData:imageData];
                     weakSelf.imageView.image = selectedImage;
                     weakSelf.imageView.frame=[self caculateOriginImageSizeWith:selectedImage];
                     //                                                       weakSelf.title = [[info objectForKey:@"PHImageFileURLKey"] lastPathComponent];
                 }];
            }
        }
    }
    return self;
}
#pragma maek - 计算图片原始高度 用于高度自适应
- (CGRect)caculateOriginImageSizeWith:(UIImage *)image{
    CGFloat originImageHeight = [self imageCompressForWidth:image targetWidth:[UIScreen mainScreen].bounds.size.width].size.height;
    if (originImageHeight >= [UIScreen mainScreen].bounds.size.height) {
        originImageHeight = [UIScreen mainScreen].bounds.size.height;
    }
    CGRect frame = CGRectMake(0, (UIScreen.mainScreen.bounds.size.height - originImageHeight) *0.5,UIScreen.mainScreen.bounds.size.width , originImageHeight);
    return frame;
    
}
- (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height/(width/targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, size) == NO) {
        CGFloat widthFactor = targetWidth/width;
        CGFloat heightFactor = targetHeight/height;
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if (widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbNailRect = CGRectZero;
    thumbNailRect.origin = thumbnailPoint;
    thumbNailRect.size.width = scaledWidth;
    thumbNailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbNailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
#pragma mark - 懒加载
-(UIScrollView *)scrollView{
    if (_scrollView==nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [_scrollView setZoomScale:1];
        
        //添加scrollView
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIImageView *)imageView{
    
    if (_imageView==nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled=YES;
        
        //添加手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;//需要点两下
        twoFingerTap.numberOfTouchesRequired = 2;//需要两个手指touch
        
        [_imageView addGestureRecognizer:singleTap];
        [_imageView addGestureRecognizer:doubleTap];
        [_imageView addGestureRecognizer:twoFingerTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击了，则不响应单击事件
        
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}
- (PHLivePhotoView *)livePhotoView{
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc]init];
        [_livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_livePhotoView];
    }
    return _livePhotoView;
}
#pragma mark - 图片的点击，touch事件
//单击
-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        [self.delegate tapHiddenPhotoView];
    }
}

//双击
-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(_scrollView.zoomScale == 1){
            float newScale = [_scrollView zoomScale] *2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }else{
            float newScale = [_scrollView zoomScale]/2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

//2手指操作
-(void)handleTwoFingerTap:(UITapGestureRecognizer *)gestureRecongnizer{
    float newScale = [_scrollView zoomScale]/2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecongnizer locationInView:gestureRecongnizer.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
}
#pragma mark - 缩放大小获取方法
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    //大小
    zoomRect.size.height = [_scrollView frame].size.height/scale;
    zoomRect.size.width = [_scrollView frame].size.width/scale;
    //原点
    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;
    return zoomRect;
}
#pragma mark - UIScrollViewDelegate
/**scroll view处理缩放和平移手势，必须需要实现委托下面两个方法,另外 maximumZoomScale和minimumZoomScale两个属性要不一样*/

//1.返回要缩放的图片
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

//让图片保持在屏幕中央，防止图片放大时，位置出现跑偏
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?(_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?
    (_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX,_scrollView.contentSize.height * 0.5 + offsetY);
}

//2.重新确定缩放完后的缩放倍数
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

@end
