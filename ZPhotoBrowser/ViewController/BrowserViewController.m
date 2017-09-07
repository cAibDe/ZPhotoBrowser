//
//  BrowserViewController.m
//  ZPhotoBrowser
//
//  Created by 张鹏 on 2017/9/7.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

#import "BrowserViewController.h"
#import "PhotoVIew.h"
#import <Photos/Photos.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface BrowserViewController ()<PhotoViewDelegate,UIScrollViewDelegate>{
    //scrollView 所有子视图
    NSMutableArray *_subViewArray;
}
/** 背景容器视图 */
@property(nonatomic,strong) UIScrollView *scrollView;

/** 外部操作控制器 */
@property (nonatomic,weak) UIViewController *handleVC;

/** 图片浏览方式 */
@property (nonatomic,assign) BrowserShowType type;

/** 图片数组 */
@property (nonatomic,strong) NSArray *imagesArray;

/** 初始显示的index */
@property (nonatomic,assign) NSUInteger index;

/** 圆点指示器 */
@property(nonatomic,strong) UIPageControl *pageControl;

/** 记录当前的图片显示视图 */
@property(nonatomic,strong) PhotoVIew *photoView;
@end

@implementation BrowserViewController

-(void)dealloc{
    NSLog(@"图片浏览器界面销毁");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _subViewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //去除自动处理
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(WIDTH * self.imagesArray.count, 0);
    for (int i = 0; i<self.imagesArray.count; i++) {
        [_subViewArray addObject:[NSNull class]];
    }
    self.scrollView.contentOffset = CGPointMake(WIDTH*self.index, 0);//此句代码需放在[_subViewArray addObject:[NSNull class]]之后，因为其主动调用scrollView的代理方法，否则会出现数组越界
    
    if (self.imagesArray.count == 1) {
        _pageControl.hidden = YES;
    }else{
        self.pageControl.currentPage = self.index;
    }
    [self showPhoto:self.index];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCurrentVC:)];
    [self.view addGestureRecognizer:tap];//为当前view添加手势，隐藏当前显示窗口
}
-(void)hideCurrentVC:(UIGestureRecognizer *)tap{
    [self hideScanImageVC];
}
-(void)hideScanImageVC{
    
    switch (_type) {
        case BrowserShowTypePush://push
            
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
        case BrowserShowTypeModal://modal
            
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
            
        case BrowserShowTypeZoom://zoom
            
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
            break;
            
        default:
            break;
    }
}
+(void)show:(UIViewController *)handelVC type:(BrowserShowType)type index:(NSUInteger)index imagesBlock:(NSArray *(^)())imagesBlock{
    NSArray *photoModels = imagesBlock();//取出相册数组
    
    if (photoModels == nil || photoModels.count == 0) {
        return;
    }
    BrowserViewController *browserVC = [[self alloc]init];
    if (index >= photoModels.count) {
        return;
    }
    
    browserVC.index = index;
    browserVC.imagesArray = photoModels;
    browserVC.type = type;
    browserVC.handleVC = handelVC;
    [browserVC show];
    
}
/** 真正展示 */
-(void)show{
    
    switch (_type) {
        case BrowserShowTypePush://push
            
            [self pushPhotoVC];
            
            break;
        case BrowserShowTypeModal://modal
            
            [self modalPhotoVC];
            
            break;
            
        case BrowserShowTypeZoom://zoom
            
            [self zoomPhotoVC];
            
            break;
            
        default:
            break;
    }
}
/** push */
-(void)pushPhotoVC{
    
    [_handleVC.navigationController pushViewController:self animated:YES];
}


/** modal */
-(void)modalPhotoVC{
    
    [_handleVC presentViewController:self animated:YES completion:nil];
}

/** zoom */
-(void)zoomPhotoVC{
    
    //拿到window
    UIWindow *window = _handleVC.view.window;
    
    if(window == nil){
        NSLog(@"错误：窗口为空！");
        return;
    }
    
    self.view.frame=[UIScreen mainScreen].bounds;
    
    [window addSubview:self.view]; //添加视图
    
    [_handleVC addChildViewController:self]; //添加子控制器
}
#pragma mark - 显示图片
- (void)showPhoto:(NSInteger)index{
    if (index<0 || index >= self.imagesArray.count) {
        return;
    }
    id currentPhotoView = [_subViewArray objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[PhotoVIew class]]) {
        //url或图片Array
        CGRect frame = CGRectMake(index * _scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        if ([[self.imagesArray firstObject]isKindOfClass:[UIImage class]]) {
            PhotoVIew *photoV = [[PhotoVIew alloc]initWithFrame:frame withPhotoImage:[self.imagesArray objectAtIndex:index]];
            photoV.delegate = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView = photoV;
        }else if ([[self.imagesArray firstObject]isKindOfClass:[NSString class]]){            PhotoVIew *photoV = [[PhotoVIew alloc] initWithFrame:frame withPhotoUrl:[self.imagesArray objectAtIndex:index]];
            photoV.delegate = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView=photoV;
        }else if ([[self.imagesArray firstObject] isKindOfClass:[PHAsset class]]){
            PhotoVIew *photoV = [[PhotoVIew alloc]initWithFrame:frame withPHAsset:[self.imagesArray objectAtIndex:index]];
            photoV.delegate = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView=photoV;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 懒加载
-(UIScrollView *)scrollView{
    
    if (_scrollView==nil) {
        _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        _scrollView.delegate=self;
        _scrollView.pagingEnabled=YES;
        _scrollView.contentOffset=CGPointZero;
        //设置最大伸缩比例
        _scrollView.maximumZoomScale=3;
        //设置最小伸缩比例
        _scrollView.minimumZoomScale=1;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIPageControl *)pageControl{
    if (_pageControl==nil) {
        UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-40, WIDTH, 30)];
        bottomView.backgroundColor=[UIColor clearColor];
        _pageControl = [[UIPageControl alloc] initWithFrame:bottomView.bounds];
        _pageControl.currentPage = self.index;
        _pageControl.numberOfPages = self.imagesArray.count;
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:153 green:153 blue:153 alpha:1];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:235 green:235 blue:235 alpha:0.6];
        [bottomView addSubview:_pageControl];
        [self.view addSubview:bottomView];
    }
    return _pageControl;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page<0||page>=self.imagesArray.count) {
        return;
    }
    self.pageControl.currentPage = page;
    
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[PhotoVIew class]]) {
            PhotoVIew *photoV=(PhotoVIew *)[_subViewArray objectAtIndex:page];
            if (photoV!=self.photoView) {
                [self.photoView.scrollView setZoomScale:1.0 animated:YES];
                self.photoView=photoV;
            }
        }
    }
    
    [self showPhoto:page];
}
#pragma mark - PhotoViewDelegate
-(void)tapHiddenPhotoView{
    [self hideScanImageVC];//隐藏当前显示窗口
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
