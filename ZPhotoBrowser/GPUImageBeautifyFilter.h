//
//  GPUImageBeautifyFilter.h
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/8/29.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "GPUImage.h"

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@end
