//
//  MainViewController.m
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/6/22.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "MainViewController.h"
#import "CameraViewController.h"

#import <Photos/Photos.h>

#import "CameraCollectionViewCell.h"
#import "PhotoCollectionViewCell.h"

#import "YCXMenu.h"
#import "Masonry.h"

#define WeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self
@interface MainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) PHFetchOptions *options;

@property (strong, nonatomic) NSMutableArray *smartFetchResultArray;

@property (strong, nonatomic) NSMutableArray *smartFetchResultTitlt;

@property (strong, nonatomic) PHCachingImageManager *imageManager;

@property (strong, nonatomic) PHFetchResult *localAllMediAassetFetchResult;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic , strong) NSMutableArray *items;

@end
@implementation MainViewController
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getAlbumAuthorized];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatCollectionView];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)creatCollectionView{
    UICollectionViewFlowLayout *flowLayOut = [[UICollectionViewFlowLayout alloc]init];
    flowLayOut.minimumLineSpacing = 10;
    flowLayOut.minimumInteritemSpacing = 10;
    
    flowLayOut.itemSize = CGSizeMake((self.view.bounds.size.width -20)/3, (self.view.bounds.size.width -20)/3);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) collectionViewLayout:flowLayOut];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //注册单元格
    [self.collectionView registerClass:[CameraCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CameraCollectionViewCell class])];
    [self.collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([PhotoCollectionViewCell class])];
}
#pragma mark - colectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.localAllMediAassetFetchResult.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        CameraCollectionViewCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CameraCollectionViewCell class]) forIndexPath:indexPath];
        return cameraCell;
    }else{
        PhotoCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCollectionViewCell class]) forIndexPath:indexPath];
        PHAsset *asset =self.localAllMediAassetFetchResult[indexPath.item - 1];
        [photoCell updatePhotoCellWith:asset];
        return photoCell;
    }

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.item == 0) {
        //这里是弹出相机界面
        CameraViewController *cameraVC = [[CameraViewController alloc]init];
        [self presentViewController:cameraVC animated:YES completion:nil];
    }else{
        //进入相册浏览
        
    }
}
#pragma mark - 处理相册授权
- (void)getAlbumAuthorized{
    //判断是否有访问权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    //还没有去做选择
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            //已经授权
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //利用PhotoKit 获取所有的相册
                    [self getAllAlbums];
                });
            }else{
                //做一个没有授权的提示
                
            }
        }];
    }
    //已经授权
    else if (status == PHAuthorizationStatusAuthorized){
        dispatch_async(dispatch_get_main_queue(), ^{
            //利用PhotoKit 获取所有的相册
            [self getAllAlbums];
        });
    }
    //拒绝访问
    else if (status == PHAuthorizationStatusRestricted){
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }
}
#pragma mark - 利用PhotoKit 获取所有的相册
- (void)getAllAlbums{
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHCollection *collection in smartAlbums) {
        if ([collection isKindOfClass:[PHCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            switch (assetCollection.assetCollectionSubtype) {
                case PHAssetCollectionSubtypeSmartAlbumAllHidden:
                    break;
                case PHAssetCollectionSubtypeSmartAlbumUserLibrary:{
                    PHFetchResult *assetFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.options];
                    [self.smartFetchResultArray insertObject:assetFetchResult atIndex:0];
                    [self.smartFetchResultTitlt insertObject:collection.localizedTitle atIndex:0];
                }
                    break;
                default:{
                    PHFetchResult *assetFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.options];
                    [self.smartFetchResultTitlt addObject:collection.localizedTitle];
                    [self.smartFetchResultArray addObject:assetFetchResult];
                }
                    break;
            }
        }
    }
    self.localAllMediAassetFetchResult = [self.smartFetchResultArray firstObject];
    [self setUpTitleView];
    [self.collectionView reloadData];
}
#pragma mark - Title View
- (void)setUpTitleView{
    UIView *titleView = [[UIView alloc]initWithFrame:self.navigationController.navigationBar.bounds];
    titleView.userInteractionEnabled = YES;
    
    UIImageView *icon= [UIImageView new];
    [icon setImage:[UIImage imageNamed:@"date_icon"]];
    [icon sizeToFit];
    
    UIView * contentView = [[UIView alloc] init];
    
    [titleView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(titleView);
        
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.text = self.smartFetchResultTitlt.firstObject;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = [UIColor blackColor];
    
    [contentView addSubview:self.titleLabel];
    [contentView addSubview:icon];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView);
        make.centerY.equalTo(contentView);
        make.right.equalTo(icon.mas_left);
    }];
    
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView);
        make.top.equalTo(contentView);
        make.bottom.equalTo(contentView);
        make.left.equalTo(self.titleLabel.mas_right);
        
    }];
    UITapGestureRecognizer *tittlViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tittlViewMethod)];
    [titleView addGestureRecognizer:tittlViewTap];
    self.navigationItem.titleView =titleView;
}
- (void)tittlViewMethod{
    WeakSelf(weakSelf);
    [YCXMenu setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    [YCXMenu setSelectedColor:[UIColor redColor]];
    if ([YCXMenu isShow]){
        [YCXMenu dismissMenu];
    } else {
        [YCXMenu showMenuInView:self.view fromRect:CGRectMake((self.view.frame.size.width - 50)/2, 64, 50, 0) menuItems:self.items selected:^(NSInteger index, YCXMenuItem *item) {
            weakSelf.titleLabel.text = weakSelf.smartFetchResultTitlt[index];
            weakSelf.localAllMediAassetFetchResult = weakSelf.smartFetchResultArray[index];
            [weakSelf.collectionView reloadData];
        }];
    }
}
#pragma mark - setter/getter
- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
        for (int i = 0; i<self.smartFetchResultTitlt.count; i++) {
           YCXMenuItem *item = [YCXMenuItem menuItem:self.smartFetchResultTitlt[i]
                            image:nil
                              tag:i
                         userInfo:nil];
            [_items addObject:item];
        }
    }
    return _items;
}
#pragma mark - Lazy Load
- (PHFetchOptions *)options {
    if (!_options) {
        _options = [[PHFetchOptions alloc] init];
        _options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
    }
    return _options;
}
- (NSMutableArray *)smartFetchResultArray {
    if (!_smartFetchResultArray) {
        _smartFetchResultArray = [[NSMutableArray alloc] init];
    }
    return _smartFetchResultArray;
}
- (NSMutableArray *)smartFetchResultTitlt {
    if (!_smartFetchResultTitlt) {
        _smartFetchResultTitlt = [[NSMutableArray alloc] init];
    }
    return _smartFetchResultTitlt;
}
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}
@end
