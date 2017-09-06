//
//  BaseViewController.m
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/6/22.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "BaseViewController.h"

#import "CameraViewController.h"
#import "UIViewController+NavigationBar.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
//特定的页面隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    if ([self isKindOfClass:[CameraViewController class]]) {
        return YES;
    }else{
        return NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLeftNavigationBarToBack];
    self.view.backgroundColor = [UIColor whiteColor];

    //防止push 之后 pop回来 位置变化
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
