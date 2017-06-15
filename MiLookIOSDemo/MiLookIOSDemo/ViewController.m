//
//  ViewController.m
//  MiLookIOSDemo
//
//  Created by 侯 银博 on 2016/12/26.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//

#import "ViewController.h"
#import "CameraModel.h"
#import "DecorationModel.h"
#import "MiLookSDK/MiLookSDK.h"
#import "MiLookSDK/MiLookSDKDelegate.h"
#import "ActionSheetDelegate.h"
#import "IQActionSheetPickerView.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ViewController()<MiLookSDKDelegate,TrackDelegate,IQActionSheetPickerViewDelegate>{
    MiLookSDK* miLookSDK;
    CameraModel *cameraModel;
    DecorationModel *decorationModel;
    EAGLContext *_context;
    
    NSTimer * _timer1;
    
    UISwitch *beautySwitch;
    UILabel *beautyLabel;
    
    UISwitch *faceliftSwitch;
    UILabel *faceliftLabel;
    
    UISwitch *maskSwitch;
    UILabel *maskLabel;
    
    UISwitch *bigEyeSwitch;
    UILabel *bigEyeLabel;
    
    UISwitch *cameraSwitch;
    UILabel *cameraLabel;
    
    UISwitch *filterSwitch;
    UILabel *filterLabel;
    
    UISwitch *pointSwitch;
    UILabel *pointLabel;
    
    UISwitch *jawSwitch;
    UILabel *jawLabel;
    
    UISwitch *comboSwitch;
    UILabel *comboLabel;
    
    UISwitch *avatarSwitch;
    UILabel *avatarLabel;
    
    UISwitch *displaySwitch;
    UILabel *displayLabel;
    
    UIImageView *videoView;
    
    UIDeviceOrientation orientationResult;
    
    UIView* view;
    
    UISwitch *sdkSwitch;
    UILabel *sdkLabel;
    
    UIStepper *faceNumUIStepper;
    UILabel *faceNumLabel;
    
    Boolean takeImageflag;
    
    IQActionSheetPickerView *picker;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self initMiLookSDK ];
    [self StartPreview];
    [self StartCamera];
    //[self SwitchCamera]; //切换摄像头
    
    
    decorationModel = [DecorationModel new];
    decorationModel.points = false;
    decorationModel.maxFace = 1;
    
    decorationModel.faceDeform = [FaceDeformModel new];
    decorationModel.faceDeform.slim = 0;
    decorationModel.faceDeform.bigEye = 0;
    decorationModel.faceDeform.jaw = 0;
    
    decorationModel.beautify = [BeautifyModel new];
    decorationModel.beautify.level =0;
    

    
    [self addView];
    [self addView3];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)deviceOrientationDidChange {
    [self removeView];
    [self removeView3];
    UIInterfaceOrientation ori =[[UIApplication sharedApplication] statusBarOrientation];
    if(ori == UIInterfaceOrientationPortrait) {
        [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        NSString* orientation = @"portrait";
        
        [miLookSDK OrientationChange:orientation];
    } else if (ori == UIInterfaceOrientationLandscapeLeft) {
        [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        NSString* orientation = @"landscape-left";
        
        [miLookSDK OrientationChange:orientation];
    } else if (ori == UIInterfaceOrientationLandscapeRight) {
        [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        NSString* orientation = @"landscape-right";
                
        [miLookSDK OrientationChange:orientation];
    } else if (ori == UIInterfaceOrientationPortraitUpsideDown){
        
        [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];

        NSString* orientation = @"portrait-upsidedown";
    
        [miLookSDK OrientationChange:orientation];
    }
    
    [self addView];
    [self addView3];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

- (void) addView2
{
    //关闭SDK
    sdkSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-196, self.view.frame.size.width, 44)];
    sdkSwitch.on = YES;
    
    [self.view addSubview:sdkSwitch ];
    
    sdkLabel = [[UILabel alloc] initWithFrame:CGRectMake(28,self.view.frame.size.height-170,40,40)];
    
    sdkLabel.text = @"SDK";
    sdkLabel.textColor = [UIColor whiteColor];
    sdkLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sdkLabel ];
    
    [sdkSwitch addTarget:self action:@selector(sdkSwitchAction:) forControlEvents:UIControlEventValueChanged];
}

- (void) addView3
{
    //关闭SDK
    sdkSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-196, self.view.frame.size.width, 44)];
    sdkSwitch.on = YES;
   
    [self.view addSubview:sdkSwitch ];
    
    sdkLabel = [[UILabel alloc] initWithFrame:CGRectMake(28,self.view.frame.size.height-170,40,40)];
    
    sdkLabel.text = @"SDK";
    sdkLabel.textColor = [UIColor whiteColor];
    sdkLabel.backgroundColor = [UIColor clearColor];
   
    [self.view addSubview:sdkLabel ];
    
    [sdkSwitch addTarget:self action:@selector(sdkSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)setStepper:(UIStepper *)stepper {
    // 初始值
    stepper.value = 1;
    // 最大值
    stepper.maximumValue = 6;
    // 最小值
    stepper.minimumValue = 1;
    // 点击增减值
    stepper.stepValue = 1;
}

- (void) addView
{
    //faceNum
    faceNumUIStepper = [[UIStepper alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-256, self.view.frame.size.width, 44)];
    
    [self.view addSubview:faceNumUIStepper ];
    [self setStepper:faceNumUIStepper];
    
    faceNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(28,self.view.frame.size.height-230,40,40)];
    
    faceNumLabel.text = @"fn1";
    faceNumLabel.textColor = [UIColor whiteColor];
    faceNumLabel.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:faceNumLabel ];
    
    [faceNumUIStepper addTarget:self action:@selector(faceNumStepper:) forControlEvents:UIControlEventValueChanged];
    
    //关闭显示
    displaySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(80, self.view.frame.size.height-196, self.view.frame.size.width, 44)];
    displaySwitch.on = YES;
    
    [self.view addSubview:displaySwitch ];
    
    displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(88,self.view.frame.size.height-170,40,40)];
    
    displayLabel.text = @"DIS";
    displayLabel.textColor = [UIColor whiteColor];
    displayLabel.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:displayLabel ];
    
    [displaySwitch addTarget:self action:@selector(displaySwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    //美颜
    beautySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-66, self.view.frame.size.width, 44)];
    beautySwitch.on = NO;
    //[self.view insertSubview:beautySwitch atIndex:1];
    [self.view addSubview:beautySwitch ];
    
    
    beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(28,self.view.frame.size.height-40,40,40)];
    //beautyLabel.center = beautySwitch.center;
    beautyLabel.text = @"美颜";
    beautyLabel.textColor = [UIColor whiteColor];
    beautyLabel.backgroundColor = [UIColor clearColor];
    //[self.view insertSubview:beautyLabel atIndex:1];
    [self.view addSubview:beautyLabel];
    
    [beautySwitch addTarget:self action:@selector(beautySwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    //瘦脸
    faceliftSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(80, self.view.frame.size.height-66, self.view.frame.size.width, 44)];
    faceliftSwitch.on = NO;
    [self.view addSubview:faceliftSwitch ];
    
    faceliftLabel = [[UILabel alloc] initWithFrame:CGRectMake(88,self.view.frame.size.height-40,self.view.frame.size.width,44)];
    faceliftLabel.text = @"瘦脸";
    faceliftLabel.textColor = [UIColor whiteColor];
    faceliftLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:faceliftLabel ];
    
    [faceliftSwitch addTarget:self action:@selector(faceliftSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    //Mask
    maskSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(140, self.view.frame.size.height-66, self.view.frame.size.width, 44)];
    maskSwitch.on = NO;
   [self.view addSubview:maskSwitch ];
    
    maskLabel = [[UILabel alloc] initWithFrame:CGRectMake(148,self.view.frame.size.height-40,self.view.frame.size.width,44)];
    maskLabel.text = @"Mask";
    maskLabel.textColor = [UIColor whiteColor];
    maskLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:maskLabel ];
    
    [maskSwitch addTarget:self action:@selector(maskSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    
    //大眼
    bigEyeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, self.view.frame.size.height-66, self.view.frame.size.width, 44)];
    bigEyeSwitch.on = NO;
    [self.view addSubview:bigEyeSwitch ];
    
    bigEyeLabel = [[UILabel alloc] initWithFrame:CGRectMake(208,self.view.frame.size.height-40,self.view.frame.size.width,44)];
    bigEyeLabel.text = @"大眼";
    bigEyeLabel.textColor = [UIColor whiteColor];
    bigEyeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bigEyeLabel ];
    
    [bigEyeSwitch addTarget:self action:@selector(bigEyeSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    //切换摄像头
    cameraSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, self.view.frame.size.height-66, self.view.frame.size.width, 44)];
    cameraSwitch.on = YES;
    [self.view addSubview:cameraSwitch ];
    
    cameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(268,self.view.frame.size.height-40,self.view.frame.size.width,44)];
    cameraLabel.text = @"摄像头";
    cameraLabel.textColor = [UIColor whiteColor];
    cameraLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cameraLabel ];
    
    [cameraSwitch addTarget:self action:@selector(cameraSwitchAction:) forControlEvents:UIControlEventValueChanged];

    //滤镜
    filterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(140, self.view.frame.size.height-136, self.view.frame.size.width, 44)];
    filterSwitch.on = NO;
   [self.view addSubview:filterSwitch ];
    
    
    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(148,self.view.frame.size.height-110,self.view.frame.size.width,44)];
    filterLabel.text = @"filter";
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.backgroundColor = [UIColor clearColor];
   
    [self.view addSubview:filterLabel ];
    
    [filterSwitch addTarget:self action:@selector(filterSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    //point
    pointSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-136, self.view.frame.size.width, 44)];
    pointSwitch.on = NO;
    
    [self.view addSubview:pointSwitch ];
    
    pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(28,self.view.frame.size.height-110,self.view.frame.size.width,44)];
    pointLabel.text = @"point";
    pointLabel.textColor = [UIColor whiteColor];
    pointLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:pointLabel ];
    
    
    [pointSwitch addTarget:self action:@selector(pointSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    //jaw
    jawSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, self.view.frame.size.height-136, self.view.frame.size.width, 44)];
    jawSwitch.on = NO;
    //[self.view insertSubview:jawSwitch atIndex:1];
    [self.view addSubview:jawSwitch ];
    
    
    jawLabel = [[UILabel alloc] initWithFrame:CGRectMake(208,self.view.frame.size.height-110,self.view.frame.size.width,44)];
    jawLabel.text = @"JAW"; //jaw
    jawLabel.textColor = [UIColor whiteColor];
    jawLabel.backgroundColor = [UIColor clearColor];
    //[self.view insertSubview:jawLabel atIndex:1];
    [self.view addSubview:jawLabel ];
    
    [jawSwitch addTarget:self action:@selector(jawSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    
    //combo
    comboSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, self.view.frame.size.height-136, self.view.frame.size.width, 44)];
    comboSwitch.on = NO;
    [self.view addSubview:comboSwitch ];
    
    comboLabel = [[UILabel alloc] initWithFrame:CGRectMake(268,self.view.frame.size.height-110,self.view.frame.size.width,44)];
    comboLabel.text = @"combo"; //combo
    comboLabel.textColor = [UIColor whiteColor];
    comboLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:comboLabel ];
    
    [comboSwitch addTarget:self action:@selector(comboSwitchAction:) forControlEvents:UIControlEventValueChanged];
 
    //avatar
    avatarSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(80, self.view.frame.size.height-136, self.view.frame.size.width, 44)];
    avatarSwitch.on = NO;
    [self.view addSubview:avatarSwitch ];
    
    
    avatarLabel = [[UILabel alloc] initWithFrame:CGRectMake(88,self.view.frame.size.height-110,self.view.frame.size.width,44)];
    avatarLabel.text = @"avatar"; //avatar
    avatarLabel.textColor = [UIColor whiteColor];
    avatarLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:avatarLabel ];
    
    [avatarSwitch addTarget:self action:@selector(avatarSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
}

- (void) removeView3
{
    [sdkSwitch removeFromSuperview];
    [sdkLabel  removeFromSuperview];
}

- (void) removeView
{
    //[videoView removeFromSuperview];
    
    [faceNumUIStepper removeFromSuperview];
    [faceNumLabel removeFromSuperview];
    
    [displaySwitch removeFromSuperview];
    [displayLabel  removeFromSuperview];
    
    [beautySwitch removeFromSuperview];
    [beautyLabel  removeFromSuperview];
    
    [faceliftSwitch removeFromSuperview];
    [faceliftLabel removeFromSuperview];
    
    [maskSwitch removeFromSuperview];
    [maskLabel removeFromSuperview];
    
    [bigEyeSwitch removeFromSuperview];
    [bigEyeLabel removeFromSuperview];
    
    [cameraSwitch removeFromSuperview];
    [cameraLabel removeFromSuperview];
    
    [filterSwitch removeFromSuperview];
    [filterLabel removeFromSuperview];
    
    [pointSwitch removeFromSuperview];
    [pointLabel removeFromSuperview];
    
    [jawSwitch removeFromSuperview];
    [jawLabel removeFromSuperview];
    
    [comboSwitch removeFromSuperview];
    [comboLabel removeFromSuperview];
    
    [avatarSwitch removeFromSuperview];
    [avatarLabel removeFromSuperview];
}

- (void) timerTask {
    NSLog(@"Timer定时任务");
    //[self initMiLookSDK ];
    //[self StartPreview];
    //[self StartCamera];
}

-(void) initMiLookSDK{
    NSLog(@"初始化MiLookSDK");
    miLookSDK = [MiLookSDK shareMiLookSDK];
    BOOL bl = [miLookSDK InitSDK: @"暂时不填" withRootPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/resource/"] withModelPath:@"milo_data.bin" withMaxFace:1];
    NSLog(@"%d",bl);
}
-(void) StartPreview{
    NSLog(@"绘制界面");
    view =[miLookSDK StartPreview:self.view.bounds];
    [self.view addSubview:view ];
    
    //截屏
    videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH/2,SCREEN_HEIGHT/2)];
    videoView.contentMode = UIViewContentModeScaleAspectFill;
    videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    videoView.backgroundColor = [UIColor clearColor];
    [videoView setHidden:false];
    [self.view addSubview:videoView ];
    
    miLookSDK.delegate = self;
    
    //face detect
   // [miLookSDK SetTrackDelegate:self];
}

