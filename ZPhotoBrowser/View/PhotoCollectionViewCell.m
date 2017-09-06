//
//  PhotoCollectionViewCell.m
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/6/22.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#define WeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface PhotoCollectionViewCell()
@property (strong, nonatomic) PHCachingImageManager *imageManager;
@end
@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        ;
    }
    return self;
}- (void)layoutSubviews{
    [super layoutSubviews];
    [self.contentView addSubview:self.imageView];
}
- (void)updatePhotoCellWith:(PHAsset *)asset{
    WeakSelf(weakSelf);
    [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(self.bounds.size.width, self.bounds.size.width) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.imageView.image = result;
    }];
}
#pragma mark - Lazy Load
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
    }
    return _imageView;
}
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}
@end
