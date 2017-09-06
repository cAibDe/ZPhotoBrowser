//
//  PhotoCollectionViewCell.h
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/6/22.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface PhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;

-(void)updatePhotoCellWith:(PHAsset *)asset;
@end