/**
 *拍照
 */
-(void)takePicture:(id)sender{
    takeImageflag = true;
}

-(void) StopPreview{
    NSLog(@"关闭绘制界面");
    [miLookSDK StopPreview];
}

/**
 * portrait
 * portrait-upsidedown
 * landscape-right
 * landscape-left
 * previewSize  @"640x480" @"1280x720"
 */
-(void) StartCamera{
    NSLog(@"打开摄像头");
    cameraModel = [CameraModel new];
    cameraModel.fps = 30;
    cameraModel.cameraID = 1;
    cameraModel.previewSize = @"1280x720";
    cameraModel.flash = false;
    cameraModel.sound = false;
    UIInterfaceOrientation ori =[[UIApplication sharedApplication] statusBarOrientation];
    if(ori == UIInterfaceOrientationPortrait){
        cameraModel.orientation = @"portrait";
    } else if(ori == UIInterfaceOrientationLandscapeLeft){
        cameraModel.orientation = @"landscape-left";
    } else if(ori == UIInterfaceOrientationLandscapeRight){
        cameraModel.orientation = @"landscape-right";
    } else if(ori == UIInterfaceOrientationPortraitUpsideDown){
        cameraModel.orientation = @"portrait-upsidedown";
    } else if(ori == UIInterfaceOrientationUnknown){
        cameraModel.orientation = @"portrait";
    } else{
        cameraModel.orientation = @"portrait";
    }
    
    NSString *string = [cameraModel toJSONString];
    NSLog(@"%@",string);
    [miLookSDK StartCamera :string];
}

