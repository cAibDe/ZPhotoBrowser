# ZPhotoBrowser
基于GPUImage
#前言
作为一个iOS开发人员，我已经不知不觉的在帝都这个地方上干了块两年了。前一阵，由于公司的发展方向的问题，我被迫加入了找工作的大军之中。这可把我担心坏了，因为我之前的一个同事找了好久都没有找到工作，之后他就选择回老家发展了。做过iOS这行的都知道现在是什么行情了，我就不多说了。不过还好我找了一周左右吧，面试不少。但是现在招人的公司，真的不知道要招什么样的开发人员，面试草草了事的偏多。还有就是自认为大牛的比较多，我记得我面了一家智能家居的科技公司。那个面试我的面试官，看了我做过的产品。就给我说了一句：“你就是个调接口和写TableView的啊。”这话听起来真的让人难受，用一句很流行的话说，那就是“扎心了，老铁”。我仔细一想，也确实。现在的App，基本都是这样的啊。基本都是项目需求是什么做什么。所以我觉得 我不能在这么下去了。
***
# GPUImage
上面说了，我打算自己做做新的功能。突然间，就对相机这个模块感兴趣了。毕竟现在是全民P图，全民美颜的时代。我还记得我小的时候看电视有这么一句台词“美不美，看大腿”。在现在应该是“美不美，看美颜”。
我就上网找了一下，偶然间发现了一个名为`GPUImage`的。好像是可以做到我想要的效果的，它内置了很多的滤镜效果，共125个滤镜, 分为四类
`Color adjustments: 31 filters, 颜色处理相关`
`Image processing: 40 filters, 图像处理相关.`
`Blending modes: 29 filters, 混合模式相关.`
`Visual effects: 25 filters, 视觉效果相关.`
这里我就不把滤镜的效果一一的列举出来了，有兴趣的可以去看[[gpuimage的各种滤镜简介](http://www.cnblogs.com/runner42/p/5672553.html)](https://github.com/cAibDe/PhotoKitDemo)或[GPUImage滤镜列表](http://www.jianshu.com/p/a90a388235a4) 后面这个是简书的文章，推荐！！
***
# GPUImage之相机
要实现相机的效果主要有如下几个变量：
`@property (nonatomic, strong) GPUImageStillCamera *camera;`
可以理解为设备
`@property (nonatomic, strong) GPUImageView *imageView;`
用于显示的View
其实主要的变量还有一个就是你的滤镜。
首先，我不是学计算机出身的一个iOS菜鸡，对于那些什么美颜算法什么的真的是搞不明白。我就上网找了一个，在我的demo中有，你也可以调用系统的滤镜文件。
```objc
//AVCaptureDevicePositionBack为后摄像头 front为前置摄像头
//AVCaptureSessionPreset1920x1080为分辨率 另外还支持多种分辨率
//AVCaptureSessionPreset1280x720 等等等等
- (GPUImageStillCamera *)camera{
    if (!_camera) {
        _camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        //设置前置摄像头镜像问题
        _camera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _camera;
}
```

```objc
//滤镜
- (GPUImageBeautifyFilter *)filter{
    if (!_filter) {
        _filter = [[GPUImageBeautifyFilter alloc]init];
    }
    return _filter;
}
```
```objc
- (GPUImageView *)imageView{
    if (!_imageView) {
        _imageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        //显示模式
        _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    }
    return _imageView;
}
```
这只是初始化，然后这3个变量之间还要添加一下
```objc
    [self.camera addTarget:self.filter];
    [self.filter addTarget:self.imageView];
    [self.view addSubview:self.imageView];
```
到此为止，你就万事俱备了，只差东风了。你一定会问，东风是什么？那么我就告诉你，东风就是`    [self.camera startCameraCapture];`这个时候你的相机就可以捕获视图了。
那么接下来，咱么就要给自己自定义的相机增加一些相应的功能按钮，例如拍照， 旋转摄像头之类的 都是标配
当我们按下拍照按钮的时候调用
```objc
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (error) {
            return ;
        }
        //成功了
        [self successCutPic:processedImage];
    }];
```
返回的那个`processedImage `就是你的照片了，然后你就去存储这张照片就可以了。当然了，你此时就用该让你的相机停止捕获视图`[self.camera stopCameraCapture];`然后再去存。
旋转摄像头，GPUImage自己就有相应的方法`[self.camera rotateCamera]`
***
忘记说了一个事情，在Github下载下来的GPUImage还需要你自己去编译`libGPUImage.a`文件。如果不会的话可以去看看[GPUImage集成](http://www.jianshu.com/p/b7c74c235b0f)上面写的很详细了。
***
