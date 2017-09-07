//
//  PhotoVIew.h
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/9/7.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
@protocol PhotoViewDelegate <NSObject>

- (void)tapHiddenPhotoView;

@end

@interface PhotoVIew : UIView
//父视图
@property (nonatomic, strong) UIScrollView *scrollView;
//图片视图
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) id<PhotoViewDelegate> delegate;

@property (nonatomic, strong) PHLivePhoto *livePhoto;

@property (nonatomic, assign) BOOL muted;

@property (nonatomic, strong) UIGestureRecognizer *playbackGestureRecognizer;

@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
/**
 *  传图片Url
 */
-(id)initWithFrame:(CGRect)frame withPhotoUrl:(NSString *)photoUrl;

/**
 *  传具体图片
 */
-(id)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image;

/**
 *  本地媒体库图片
 */
-(id)initWithFrame:(CGRect)frame withPHAsset:(PHAsset *)asset;
@end