/**
 * portrait
 * portrait-upsidedown
 * landscape-right
 * landscape-left
 */
-(void) SetCameraParam{
    cameraModel = [CameraModel new];
    cameraModel.fps = 30;
    cameraModel.cameraID = 1;
    cameraModel.previewSize = @"640x480";
    cameraModel.flash = false;
    cameraModel.orientation = @"portrait";
    NSString *string = [cameraModel toJSONString];
    NSLog(@"%@",string);
    [miLookSDK SetCameraParam:string];
}

-(void) SwitchCamera{
    NSLog(@"切换摄像头");
    [miLookSDK SwitchCamera];
}

-(void) StopCamera{
    NSLog(@"关闭摄像头");
    [miLookSDK StopCamera];
}

-(void) SetDecoration{
    NSLog(@"瘦脸/美颜/滤镜/FaceTracker点");
}

-(void) ProcessFrame{
    NSLog(@"处理视频");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)displaySwitchAction:(UISwitch *)sender{
    if ([sender isOn]){
        [miLookSDK display:true];
    }else{
        [miLookSDK display:false];
    }
}

// 点击事件
- (void)faceNumStepper:(UIStepper *)sender {
    decorationModel.maxFace = sender.value;
    [faceNumLabel setText:[NSString stringWithFormat:@"fn%d", decorationModel.maxFace]];
    NSString* string = [decorationModel toJSONString];
    NSLog(@"%@",string);
    [miLookSDK SetDecoration:string];
}

