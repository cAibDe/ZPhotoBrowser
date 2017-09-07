//
//  BrowserViewController.h
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/9/7.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger ,BrowserShowType) {
    
    BrowserShowTypePush = 0,
    
    BrowserShowTypeModal,
    
    BrowserShowTypeZoom,
};

@interface BrowserViewController : BaseViewController

+ (void)show:(UIViewController *)handelVC type:(BrowserShowType)type index:(NSUInteger)index imagesBlock:(NSArray *(^)())imagesBlock;
@end