- (void)beautySwitchAction:(UISwitch *)sender{
    if ([sender isOn]){
        decorationModel.beautify.level =1;
        NSString* string = [decorationModel toJSONString];
        [miLookSDK SetDecoration:string];
    }else{
        decorationModel.beautify.level =0;
        [miLookSDK SetDecorationClear];
    }
}

- (void)faceliftSwitchAction:(UISwitch *)sender{
    if ([sender isOn]){
        decorationModel.faceDeform.slim = 1;
        NSString* string = [decorationModel toJSONString];
        [miLookSDK SetDecoration:string];
    }else{
        decorationModel.faceDeform.slim = 0;
        [miLookSDK SetDecorationClear];
    }
}

- (void)maskSwitchAction:(UISwitch *)sender{
    if ([sender isOn]){
        decorationModel.faceDeform.bigEye = 1;
        decorationModel.comb = [[NSArray<CombModel> alloc]init];
        NSMutableArray<CombModel> *combModelMutable = [[NSMutableArray<CombModel> alloc]init];
        
        CombModel *acc = [CombModel new];
        acc.type = @"foreground6"; // 前景
        acc.folder = @"foreground6.xml";
        [combModelMutable addObject:acc];
        
        CombModel *mask = [CombModel new];
        mask.type = @"Mask1";
        mask.folder = @"Mask1.xml"; //mask
        [combModelMutable addObject:mask];
        
        CombModel *trig = [CombModel new];
        trig.type = @"Face_Fire";
        trig.folder = @"Face_Fire.xml";
        [combModelMutable addObject:trig];
        
        decorationModel.comb = combModelMutable;
        
        NSString* string = [decorationModel toJSONString];
        NSLog(@"%@",string);
        [miLookSDK SetDecoration:string];

    }else{
        decorationModel.faceDeform.bigEye = 0;
        decorationModel.comb = nil;
        [miLookSDK SetDecorationClear];
    }
}


- (void)bigEyeSwitchAction:(UISwitch *)sender{
    if ([sender isOn]){
        decorationModel.faceDeform.bigEye = 1;
        NSString* string = [decorationModel toJSONString];
        [miLookSDK SetDecoration:string];
    }else{
        decorationModel.faceDeform.bigEye = 0;
        [miLookSDK SetDecorationClear];
    }
}

- (void)sdkSwitchAction:(UISwitch *)sender{
    NSLog(@"关闭SDK");
    if([sender isOn]){
        [self removeView3];
        [self initMiLookSDK ];
        [self StartPreview];
        [self StartCamera];
        [self addView];
        [self addView3];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        UIInterfaceOrientation ori =[[UIApplication sharedApplication] statusBarOrientation];
        if(ori == UIInterfaceOrientationPortrait){
            [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString* orientation = @"portrait";
            [miLookSDK OrientationChange:orientation];
        } else if(ori == UIInterfaceOrientationLandscapeLeft){
            [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString* orientation = @"landscape-left";
            [miLookSDK OrientationChange:orientation];
        } else if(ori == UIInterfaceOrientationLandscapeRight){
            [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString* orientation = @"landscape-right";
            [miLookSDK OrientationChange:orientation];
        } else if(ori == UIInterfaceOrientationPortraitUpsideDown){
            [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString* orientation = @"portrait-upsidedown";
            [miLookSDK OrientationChange:orientation];
        } else if(ori == UIInterfaceOrientationUnknown){
            [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString* orientation = @"portrait";
            [miLookSDK OrientationChange:orientation];
        } else{
            [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString* orientation = @"portrait";
            [miLookSDK OrientationChange:orientation];
        }

        //拍照
        //takeImageflag = true;
    }else{
        //miLookSDK.delegate = nil;
        
        [self removeView];
        [self StopCamera];
        [self StopPreview];
       
        //[view removeFromSuperview];
        //view = nil;
        //[self.view removeFromSuperview];
        //[self removeFromParentViewController];
        
        //[self removeView];
        
        //[[NSNotificationCenter defaultCenter] removeObserver:self ] ;
        
       
        
        
        
//        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(timerTask)]];
//        [invocation setTarget:self];
//        [invocation setSelector:@selector(timerTask)];
//        
//        _timer1 = [NSTimer timerWithTimeInterval:5 invocation:invocation repeats:NO];
//        [[NSRunLoop mainRunLoop] addTimer:_timer1 forMode:NSDefaultRunLoopMode];
        
    }
}

- (void)cameraSwitchAction:(UISwitch *)sender{
    NSLog(@"切换摄像头");
    [miLookSDK SwitchCamera];
}


-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    decorationModel.videoFilter =[VideoFilterModel new];
    switch (pickerView.tag)
    {
        case 1:
        {
            //1、暖阳
            decorationModel.videoFilter.type = @"ColorFilter";
            decorationModel.videoFilter.folder = @"portraitbeauty.png";
        }
            break;
        case 2:
        {
            //2、老电影
            decorationModel.videoFilter.type = @"OldFilm";
            decorationModel.videoFilter.folder = @"share_film.png";
        }
            break;
        case 3:
        {
            //3、11305 褪色
            decorationModel.videoFilter.type = @"CurveFilter";
            decorationModel.videoFilter.folder = @"qingxiheibai.png";
        }
            break;
        case 4:
        {
            //4、11052 MissEtikate色彩狂又名 拍立得
            decorationModel.videoFilter.type = @"DarkCornerFilter";
            decorationModel.videoFilter.folder = @"lomo.png";
            
        }
            break;
        case 5:
        {
            //        //5、油画
            decorationModel.videoFilter.type = @"KuwaharaFilter";
            decorationModel.videoFilter.folder = @"KuwaharaFilter";
        }
            break;
        case 6:
        {
            //        //6、素描
            decorationModel.videoFilter.type = @"CrayonPencilFilter";
            decorationModel.videoFilter.folder = @"CrayonPencilFilter";
        }
            break;
        case 7:
        {
            //        //7、11053,补光
            decorationModel.videoFilter.type = @"LightFilter";
            decorationModel.videoFilter.folder = @"LightFilter";
        }
            break;
        case 8:
        {
            //        //8、SkinRedFilter
            decorationModel.videoFilter.type = @"SkinRedFilter";
            decorationModel.videoFilter.folder = @"SkinRedFilter";
        }
            break;
        case 9:
        {
            ////9、清新丽人 //甜美可人//深度美白//香艳红唇//xxxxx
            decorationModel.videoFilter.type = @"1Filter";
            decorationModel.videoFilter.folder = @"portraitbeauty.png";
        }
            break;
        case 10:
        {
            ////10、清新丽人 //甜美可人//深度美白//香艳红唇//xxxxx
            decorationModel.videoFilter.type = @"2Filter";
            decorationModel.videoFilter.folder = @"portraitbeauty.png";
        }
            break;
        case 11:
        {
            ////11、清新丽人 //甜美可人//深度美白//香艳红唇//xxxxx
            decorationModel.videoFilter.type = @"3Filter";
            decorationModel.videoFilter.folder = @"portraitbeauty.png";
        }
            break;
        case 12:
        {
            ////12、清新丽人 //甜美可人//深度美白//香艳红唇//xxxxx
            decorationModel.videoFilter.type = @"4Filter";
            decorationModel.videoFilter.folder = @"portraitbeauty.png";
        }
            break;
        case 13:
        {
            ////13、清新丽人 //甜美可人//深度美白//香艳红唇//xxxxx
            decorationModel.videoFilter.type = @"5Filter";
            decorationModel.videoFilter.folder = @"portraitbeauty.png";
        }
            break;
        case 14:
        {
            //14、眼睛马赛克
            decorationModel.videoFilter.type = @"Mosaic";
            decorationModel.videoFilter.folder = @"Mosaic";
        }
            break;
        case 15:
        {
            //        //15、Mask
            decorationModel.videoFilter.type = @"Mask";
            decorationModel.videoFilter.folder = @"Mask";
        }
            break;
        case 16:
        {
            //        //16、Blur
            decorationModel.videoFilter.type = @"Blur";
            decorationModel.videoFilter.folder = @"Blur";
        }
            break;
        default:
            //1、暖阳
            decorationModel.videoFilter.type = @"ColorFilter";
            decorationModel.videoFilter.folder = @"portraitbeauty.png";
            break;
            
    }
    NSString* string = [decorationModel toJSONString];
    NSLog(@"%@",string);
    [miLookSDK SetDecoration:string];
}

- (void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didChangeRow:(NSInteger)row inComponent:(NSInteger)component
{
    //[picker setTag:pickerView.tag];
    [picker setTag:(row+1)];
}

- (void)filterSwitchAction:(UISwitch *)sender{
    NSLog(@"滤镜");
    if ([sender isOn]){
        picker = [[IQActionSheetPickerView alloc] initWithTitle:@"滤镜" delegate:self];
        picker.titleFont = [UIFont systemFontOfSize:12];
        picker.titleColor = [UIColor redColor];
        
        [picker setTitlesForComponents:@[@[@"1、暖阳", @"2、老电影", @"3、11305 褪色", @"4、11052 MissEtikate色彩狂又名 拍立得", @"5、油画",@"6、素描", @"7、11053,补光", @"8、SkinRedFilter", @"9、清新丽人 ", @"10、甜美可人",@"11、深度美白", @"12、香艳红唇", @"13、xxxxx", @"14、眼睛马赛克",@"15、Mask", @"16、Blur"]]];
        [picker show];
        
    }else{
        decorationModel.videoFilter = nil;
        NSString* string = [decorationModel toJSONString];
        NSLog(@"%@",string);
        [miLookSDK SetDecoration:string];
    }
}

- (void)pointSwitchAction:(UISwitch *)sender{
    NSLog(@"point");
    if ([sender isOn]){
        decorationModel.points = true;
        NSString* string = [decorationModel toJSONString];
        NSLog(@"%@",string);
        [miLookSDK SetDecoration:string];
    }else{
        decorationModel.points = false;
        NSString* string = [decorationModel toJSONString];
        NSLog(@"%@",string);
        [miLookSDK SetDecoration:string];
    }
}

- (void)avatarSwitchAction:(UISwitch *)sender{
    NSLog(@"avatar3d");
    if ([sender isOn]){
        decorationModel.comb = [[NSArray<CombModel> alloc]init];
        NSMutableArray<CombModel> *combModelMutable = [[NSMutableArray<CombModel> alloc]init];
        CombModel *headAcc = [CombModel new];
        headAcc.type = @"3d_mummy";
        headAcc.folder = @"3d_mummy.xml";
        [combModelMutable addObject:headAcc];
        
        decorationModel.comb = combModelMutable;
        
        NSString* string = [decorationModel toJSONString];
        NSLog(@"%@",string);
        [miLookSDK SetDecoration:string];
    }else{
        decorationModel.comb = nil;
        [miLookSDK SetDecorationClear];
    }
}

- (void)jawSwitchAction:(UISwitch *)sender{
    NSLog(@"jaw");
    if ([sender isOn]){
        decorationModel.faceDeform.jaw = 1;
        NSString* string = [decorationModel toJSONString];
        NSLog(@"%@",string);
        [miLookSDK SetDecoration:string];
    }else{
        decorationModel.faceDeform.jaw = 0;
        [miLookSDK SetDecorationClear];
    }
}

- (void)comboSwitchAction:(UISwitch *)sender{
    NSLog(@"combo");
    if ([sender isOn]){
        decorationModel.faceDeform.jaw = 1;
        decorationModel.faceDeform.slim = 1;
        decorationModel.beautify.level =1;
        decorationModel.faceDeform.bigEye = 1;
        decorationModel.comb = [[NSArray<CombModel> alloc]init];
        NSMutableArray<CombModel> *combModelMutable = [[NSMutableArray<CombModel> alloc]init];
        CombModel *headAcc = [CombModel new];
        headAcc.type = @"bear";
        headAcc.folder = @"bear.xml";
        [combModelMutable addObject:headAcc];
        
        CombModel *eyeAcc = [CombModel new];
        eyeAcc.type = @"bear_nose";
        eyeAcc.folder = @"bear_nose.xml";
        [combModelMutable addObject:eyeAcc];
        
        decorationModel.comb = combModelMutable;
    
        NSString* string = [decorationModel toJSONString];
        NSLog(@"%@",string);
        [miLookSDK SetDecoration:string];
    }else{
        decorationModel.faceDeform.jaw = 0;
        decorationModel.faceDeform.slim = 0;
        decorationModel.beautify.level =0;
        decorationModel.faceDeform.bigEye = 0;
        decorationModel.comb = nil;
        [miLookSDK SetDecorationClear];
    }
}


#pragma mark - MiLookSDKDelegate
-(void) captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
       devicePosition:(AVCaptureDevicePosition)devicePosition
          ofMediaType:(NSString*) mediaType
     videoPixelBuffer:(CVPixelBufferRef) pixelBuffer
 withPresentationTime:(CMTime) timestamp
{
    if([mediaType isEqualToString: AVMediaTypeVideo ]){
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                     width,
                                                     height,
                                                     8,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
        
        UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:0];
        videoView.image = image;
        
        CGImageRelease(quartzImage);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
    }else if([mediaType isEqualToString: AVMediaTypeAudio ]){
        //CFRelease(sampleBuffer);
    }
}

- (CVPixelBufferRef)correctBufferOrientation:(CVImageBufferRef)imageBuffer withRotation:(NSInteger)rotation {
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t bytesPerRow                  = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width                        = CVPixelBufferGetWidth(imageBuffer);
    size_t height                       = CVPixelBufferGetHeight(imageBuffer);
    size_t currSize                     = bytesPerRow * height * sizeof(unsigned char);
    size_t bytesPerRowOut               = bytesPerRow;
    
    void *srcBuff                       = CVPixelBufferGetBaseAddress(imageBuffer);
    
    /* rotationConstant:
     *  0 -- rotate 0 degrees (simply copy the data from src to dest)
     *  1 -- rotate 90 degrees counterclockwise
     *  2 -- rotate 180 degress
     *  3 -- rotate 270 degrees counterclockwise
     */
    uint8_t rotationConstant            = rotation;
    
    unsigned char *dstBuff              = (unsigned char *)malloc(currSize);
    
    vImage_Buffer inbuff                = {srcBuff, height, width, bytesPerRow};
    vImage_Buffer outbuff;
    
    if (rotationConstant == kRotate0DegreesClockwise || rotationConstant == kRotate180DegreesClockwise) {
        outbuff.data = dstBuff;
        outbuff.height = height;
        outbuff.width = width;
        outbuff.rowBytes = inbuff.rowBytes;
    } else {
        outbuff.data = dstBuff;
        outbuff.height = width;
        outbuff.width = height;
        bytesPerRowOut = 4 * height * sizeof(unsigned char);
        outbuff.rowBytes = 4 * height * sizeof(unsigned char);
    }
    
    uint8_t bgColor[4]                  = {0, 0, 0, 0};
    
    vImage_Error err                    = vImageRotate90_ARGB8888(&inbuff, &outbuff, rotationConstant, bgColor, 0);
    if (err != kvImageNoError) NSLog(@"%ld", err);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    CVPixelBufferRef rotatedBuffer      = NULL;
    CVPixelBufferCreateWithBytes(NULL,
                                 height,
                                 width,
                                 kCVPixelFormatType_32BGRA,
                                 outbuff.data,
                                 bytesPerRowOut,
                                 freePixelBufferDataAfterRelease,
                                 NULL,
                                 NULL,
                                 &rotatedBuffer);
    
    return rotatedBuffer;
}



- (CVPixelBufferRef)rotateBuffer:(CVImageBufferRef)imageBuffer
{
    CVPixelBufferLockBaseAddress( imageBuffer, 0 );
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow( imageBuffer );
    size_t width = CVPixelBufferGetWidth( imageBuffer );
    size_t height = CVPixelBufferGetHeight( imageBuffer );
    size_t currSize = bytesPerRow * height * sizeof( unsigned char );
    size_t bytesPerRowOut = 4 * height * sizeof( unsigned char );
    
    uint8_t rotationConstant = 3;
    
    void *srcBuff = CVPixelBufferGetBaseAddress( imageBuffer );
    
    unsigned char *outBuff = (unsigned char *)malloc( currSize );
    
    vImage_Buffer iBuff =
    {
        srcBuff, height, width, bytesPerRow
    };
    
    vImage_Buffer uBuff =
    {
        outBuff, width, height, bytesPerRowOut
    };
    
    uint8_t bgColor[4] = { 0, 0, 0, 0 };
    
    vImage_Error error = vImageRotate90_ARGB8888(&iBuff, &uBuff, rotationConstant, bgColor, 0);
    
    if( error != kvImageNoError )
    {
        NSLog(@"ERROR IN VIMAGE");
    }
    
    CVPixelBufferRef rotatedBuffer = NULL;
    CVPixelBufferCreateWithBytes(NULL,
                                 height,
                                 width,
                                 kCVPixelFormatType_32BGRA,
                                 uBuff.data,
                                 bytesPerRowOut,
                                 freePixelBufferDataAfterRelease,
                                 NULL,
                                 NULL,
                                 &rotatedBuffer);
    
    
    return rotatedBuffer;
}

void freePixelBufferDataAfterRelease(void *releaseRefCon, const void *baseAddress)
{
    free((void *)baseAddress);
}

- (UIImage *)imageFromCVPixelBuffer:(CVImageBufferRef)pixelBuffer
{
    size_t w = CVPixelBufferGetWidth(pixelBuffer);
    size_t h = CVPixelBufferGetHeight(pixelBuffer);
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    unsigned char *buffer = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    unsigned char* data = CGBitmapContextGetData(c);
    
    memcpy(data, buffer, CVPixelBufferGetDataSize( pixelBuffer) );
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
    return img;
}



// EX1 - Symmetric eye close
// EX2 - Right eye close
// EX3 - Left eye close
// EX4 - Symmetric wide eye open
// EX5 - Symmetric eyebrow raise
// EX6 - Right eyebrow raise
// EX7 - Left eyebrow raise
// EX8 - Symmetric eyebrow furrow
// EX9 - Ah-shape mouth open
// EX10 - Disgusted mouth shape
// EX11 - Downward displacement of the mouth
// EX12 - Oh-shaped mouth
// EX13 - Eh-shaped mouth
// EX14 - Mouth-closed smile
// EX15 - Mouth-open smile
// EX16 - Frown mouth shape
// EX17 - Pull of the right mouth corner
// EX18 - Pull of the left mouth corner
-(void) onFrameResult:(int) result trackData:(float[21]) trackData
{
    NSLog(@"%d",result);
    for(int i= 0; i<21;i++){
        NSLog(@"%f",trackData[i]);//表情权值
    }
}

@end
