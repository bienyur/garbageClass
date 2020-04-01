//
//  ViewController.m
//  SpeechTest
//
//  Created by Dushu Ou on 26/08/2017.
//  Copyright © 2017 Dushu Ou. All rights reserved.
//

#import "SpeechViewController.h"
#import <Speech/Speech.h>

@interface SpeechViewController (){
    UIScrollView *_scrollView;
    
    UILabel     *_textLabel;
    
    UIView      *_avatarWrapView2;
    UIButton *_avatarImageView2;
    UIBezierPath *_initPath;
    UIBezierPath *_finalPath;
    
}

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) QMUILabel *label1;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;

@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (strong, nonatomic) UIButton *backBtn;

@end
#define appWidth  [UIScreen mainScreen].bounds.size.width
//屏幕能显示的区域高度 考虑到了热点状态栏的情况
#define appHeight  [UIScreen mainScreen].bounds.size.height

#define RippleAnimationAvatarSize CGSizeMake(100, 100)
#define RippleAnimationExpandSizeValue 40.0
#define RippleAnimationDuration 2.0
#define RippleAnimationLineWidth 1.0
@implementation SpeechViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-2688h"]];
    image.frame = CGRectMake(0, 0, appWidth, appHeight);
    [self.view addSubview:image];
    
    
    _label1 = [[QMUILabel alloc] init];
    self.label1.text = @"按住识别";
    self.label1.font = UIFontMake(50);
    self.label1.textColor = UIColorWhite;
    self.label1.canPerformCopyAction = YES;
    
    
    self.label1.didCopyBlock = ^(QMUILabel *label, NSString *stringCopied) {
        [QMUITips showSucceed:@"已复制"];
    };
    self.label1.textAlignment = 1;
    [self.label1 sizeToFit];
    self.label1.numberOfLines = 0;
    self.label1.lineBreakMode = UILineBreakModeCharacterWrap;
    self.label1.frame = CGRectMake(0, appHeight/2-200, appWidth, 200);
    [self.view addSubview:self.label1];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // 请求权限
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"status %@", status == SFSpeechRecognizerAuthorizationStatusAuthorized ? @"授权成功" : @"授权失败");
    }];

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_scrollView];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.numberOfLines = 0;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = UIColorGray4;
    _textLabel.font = UIFontMake(16);
    _textLabel.text = @"第一个动画使用CAAnimationGroup来实现，第二个动画使用CAReplicatorLayer来实现。";
//    [_scrollView addSubview:_textLabel];
    
    _avatarWrapView2 = [[UIView alloc] init];
    [_scrollView addSubview:_avatarWrapView2];
    
//    _avatarImageView2 = [[UIImageView alloc] initWithImage:UIImageMake(@"image0")];
    _avatarImageView2 = [[UIButton alloc] qmui_initWithImage:UIImageMake(@"speech_icon1") title:nil];
    _avatarImageView2.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView2.clipsToBounds = YES;
    [_avatarImageView2 addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchDown];
    [_avatarImageView2 addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [_avatarWrapView2 addSubview:_avatarImageView2];
    
    _avatarImageView2.layer.cornerRadius = RippleAnimationAvatarSize.height / 2;

    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 60, 40)];
    [self.backBtn setTitle:@"<back" forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _initPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMake(0, 0, RippleAnimationAvatarSize.width, RippleAnimationAvatarSize.height), RippleAnimationLineWidth, RippleAnimationLineWidth)];
    _finalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMake(- RippleAnimationExpandSizeValue, - RippleAnimationExpandSizeValue, RippleAnimationAvatarSize.width + RippleAnimationExpandSizeValue * 2, RippleAnimationAvatarSize.height + RippleAnimationExpandSizeValue * 2), RippleAnimationLineWidth, RippleAnimationLineWidth)];
    
    [self beginAnimation];
}
- (void)initEngine {
    if (!self.speechRecognizer) {
        // 设置语言
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    }
    if (!self.audioEngine) {
        self.audioEngine = [[AVAudioEngine alloc] init];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    if (self.recognitionRequest) {
        [self.recognitionRequest endAudio];
        self.recognitionRequest = nil;
    }
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.recognitionRequest.shouldReportPartialResults = YES; // 实时翻译
    NSString *jsonString = [self datastr];
    self.dataDic = [[NSMutableDictionary alloc] init];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    self.dataDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    NSMutableDictionary *typeDic = [[NSMutableDictionary alloc] init];
    [typeDic setObject:@"可回收垃圾" forKey:@"1"];
    [typeDic setObject:@"有害垃圾" forKey:@"2"];
    [typeDic setObject:@"湿垃圾" forKey:@"3"];
    [typeDic setObject:@"干垃圾" forKey:@"4"];
    [typeDic setObject:@"电器电子产品" forKey:@"5"];
    
    [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        NSLog(@"is final: %d  result: %@", result.isFinal, result.bestTranscription.formattedString);
        NSMutableDictionary *mdic = [[NSMutableDictionary alloc] init];
        
        if (result.isFinal) {
            NSString *resultStr = result.bestTranscription.formattedString;
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"[ _`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]|\n|\r|\t"];
            NSString *resultS = [[resultStr componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
            
            for (int i = 0; i<2000; i++) {
                mdic = self.dataDic[[NSString stringWithFormat:@"%d",i]];
                if (mdic) {
                    if ([mdic[@"name"] isEqualToString:resultS]) {
                        self.label1.text = [NSString stringWithFormat:@"%@ - %@",mdic[@"name"],typeDic[mdic[@"type"]]];
                        return ;
                    }
                }
            }
            self.label1.text =[NSString stringWithFormat:@"'%@'\n没有匹配结果",resultS];
        }
    }];
}

- (void)releaseEngine {
    [[self.audioEngine inputNode] removeTapOnBus:0];
    [self.audioEngine stop];
    
    [self.recognitionRequest endAudio];
    self.recognitionRequest = nil;
}

- (void)startRecording:(UIButton *)recordButton {
    [self initEngine];
    
    AVAudioFormat *recordingFormat = [[self.audioEngine inputNode] outputFormatForBus:0];
    [[self.audioEngine inputNode] installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:nil];
    
    [recordButton setTitle:@"录音ing" forState:UIControlStateNormal];
}

- (void)stopRecording:(UIButton *)recordButton {
    [self releaseEngine];
    
    [recordButton setTitle:@"录音" forState:UIControlStateNormal];
}





- (void)dealloc {
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

- (void)handleWillEnterForeground:(NSNotification *)notification {
    [self beginAnimation];
}

//- (void)initSubviews {
//    [super initSubviews];
//
//    _scrollView = [[UIScrollView alloc] init];
//    [self.view addSubview:_scrollView];
//
//    _textLabel = [[UILabel alloc] init];
//    _textLabel.numberOfLines = 0;
//    _textLabel.textAlignment = NSTextAlignmentCenter;
//    _textLabel.textColor = UIColorGray4;
//    _textLabel.font = UIFontMake(16);
//    _textLabel.text = @"第一个动画使用CAAnimationGroup来实现，第二个动画使用CAReplicatorLayer来实现。";
//    [_scrollView addSubview:_textLabel];
//
//    _avatarWrapView1 = [[UIView alloc] init];
//    [_scrollView addSubview:_avatarWrapView1];
//
//    _avatarImageView1 = [[UIImageView alloc] initWithImage:UIImageMake(@"image0")];
//    _avatarImageView1.contentMode = UIViewContentModeScaleAspectFill;
//    _avatarImageView1.clipsToBounds = YES;
//    [_avatarWrapView1 addSubview:_avatarImageView1];
//
//    _avatarWrapView2 = [[UIView alloc] init];
//    [_scrollView addSubview:_avatarWrapView2];
//
//    _avatarImageView2 = [[UIImageView alloc] initWithImage:UIImageMake(@"image0")];
//    _avatarImageView2.contentMode = UIViewContentModeScaleAspectFill;
//    _avatarImageView2.clipsToBounds = YES;
//    [_avatarWrapView2 addSubview:_avatarImageView2];
//
//    _avatarImageView1.layer.cornerRadius = RippleAnimationAvatarSize.height / 2;
//    _avatarImageView2.layer.cornerRadius = RippleAnimationAvatarSize.height / 2;
//}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _scrollView.frame = self.view.bounds;
    
    CGFloat insetLeft = 20;
    _textLabel.frame = CGRectFlatMake(insetLeft, 40, CGRectGetWidth(self.view.bounds) - insetLeft * 2, QMUIViewSelfSizingHeight);
    
    _avatarWrapView2.frame = CGRectMake(CGFloatGetCenter(CGRectGetWidth(self.view.bounds), RippleAnimationAvatarSize.width), appHeight/2+RippleAnimationAvatarSize.height, RippleAnimationAvatarSize.width, RippleAnimationAvatarSize.height);
    _avatarImageView2.frame = _avatarWrapView2.bounds;
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.bounds), CGRectGetMaxY(_avatarWrapView2.frame) + 50);
}

- (void)beginAnimation {
    [self animationReplicatorAvatarInView:_avatarWrapView2 animated:YES];
    [_avatarWrapView2 bringSubviewToFront:_avatarImageView2];
}

- (void)animationAvatarInView:(UIView *)view animated:(BOOL)animated {
    
    NSMutableArray *_layers = [[NSMutableArray alloc] init];
    NSInteger count = view.layer.sublayers.count;
    for (int i = 0; i < count; i++) {
        if ([view.layer.sublayers[i] isKindOfClass:[CAShapeLayer class]]) {
            [_layers addObject:view.layer.sublayers[i]];
            [view.layer.sublayers[i] setHidden:YES];
        }
    }
    count = _layers.count;
    for (int i = 0; i < count; i++) {
        [_layers[i] removeFromSuperlayer];
    }
    
    if (!animated) {
        return;
    }
    
    CAShapeLayer *layer1 = [self animationLayerWithPath:_initPath];
    layer1.frame = CGRectMake(0, 0, RippleAnimationAvatarSize.width, RippleAnimationAvatarSize.height);
    [view.layer addSublayer:layer1];
    
    CAShapeLayer *layer2 = [self animationLayerWithPath:_initPath];
    layer2.frame = layer1.frame;
    [view.layer addSublayer:layer2];
    
    CAShapeLayer *layer3 = [self animationLayerWithPath:_initPath];
    layer3.frame = layer1.frame;
    [view.layer addSublayer:layer3];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)_initPath.CGPath;
    pathAnimation.toValue = (id)_finalPath.CGPath;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1;
    opacityAnimation.toValue = @0;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[pathAnimation, opacityAnimation];
    groupAnimation.duration = RippleAnimationDuration;
    groupAnimation.repeatCount = HUGE_VALF;
    
    [layer1 addAnimation:groupAnimation forKey:nil];
    groupAnimation.beginTime = CACurrentMediaTime() + RippleAnimationDuration / 3;
    [layer2 addAnimation:groupAnimation forKey:nil];
    groupAnimation.beginTime = CACurrentMediaTime() + 2 * RippleAnimationDuration / 3;
    [layer3 addAnimation:groupAnimation forKey:nil];
}

- (void)animationReplicatorAvatarInView:(UIView *)view animated:(BOOL)animated {
    
    NSMutableArray *_layers = [[NSMutableArray alloc] init];
    NSInteger count = view.layer.sublayers.count;
    for (int i = 0; i < count; i++) {
        if ([view.layer.sublayers[i] isKindOfClass:[CAReplicatorLayer class]]) {
            [_layers addObject:view.layer.sublayers[i]];
            [view.layer.sublayers[i] setHidden:YES];
        }
    }
    count = _layers.count;
    for (int i = 0; i < count; i++) {
        [_layers[i] removeFromSuperlayer];
    }
    
    if (!animated) {
        return;
    }
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.instanceCount = 3;
    replicatorLayer.instanceDelay = RippleAnimationDuration / 3;
    replicatorLayer.backgroundColor = UIColorClear.CGColor;
    [view.layer addSublayer:replicatorLayer];
    
    CAShapeLayer *layer = [self animationLayerWithPath:_initPath];
    layer.frame = CGRectMake(0, 0, RippleAnimationAvatarSize.width, RippleAnimationAvatarSize.height);
    [replicatorLayer addSublayer:layer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)_initPath.CGPath;
    pathAnimation.toValue = (id)_finalPath.CGPath;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1;
    opacityAnimation.toValue = @0;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[pathAnimation, opacityAnimation];
    groupAnimation.duration = RippleAnimationDuration;
    groupAnimation.repeatCount = HUGE_VALF;
    
    [layer addAnimation:groupAnimation forKey:nil];
}

- (CAShapeLayer *)animationLayerWithPath:(UIBezierPath *)path {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.strokeColor = UIColorBlue.CGColor;
    layer.fillColor = UIColorClear.CGColor;
    layer.lineWidth = RippleAnimationLineWidth;
    return layer;
}


- (NSString *)datastr{
    return @"{\"2\":{\"name\":\"开心果壳\",\"select\":\"0\",\"type\":\"3\"},\"4\":{\"name\":\"被套\",\"select\":\"0\",\"type\":\"1\"},\"8\":{\"name\":\"废旧牙刷\",\"select\":\"0\",\"type\":\"4\"},\"10\":{\"name\":\"电热毯\",\"select\":\"0\",\"type\":\"5\"},\"11\":{\"name\":\"红薯皮\",\"select\":\"0\",\"type\":\"3\"},\"13\":{\"name\":\"过滤芯\",\"select\":\"0\",\"type\":\"4\"},\"15\":{\"name\":\"大头钉\",\"select\":\"0\",\"type\":\"4\"},\"18\":{\"name\":\"爆米花\",\"select\":\"0\",\"type\":\"3\"},\"19\":{\"name\":\"蚌壳\",\"select\":\"0\",\"type\":\"4\"},\"21\":{\"name\":\"西洋参\",\"select\":\"0\",\"type\":\"3\"},\"26\":{\"name\":\"白菜叶\",\"select\":\"0\",\"type\":\"3\"},\"27\":{\"name\":\"黑豆\",\"select\":\"0\",\"type\":\"3\"},\"32\":{\"name\":\"家养绿植\",\"select\":\"0\",\"type\":\"3\"},\"35\":{\"name\":\"报刊\",\"select\":\"0\",\"type\":\"1\"},\"38\":{\"name\":\"披萨盒\",\"select\":\"0\",\"type\":\"4\"},\"42\":{\"name\":\"熟菜\",\"select\":\"0\",\"type\":\"3\"},\"44\":{\"name\":\"电子体温计\",\"select\":\"0\",\"type\":\"5\"},\"46\":{\"name\":\"光驱\",\"select\":\"0\",\"type\":\"5\"},\"47\":{\"name\":\"动物内脏\",\"select\":\"0\",\"type\":\"3\"},\"49\":{\"name\":\"少量泥土\",\"select\":\"0\",\"type\":\"4\"},\"54\":{\"name\":\"泡沫餐盒\",\"select\":\"0\",\"type\":\"4\"},\"56\":{\"name\":\"牛仔裤\",\"select\":\"0\",\"type\":\"1\"},\"58\":{\"name\":\"鸽子\",\"select\":\"0\",\"type\":\"3\"},\"61\":{\"name\":\"桂圆\",\"select\":\"0\",\"type\":\"3\"},\"62\":{\"name\":\"生姜\",\"select\":\"0\",\"type\":\"3\"},\"63\":{\"name\":\"谷物\",\"select\":\"0\",\"type\":\"3\"},\"65\":{\"name\":\"桂圆干壳\",\"select\":\"0\",\"type\":\"3\"},\"66\":{\"name\":\"插排\",\"select\":\"0\",\"type\":\"1\"},\"69\":{\"name\":\"牛尾\",\"select\":\"0\",\"type\":\"3\"},\"72\":{\"name\":\"卷烟\",\"select\":\"0\",\"type\":\"4\"},\"77\":{\"name\":\"优盘\",\"select\":\"0\",\"type\":\"5\"},\"79\":{\"name\":\"玻璃壶\",\"select\":\"0\",\"type\":\"1\"},\"80\":{\"name\":\"大螃蟹壳\",\"select\":\"0\",\"type\":\"3\"},\"82\":{\"name\":\"乒乓球\",\"select\":\"0\",\"type\":\"1\"},\"88\":{\"name\":\"鸭胗干\",\"select\":\"0\",\"type\":\"3\"},\"90\":{\"name\":\"蓄电池\",\"select\":\"0\",\"type\":\"2\"},\"94\":{\"name\":\"饼干包装袋\",\"select\":\"0\",\"type\":\"4\"},\"97\":{\"name\":\"电子琴\",\"select\":\"0\",\"type\":\"5\"},\"99\":{\"name\":\"黄芪\",\"select\":\"0\",\"type\":\"3\"},\"102\":{\"name\":\"摄像头\",\"select\":\"0\",\"type\":\"5\"},\"103\":{\"name\":\"化妆刷\",\"select\":\"0\",\"type\":\"4\"},\"110\":{\"name\":\"纺织物\",\"select\":\"0\",\"type\":\"1\"},\"111\":{\"name\":\"茶壶碎片\",\"select\":\"0\",\"type\":\"4\"},\"112\":{\"name\":\"饼干袋\",\"select\":\"0\",\"type\":\"4\"},\"113\":{\"name\":\"收银条\",\"select\":\"0\",\"type\":\"1\"},\"114\":{\"name\":\"伞\",\"select\":\"0\",\"type\":\"4\"},\"117\":{\"name\":\"芝麻\",\"select\":\"0\",\"type\":\"3\"},\"118\":{\"name\":\"无菌注射器包装\",\"select\":\"0\",\"type\":\"4\"},\"120\":{\"name\":\"搪瓷杯\",\"select\":\"0\",\"type\":\"4\"},\"121\":{\"name\":\"发圈\",\"select\":\"0\",\"type\":\"4\"},\"123\":{\"name\":\"搪瓷\",\"select\":\"0\",\"type\":\"1\"},\"124\":{\"name\":\"充电插头\",\"select\":\"0\",\"type\":\"1\"},\"125\":{\"name\":\"导线\",\"select\":\"0\",\"type\":\"1\"},\"126\":{\"name\":\"各类过期药品\",\"select\":\"0\",\"type\":\"2\"},\"128\":{\"name\":\"变质食品\",\"select\":\"0\",\"type\":\"3\"},\"130\":{\"name\":\"足球\",\"select\":\"0\",\"type\":\"1\"},\"133\":{\"name\":\"西柚\",\"select\":\"0\",\"type\":\"3\"},\"135\":{\"name\":\"双面胶\",\"select\":\"0\",\"type\":\"4\"},\"140\":{\"name\":\"夏威夷果\",\"select\":\"0\",\"type\":\"4\"},\"144\":{\"name\":\"胡桃壳\",\"select\":\"0\",\"type\":\"4\"},\"147\":{\"name\":\"山芋\",\"select\":\"0\",\"type\":\"3\"},\"152\":{\"name\":\"窗纱\",\"select\":\"0\",\"type\":\"4\"},\"155\":{\"name\":\"遥控车\",\"select\":\"0\",\"type\":\"5\"},\"165\":{\"name\":\"水饺\",\"select\":\"0\",\"type\":\"3\"},\"166\":{\"name\":\"电热蚊香片\",\"select\":\"0\",\"type\":\"4\"},\"168\":{\"name\":\"废中药材\",\"select\":\"0\",\"type\":\"3\"},\"171\":{\"name\":\"生蚝壳\",\"select\":\"0\",\"type\":\"4\"},\"173\":{\"name\":\"面包屑\",\"select\":\"0\",\"type\":\"3\"},\"174\":{\"name\":\"火腿\",\"select\":\"0\",\"type\":\"3\"},\"176\":{\"name\":\"电子镇流器\",\"select\":\"0\",\"type\":\"5\"},\"177\":{\"name\":\"茭白皮\",\"select\":\"0\",\"type\":\"3\"},\"179\":{\"name\":\"搅拌棒\",\"select\":\"0\",\"type\":\"4\"},\"180\":{\"name\":\"糖葫芦棍\",\"select\":\"0\",\"type\":\"4\"},\"181\":{\"name\":\"巧克力\",\"select\":\"0\",\"type\":\"3\"},\"182\":{\"name\":\"茶包\",\"select\":\"0\",\"type\":\"4\"},\"183\":{\"name\":\"南瓜子壳\",\"select\":\"0\",\"type\":\"3\"},\"190\":{\"name\":\"水果茎枝\",\"select\":\"0\",\"type\":\"3\"},\"191\":{\"name\":\"花泥\",\"select\":\"0\",\"type\":\"4\"},\"193\":{\"name\":\"萝卜\",\"select\":\"0\",\"type\":\"3\"},\"199\":{\"name\":\"电动洗脚盆\",\"select\":\"0\",\"type\":\"5\"},\"200\":{\"name\":\"披萨\",\"select\":\"0\",\"type\":\"3\"},\"208\":{\"name\":\"缎带\",\"select\":\"0\",\"type\":\"1\"},\"209\":{\"name\":\"金属拉链\",\"select\":\"0\",\"type\":\"1\"},\"213\":{\"name\":\"菌菇\",\"select\":\"0\",\"type\":\"3\"},\"214\":{\"name\":\"板栗\",\"select\":\"0\",\"type\":\"3\"},\"215\":{\"name\":\"活性炭\",\"select\":\"0\",\"type\":\"4\"},\"217\":{\"name\":\"风筝\",\"select\":\"0\",\"type\":\"4\"},\"220\":{\"name\":\"燕窝\",\"select\":\"0\",\"type\":\"3\"},\"221\":{\"name\":\"假发\",\"select\":\"0\",\"type\":\"4\"},\"222\":{\"name\":\"木梳\",\"select\":\"0\",\"type\":\"1\"},\"229\":{\"name\":\"咸菜\",\"select\":\"0\",\"type\":\"3\"},\"230\":{\"name\":\"菜梗\",\"select\":\"0\",\"type\":\"3\"},\"234\":{\"name\":\"保温棉\",\"select\":\"0\",\"type\":\"4\"},\"236\":{\"name\":\"冲泡饮料\",\"select\":\"0\",\"type\":\"3\"},\"238\":{\"name\":\"刀片\",\"select\":\"0\",\"type\":\"1\"},\"242\":{\"name\":\"铅酸电池\",\"select\":\"0\",\"type\":\"2\"},\"244\":{\"name\":\"电动玩具\",\"select\":\"0\",\"type\":\"5\"},\"246\":{\"name\":\"镍镉电池\",\"select\":\"0\",\"type\":\"2\"},\"253\":{\"name\":\"爆竹\",\"select\":\"0\",\"type\":\"4\"},\"254\":{\"name\":\"保鲜膜\",\"select\":\"0\",\"type\":\"4\"},\"255\":{\"name\":\"火柴\",\"select\":\"0\",\"type\":\"4\"},\"256\":{\"name\":\"芝士\",\"select\":\"0\",\"type\":\"3\"},\"258\":{\"name\":\"运动服\",\"select\":\"0\",\"type\":\"1\"},\"260\":{\"name\":\"游戏机\",\"select\":\"0\",\"type\":\"5\"},\"262\":{\"name\":\"耳屎\",\"select\":\"0\",\"type\":\"4\"},\"264\":{\"name\":\"长生果壳\",\"select\":\"0\",\"type\":\"3\"},\"266\":{\"name\":\"成人尿布\",\"select\":\"0\",\"type\":\"4\"},\"267\":{\"name\":\"多肉植物\",\"select\":\"0\",\"type\":\"3\"},\"268\":{\"name\":\"汉堡包\",\"select\":\"0\",\"type\":\"3\"},\"269\":{\"name\":\"芦苇叶\",\"select\":\"0\",\"type\":\"4\"},\"270\":{\"name\":\"菜根\",\"select\":\"0\",\"type\":\"3\"},\"271\":{\"name\":\"饼干渣\",\"select\":\"0\",\"type\":\"3\"},\"272\":{\"name\":\"太阳能热水器\",\"select\":\"0\",\"type\":\"5\"},\"273\":{\"name\":\"剪刀\",\"select\":\"0\",\"type\":\"1\"},\"275\":{\"name\":\"电动牙刷\",\"select\":\"0\",\"type\":\"5\"},\"278\":{\"name\":\"鸡骨架\",\"select\":\"0\",\"type\":\"3\"},\"279\":{\"name\":\"尼龙制品\",\"select\":\"0\",\"type\":\"4\"},\"280\":{\"name\":\"布面粉袋\",\"select\":\"0\",\"type\":\"1\"},\"281\":{\"name\":\"火腿肠\",\"select\":\"0\",\"type\":\"3\"},\"282\":{\"name\":\"章鱼\",\"select\":\"0\",\"type\":\"3\"},\"283\":{\"name\":\"保温材料\",\"select\":\"0\",\"type\":\"4\"},\"286\":{\"name\":\"睫毛膏\",\"select\":\"0\",\"type\":\"4\"},\"287\":{\"name\":\"三明治\",\"select\":\"0\",\"type\":\"3\"},\"289\":{\"name\":\"口罩\",\"select\":\"0\",\"type\":\"4\"},\"291\":{\"name\":\"笔\",\"select\":\"0\",\"type\":\"4\"},\"292\":{\"name\":\"竹坐垫\",\"select\":\"0\",\"type\":\"4\"},\"296\":{\"name\":\"灯管\",\"select\":\"0\",\"type\":\"2\"},\"299\":{\"name\":\"体重秤\",\"select\":\"0\",\"type\":\"5\"},\"301\":{\"name\":\"传单\",\"select\":\"0\",\"type\":\"1\"},\"303\":{\"name\":\"布包\",\"select\":\"0\",\"type\":\"1\"},\"308\":{\"name\":\"珍珠米\",\"select\":\"0\",\"type\":\"3\"},\"310\":{\"name\":\"连衣裙\",\"select\":\"0\",\"type\":\"1\"},\"311\":{\"name\":\"白菜\",\"select\":\"0\",\"type\":\"3\"},\"313\":{\"name\":\"菜椒\",\"select\":\"0\",\"type\":\"3\"},\"315\":{\"name\":\"瓜子仁\",\"select\":\"0\",\"type\":\"3\"},\"316\":{\"name\":\"纸质说明书\",\"select\":\"0\",\"type\":\"1\"},\"319\":{\"name\":\"鸡精\",\"select\":\"0\",\"type\":\"3\"},\"320\":{\"name\":\"雨伞\",\"select\":\"0\",\"type\":\"4\"},\"321\":{\"name\":\"粽子\",\"select\":\"0\",\"type\":\"3\"},\"322\":{\"name\":\"蛋挞托\",\"select\":\"0\",\"type\":\"4\"},\"324\":{\"name\":\"鸡\",\"select\":\"0\",\"type\":\"3\"},\"327\":{\"name\":\"豆浆袋\",\"select\":\"0\",\"type\":\"4\"},\"328\":{\"name\":\"药丸\",\"select\":\"0\",\"type\":\"2\"},\"331\":{\"name\":\"中草药\",\"select\":\"0\",\"type\":\"3\"},\"333\":{\"name\":\"龙虾\",\"select\":\"0\",\"type\":\"3\"},\"335\":{\"name\":\"高跟鞋\",\"select\":\"0\",\"type\":\"1\"},\"336\":{\"name\":\"臭豆腐\",\"select\":\"0\",\"type\":\"3\"},\"339\":{\"name\":\"蘸酱\",\"select\":\"0\",\"type\":\"3\"},\"342\":{\"name\":\"玻璃罐\",\"select\":\"0\",\"type\":\"1\"},\"343\":{\"name\":\"酒酿\",\"select\":\"0\",\"type\":\"3\"},\"344\":{\"name\":\"铝箔包\",\"select\":\"0\",\"type\":\"4\"},\"348\":{\"name\":\"牛筋\",\"select\":\"0\",\"type\":\"3\"},\"351\":{\"name\":\"大蒜\",\"select\":\"0\",\"type\":\"3\"},\"354\":{\"name\":\"芹菜\",\"select\":\"0\",\"type\":\"3\"},\"362\":{\"name\":\"过期零食\",\"select\":\"0\",\"type\":\"3\"},\"363\":{\"name\":\"氢气球\",\"select\":\"0\",\"type\":\"4\"},\"364\":{\"name\":\"炒板栗\",\"select\":\"0\",\"type\":\"3\"},\"365\":{\"name\":\"苍蝇\",\"select\":\"0\",\"type\":\"3\"},\"371\":{\"name\":\"电蚊拍\",\"select\":\"0\",\"type\":\"5\"},\"372\":{\"name\":\"长尾夹\",\"select\":\"0\",\"type\":\"1\"},\"373\":{\"name\":\"陈皮\",\"select\":\"0\",\"type\":\"3\"},\"377\":{\"name\":\"荷包蛋\",\"select\":\"0\",\"type\":\"3\"},\"385\":{\"name\":\"金属铅笔盒\",\"select\":\"0\",\"type\":\"1\"},\"386\":{\"name\":\"过期芝士\",\"select\":\"0\",\"type\":\"3\"},\"388\":{\"name\":\"脚指甲\",\"select\":\"0\",\"type\":\"4\"},\"393\":{\"name\":\"饺子\",\"select\":\"0\",\"type\":\"3\"},\"394\":{\"name\":\"验孕棒\",\"select\":\"0\",\"type\":\"4\"},\"396\":{\"name\":\"大排\",\"select\":\"0\",\"type\":\"3\"},\"398\":{\"name\":\"鸡翅\",\"select\":\"0\",\"type\":\"3\"},\"401\":{\"name\":\"避孕套\",\"select\":\"0\",\"type\":\"4\"},\"402\":{\"name\":\"豆腐乳\",\"select\":\"0\",\"type\":\"3\"},\"405\":{\"name\":\"山楂片\",\"select\":\"0\",\"type\":\"3\"},\"407\":{\"name\":\"围裙\",\"select\":\"0\",\"type\":\"1\"},\"415\":{\"name\":\"移动硬盘\",\"select\":\"0\",\"type\":\"5\"},\"416\":{\"name\":\"肮脏塑料袋\",\"select\":\"0\",\"type\":\"4\"},\"418\":{\"name\":\"凉席\",\"select\":\"0\",\"type\":\"4\"},\"419\":{\"name\":\"蘑菇\",\"select\":\"0\",\"type\":\"3\"},\"420\":{\"name\":\"考卷\",\"select\":\"0\",\"type\":\"1\"},\"423\":{\"name\":\"指甲钳\",\"select\":\"0\",\"type\":\"1\"},\"424\":{\"name\":\"辣条\",\"select\":\"0\",\"type\":\"3\"},\"429\":{\"name\":\"丁字裤\",\"select\":\"0\",\"type\":\"4\"},\"430\":{\"name\":\"煤灰\",\"select\":\"0\",\"type\":\"4\"},\"431\":{\"name\":\"阿尔卑斯糖\",\"select\":\"0\",\"type\":\"3\"},\"434\":{\"name\":\"蓝莓干\",\"select\":\"0\",\"type\":\"3\"},\"438\":{\"name\":\"可擦笔\",\"select\":\"0\",\"type\":\"4\"},\"439\":{\"name\":\"泡馍\",\"select\":\"0\",\"type\":\"3\"},\"441\":{\"name\":\"电热水壶\",\"select\":\"0\",\"type\":\"5\"},\"444\":{\"name\":\"勾线笔\",\"select\":\"0\",\"type\":\"4\"},\"445\":{\"name\":\"扫帚\",\"select\":\"0\",\"type\":\"4\"},\"451\":{\"name\":\"蛏子肉\",\"select\":\"0\",\"type\":\"3\"},\"456\":{\"name\":\"鲍鱼壳\",\"select\":\"0\",\"type\":\"4\"},\"458\":{\"name\":\"干红枣\",\"select\":\"0\",\"type\":\"3\"},\"462\":{\"name\":\"芒果干\",\"select\":\"0\",\"type\":\"3\"},\"466\":{\"name\":\"番薯\",\"select\":\"0\",\"type\":\"3\"},\"467\":{\"name\":\"遮阳帽\",\"select\":\"0\",\"type\":\"1\"},\"468\":{\"name\":\"胡椒粉\",\"select\":\"0\",\"type\":\"3\"},\"469\":{\"name\":\"冬笋壳\",\"select\":\"0\",\"type\":\"3\"},\"470\":{\"name\":\"不锈钢\",\"select\":\"0\",\"type\":\"1\"},\"471\":{\"name\":\"美工刀\",\"select\":\"0\",\"type\":\"1\"},\"473\":{\"name\":\"螃蟹\",\"select\":\"0\",\"type\":\"3\"},\"474\":{\"name\":\"丝绸制品\",\"select\":\"0\",\"type\":\"1\"},\"476\":{\"name\":\"抱枕\",\"select\":\"0\",\"type\":\"1\"},\"482\":{\"name\":\"西瓜\",\"select\":\"0\",\"type\":\"3\"},\"483\":{\"name\":\"游戏手柄\",\"select\":\"0\",\"type\":\"5\"},\"484\":{\"name\":\"猕猴桃\",\"select\":\"0\",\"type\":\"3\"},\"487\":{\"name\":\"狗粮\",\"select\":\"0\",\"type\":\"3\"},\"489\":{\"name\":\"花螺\",\"select\":\"0\",\"type\":\"4\"},\"490\":{\"name\":\"打印间碎纸\",\"select\":\"0\",\"type\":\"1\"},\"493\":{\"name\":\"月季\",\"select\":\"0\",\"type\":\"3\"},\"502\":{\"name\":\"甜瓜\",\"select\":\"0\",\"type\":\"3\"},\"507\":{\"name\":\"美瞳\",\"select\":\"0\",\"type\":\"4\"},\"509\":{\"name\":\"木砧板\",\"select\":\"0\",\"type\":\"1\"},\"511\":{\"name\":\"白炽灯\",\"select\":\"0\",\"type\":\"2\"},\"518\":{\"name\":\"练习本\",\"select\":\"0\",\"type\":\"1\"},\"525\":{\"name\":\"花朵\",\"select\":\"0\",\"type\":\"3\"},\"527\":{\"name\":\"香肠\",\"select\":\"0\",\"type\":\"3\"},\"529\":{\"name\":\"榴莲干\",\"select\":\"0\",\"type\":\"3\"},\"530\":{\"name\":\"馒头\",\"select\":\"0\",\"type\":\"3\"},\"531\":{\"name\":\"海报\",\"select\":\"0\",\"type\":\"1\"},\"533\":{\"name\":\"西兰花\",\"select\":\"0\",\"type\":\"3\"},\"542\":{\"name\":\"尼龙绳\",\"select\":\"0\",\"type\":\"4\"},\"543\":{\"name\":\"辣椒\",\"select\":\"0\",\"type\":\"3\"},\"549\":{\"name\":\"瓷器\",\"select\":\"0\",\"type\":\"4\"},\"551\":{\"name\":\"尘土\",\"select\":\"0\",\"type\":\"4\"},\"552\":{\"name\":\"信封\",\"select\":\"0\",\"type\":\"1\"},\"553\":{\"name\":\"电影票\",\"select\":\"0\",\"type\":\"1\"},\"554\":{\"name\":\"钨丝灯泡\",\"select\":\"0\",\"type\":\"2\"},\"555\":{\"name\":\"除湿盒\",\"select\":\"0\",\"type\":\"1\"},\"556\":{\"name\":\"玻璃锅盖\",\"select\":\"0\",\"type\":\"1\"},\"559\":{\"name\":\"太阳能热水管\",\"select\":\"0\",\"type\":\"1\"},\"560\":{\"name\":\"海苔\",\"select\":\"0\",\"type\":\"3\"},\"565\":{\"name\":\"麻绳\",\"select\":\"0\",\"type\":\"4\"},\"566\":{\"name\":\"羽毛球\",\"select\":\"0\",\"type\":\"4\"},\"568\":{\"name\":\"洗脸巾\",\"select\":\"0\",\"type\":\"4\"},\"573\":{\"name\":\"胡萝卜\",\"select\":\"0\",\"type\":\"3\"},\"574\":{\"name\":\"人造奶油\",\"select\":\"0\",\"type\":\"3\"},\"576\":{\"name\":\"洋山芋\",\"select\":\"0\",\"type\":\"3\"},\"578\":{\"name\":\"冰激凌\",\"select\":\"0\",\"type\":\"3\"},\"579\":{\"name\":\"香蕉\",\"select\":\"0\",\"type\":\"3\"},\"581\":{\"name\":\"丝瓜瓤\",\"select\":\"0\",\"type\":\"3\"},\"584\":{\"name\":\"本子\",\"select\":\"0\",\"type\":\"1\"},\"594\":{\"name\":\"纸质购物袋\",\"select\":\"0\",\"type\":\"1\"},\"595\":{\"name\":\"咸鱼\",\"select\":\"0\",\"type\":\"3\"},\"597\":{\"name\":\"艾叶\",\"select\":\"0\",\"type\":\"3\"},\"599\":{\"name\":\"被单\",\"select\":\"0\",\"type\":\"1\"},\"600\":{\"name\":\"菠萝\",\"select\":\"0\",\"type\":\"3\"},\"601\":{\"name\":\"贝壳肉\",\"select\":\"0\",\"type\":\"3\"},\"604\":{\"name\":\"电子书阅读器\",\"select\":\"0\",\"type\":\"5\"},\"605\":{\"name\":\"玉米穗\",\"select\":\"0\",\"type\":\"3\"},\"607\":{\"name\":\"速溶饮料粉末\",\"select\":\"0\",\"type\":\"3\"},\"609\":{\"name\":\"夏威夷果壳\",\"select\":\"0\",\"type\":\"4\"},\"619\":{\"name\":\"橘子\",\"select\":\"0\",\"type\":\"3\"},\"621\":{\"name\":\"月饼\",\"select\":\"0\",\"type\":\"3\"},\"623\":{\"name\":\"挂耳咖啡包\",\"select\":\"0\",\"type\":\"4\"},\"625\":{\"name\":\"兔肉\",\"select\":\"0\",\"type\":\"3\"},\"627\":{\"name\":\"莲雾\",\"select\":\"0\",\"type\":\"3\"},\"628\":{\"name\":\"布鞋\",\"select\":\"0\",\"type\":\"1\"},\"632\":{\"name\":\"年糕\",\"select\":\"0\",\"type\":\"3\"},\"633\":{\"name\":\"圣女果\",\"select\":\"0\",\"type\":\"3\"},\"635\":{\"name\":\"鲜肉月饼\",\"select\":\"0\",\"type\":\"3\"},\"636\":{\"name\":\"扑克牌\",\"select\":\"0\",\"type\":\"1\"},\"637\":{\"name\":\"炒花生壳\",\"select\":\"0\",\"type\":\"3\"},\"640\":{\"name\":\"速溶咖啡包装\",\"select\":\"0\",\"type\":\"4\"},\"641\":{\"name\":\"磁铁\",\"select\":\"0\",\"type\":\"1\"},\"642\":{\"name\":\"玻璃胶带\",\"select\":\"0\",\"type\":\"4\"},\"645\":{\"name\":\"甜甜圈\",\"select\":\"0\",\"type\":\"3\"},\"647\":{\"name\":\"冬瓜\",\"select\":\"0\",\"type\":\"3\"},\"651\":{\"name\":\"笔盖\",\"select\":\"0\",\"type\":\"4\"},\"654\":{\"name\":\"大闸蟹壳\",\"select\":\"0\",\"type\":\"3\"},\"656\":{\"name\":\"八宝粥\",\"select\":\"0\",\"type\":\"3\"},\"661\":{\"name\":\"牛鞭\",\"select\":\"0\",\"type\":\"3\"},\"663\":{\"name\":\"亚克力板\",\"select\":\"0\",\"type\":\"1\"},\"665\":{\"name\":\"鸡爪\",\"select\":\"0\",\"type\":\"3\"},\"669\":{\"name\":\"吹风机\",\"select\":\"0\",\"type\":\"5\"},\"674\":{\"name\":\"炸鸡腿\",\"select\":\"0\",\"type\":\"3\"},\"675\":{\"name\":\"马铃薯片\",\"select\":\"0\",\"type\":\"3\"},\"676\":{\"name\":\"芦荟\",\"select\":\"0\",\"type\":\"3\"},\"680\":{\"name\":\"膨化食品\",\"select\":\"0\",\"type\":\"3\"},\"683\":{\"name\":\"生煎包\",\"select\":\"0\",\"type\":\"3\"},\"686\":{\"name\":\"按摩棒\",\"select\":\"0\",\"type\":\"4\"},\"689\":{\"name\":\"雪糕棒\",\"select\":\"0\",\"type\":\"4\"},\"691\":{\"name\":\"硅胶铲\",\"select\":\"0\",\"type\":\"4\"},\"693\":{\"name\":\"山芋皮\",\"select\":\"0\",\"type\":\"3\"},\"696\":{\"name\":\"电路板\",\"select\":\"0\",\"type\":\"1\"},\"697\":{\"name\":\"肋排\",\"select\":\"0\",\"type\":\"3\"},\"702\":{\"name\":\"咸鸭蛋壳\",\"select\":\"0\",\"type\":\"3\"},\"703\":{\"name\":\"梭子蟹\",\"select\":\"0\",\"type\":\"3\"},\"704\":{\"name\":\"蛤蜊壳\",\"select\":\"0\",\"type\":\"4\"},\"706\":{\"name\":\"折扇\",\"select\":\"0\",\"type\":\"4\"},\"713\":{\"name\":\"中成药\",\"select\":\"0\",\"type\":\"2\"},\"716\":{\"name\":\"衣服吊牌\",\"select\":\"0\",\"type\":\"4\"},\"719\":{\"name\":\"平板电脑\",\"select\":\"0\",\"type\":\"5\"},\"721\":{\"name\":\"粘鼠板\",\"select\":\"0\",\"type\":\"4\"},\"727\":{\"name\":\"果冻盒\",\"select\":\"0\",\"type\":\"4\"},\"730\":{\"name\":\"调味品\",\"select\":\"0\",\"type\":\"3\"},\"731\":{\"name\":\"板擦儿\",\"select\":\"0\",\"type\":\"4\"},\"733\":{\"name\":\"图钉\",\"select\":\"0\",\"type\":\"4\"},\"738\":{\"name\":\"豆腐\",\"select\":\"0\",\"type\":\"3\"},\"742\":{\"name\":\"暖宝宝帖\",\"select\":\"0\",\"type\":\"4\"},\"743\":{\"name\":\"胶卷\",\"select\":\"0\",\"type\":\"2\"},\"744\":{\"name\":\"海螺\",\"select\":\"0\",\"type\":\"4\"},\"746\":{\"name\":\"电焊丝\",\"select\":\"0\",\"type\":\"1\"},\"747\":{\"name\":\"标签\",\"select\":\"0\",\"type\":\"4\"},\"751\":{\"name\":\"水垢\",\"select\":\"0\",\"type\":\"4\"},\"755\":{\"name\":\"粘鼠胶\",\"select\":\"0\",\"type\":\"2\"},\"756\":{\"name\":\"玻璃锅\",\"select\":\"0\",\"type\":\"1\"},\"762\":{\"name\":\"甘蔗皮\",\"select\":\"0\",\"type\":\"4\"},\"768\":{\"name\":\"冬枣核\",\"select\":\"0\",\"type\":\"3\"},\"770\":{\"name\":\"荔枝壳\",\"select\":\"0\",\"type\":\"3\"},\"773\":{\"name\":\"橙子\",\"select\":\"0\",\"type\":\"3\"},\"774\":{\"name\":\"电子温度计\",\"select\":\"0\",\"type\":\"5\"},\"776\":{\"name\":\"芋艿\",\"select\":\"0\",\"type\":\"3\"},\"777\":{\"name\":\"鸟笼\",\"select\":\"0\",\"type\":\"4\"},\"782\":{\"name\":\"微波炉\",\"select\":\"0\",\"type\":\"5\"},\"784\":{\"name\":\"窗帘\",\"select\":\"0\",\"type\":\"1\"},\"791\":{\"name\":\"过期芝麻酱\",\"select\":\"0\",\"type\":\"3\"},\"792\":{\"name\":\"钢化膜\",\"select\":\"0\",\"type\":\"4\"},\"796\":{\"name\":\"糠\",\"select\":\"0\",\"type\":\"3\"},\"797\":{\"name\":\"包装干燥剂\",\"select\":\"0\",\"type\":\"4\"},\"798\":{\"name\":\"黑框眼镜\",\"select\":\"0\",\"type\":\"4\"},\"802\":{\"name\":\"马铃薯\",\"select\":\"0\",\"type\":\"3\"},\"809\":{\"name\":\"大米包装袋\",\"select\":\"0\",\"type\":\"4\"},\"813\":{\"name\":\"雨刮器\",\"select\":\"0\",\"type\":\"4\"},\"817\":{\"name\":\"电话机\",\"select\":\"0\",\"type\":\"5\"},\"823\":{\"name\":\"快递包装袋\",\"select\":\"0\",\"type\":\"4\"},\"825\":{\"name\":\"记号笔\",\"select\":\"0\",\"type\":\"4\"},\"835\":{\"name\":\"绿豆芽\",\"select\":\"0\",\"type\":\"3\"},\"836\":{\"name\":\"彩票\",\"select\":\"0\",\"type\":\"4\"},\"837\":{\"name\":\"南瓜\",\"select\":\"0\",\"type\":\"3\"},\"838\":{\"name\":\"方便面\",\"select\":\"0\",\"type\":\"3\"},\"839\":{\"name\":\"可降解塑料袋\",\"select\":\"0\",\"type\":\"4\"},\"846\":{\"name\":\"纱布\",\"select\":\"0\",\"type\":\"4\"},\"851\":{\"name\":\"南瓜皮\",\"select\":\"0\",\"type\":\"3\"},\"852\":{\"name\":\"贝壳\",\"select\":\"0\",\"type\":\"4\"},\"856\":{\"name\":\"葱\",\"select\":\"0\",\"type\":\"3\"},\"858\":{\"name\":\"长生果\",\"select\":\"0\",\"type\":\"3\"},\"859\":{\"name\":\"厨房垃圾袋\",\"select\":\"0\",\"type\":\"4\"},\"863\":{\"name\":\"冰棍棒\",\"select\":\"0\",\"type\":\"4\"},\"866\":{\"name\":\"粽叶\",\"select\":\"0\",\"type\":\"4\"},\"868\":{\"name\":\"电动剃须刀\",\"select\":\"0\",\"type\":\"5\"},\"869\":{\"name\":\"烤箱\",\"select\":\"0\",\"type\":\"5\"},\"871\":{\"name\":\"菜花\",\"select\":\"0\",\"type\":\"3\"},\"873\":{\"name\":\"肥皂\",\"select\":\"0\",\"type\":\"4\"},\"876\":{\"name\":\"窗玻璃\",\"select\":\"0\",\"type\":\"1\"},\"883\":{\"name\":\"牡蛎肉\",\"select\":\"0\",\"type\":\"3\"},\"885\":{\"name\":\"煤饼\",\"select\":\"0\",\"type\":\"4\"},\"887\":{\"name\":\"草稿纸\",\"select\":\"0\",\"type\":\"1\"},\"888\":{\"name\":\"显卡\",\"select\":\"0\",\"type\":\"1\"},\"890\":{\"name\":\"塑料积木\",\"select\":\"0\",\"type\":\"1\"},\"894\":{\"name\":\"鼻屎\",\"select\":\"0\",\"type\":\"4\"},\"895\":{\"name\":\"红笔\",\"select\":\"0\",\"type\":\"4\"},\"896\":{\"name\":\"走油肉\",\"select\":\"0\",\"type\":\"3\"},\"898\":{\"name\":\"录像带\",\"select\":\"0\",\"type\":\"2\"},\"899\":{\"name\":\"白炽灯泡\",\"select\":\"0\",\"type\":\"2\"},\"900\":{\"name\":\"莲蓬\",\"select\":\"0\",\"type\":\"3\"},\"901\":{\"name\":\"纺织布\",\"select\":\"0\",\"type\":\"1\"},\"907\":{\"name\":\"无线路由器\",\"select\":\"0\",\"type\":\"5\"},\"909\":{\"name\":\"仙人掌\",\"select\":\"0\",\"type\":\"3\"},\"910\":{\"name\":\"蒜\",\"select\":\"0\",\"type\":\"3\"},\"912\":{\"name\":\"茶叶蛋\",\"select\":\"0\",\"type\":\"3\"},\"918\":{\"name\":\"乌龟壳\",\"select\":\"0\",\"type\":\"4\"},\"920\":{\"name\":\"草\",\"select\":\"0\",\"type\":\"3\"},\"923\":{\"name\":\"键盘\",\"select\":\"0\",\"type\":\"5\"},\"924\":{\"name\":\"盐\",\"select\":\"0\",\"type\":\"3\"},\"928\":{\"name\":\"玻璃制品\",\"select\":\"0\",\"type\":\"1\"},\"929\":{\"name\":\"羊毛衫\",\"select\":\"0\",\"type\":\"1\"},\"931\":{\"name\":\"大豆\",\"select\":\"0\",\"type\":\"3\"},\"934\":{\"name\":\"绷带\",\"select\":\"0\",\"type\":\"4\"},\"935\":{\"name\":\"老鼠药\",\"select\":\"0\",\"type\":\"2\"},\"939\":{\"name\":\"掉落的头发\",\"select\":\"0\",\"type\":\"4\"},\"943\":{\"name\":\"玻璃餐具\",\"select\":\"0\",\"type\":\"1\"},\"951\":{\"name\":\"八宝饭\",\"select\":\"0\",\"type\":\"3\"},\"955\":{\"name\":\"莲藕\",\"select\":\"0\",\"type\":\"3\"},\"956\":{\"name\":\"卤素灯\",\"select\":\"0\",\"type\":\"2\"},\"957\":{\"name\":\"矿泉水瓶\",\"select\":\"0\",\"type\":\"1\"},\"959\":{\"name\":\"八角\",\"select\":\"0\",\"type\":\"3\"},\"961\":{\"name\":\"干桂圆壳\",\"select\":\"0\",\"type\":\"3\"},\"966\":{\"name\":\"姨妈巾\",\"select\":\"0\",\"type\":\"4\"},\"970\":{\"name\":\"玻璃器皿\",\"select\":\"0\",\"type\":\"1\"},\"972\":{\"name\":\"主板\",\"select\":\"0\",\"type\":\"1\"},\"973\":{\"name\":\"冰淇淋\",\"select\":\"0\",\"type\":\"3\"},\"974\":{\"name\":\"玻璃盆\",\"select\":\"0\",\"type\":\"1\"},\"975\":{\"name\":\"快递冰袋\",\"select\":\"0\",\"type\":\"4\"},\"976\":{\"name\":\"鸡\",\"select\":\"0\",\"type\":\"3\"},\"977\":{\"name\":\"残渣剩饭\",\"select\":\"0\",\"type\":\"3\"},\"979\":{\"name\":\"宠物饲料\",\"select\":\"0\",\"type\":\"3\"},\"981\":{\"name\":\"凉皮\",\"select\":\"0\",\"type\":\"3\"},\"995\":{\"name\":\"废油漆\",\"select\":\"0\",\"type\":\"2\"},\"997\":{\"name\":\"彩笔\",\"select\":\"0\",\"type\":\"4\"},\"1000\":{\"name\":\"充电电池\",\"select\":\"0\",\"type\":\"2\"},\"1001\":{\"name\":\"菠萝蜜壳\",\"select\":\"0\",\"type\":\"4\"},\"1005\":{\"name\":\"鼻毛\",\"select\":\"0\",\"type\":\"4\"},\"1010\":{\"name\":\"透明胶带\",\"select\":\"0\",\"type\":\"4\"},\"1012\":{\"name\":\"不锈钢刀\",\"select\":\"0\",\"type\":\"1\"},\"1020\":{\"name\":\"感光胶片\",\"select\":\"0\",\"type\":\"2\"},\"1024\":{\"name\":\"有机溶剂\",\"select\":\"0\",\"type\":\"2\"},\"1025\":{\"name\":\"菠菜\",\"select\":\"0\",\"type\":\"3\"},\"1026\":{\"name\":\"绣花针\",\"select\":\"0\",\"type\":\"4\"},\"1027\":{\"name\":\"碱性无汞电池\",\"select\":\"0\",\"type\":\"4\"},\"1029\":{\"name\":\"尼龙丝袜\",\"select\":\"0\",\"type\":\"4\"},\"1032\":{\"name\":\"蒸汽眼罩\",\"select\":\"0\",\"type\":\"4\"},\"1033\":{\"name\":\"螺蛳壳\",\"select\":\"0\",\"type\":\"3\"},\"1036\":{\"name\":\"琼脂\",\"select\":\"0\",\"type\":\"3\"},\"1037\":{\"name\":\"牙齿\",\"select\":\"0\",\"type\":\"4\"},\"1042\":{\"name\":\"红薯\",\"select\":\"0\",\"type\":\"3\"},\"1043\":{\"name\":\"绸带\",\"select\":\"0\",\"type\":\"1\"},\"1045\":{\"name\":\"长筒连裤袜\",\"select\":\"0\",\"type\":\"4\"},\"1047\":{\"name\":\"火龙果皮\",\"select\":\"0\",\"type\":\"3\"},\"1050\":{\"name\":\"西红柿\",\"select\":\"0\",\"type\":\"3\"},\"1052\":{\"name\":\"饭团\",\"select\":\"0\",\"type\":\"3\"},\"1058\":{\"name\":\"安全套\",\"select\":\"0\",\"type\":\"4\"},\"1059\":{\"name\":\"樱桃\",\"select\":\"0\",\"type\":\"3\"},\"1061\":{\"name\":\"布条\",\"select\":\"0\",\"type\":\"1\"},\"1063\":{\"name\":\"苹果\",\"select\":\"0\",\"type\":\"3\"},\"1064\":{\"name\":\"茭白\",\"select\":\"0\",\"type\":\"3\"},\"1073\":{\"name\":\"行车记录仪\",\"select\":\"0\",\"type\":\"5\"},\"1074\":{\"name\":\"蛋挞皮\",\"select\":\"0\",\"type\":\"3\"},\"1075\":{\"name\":\"毛绒玩具\",\"select\":\"0\",\"type\":\"1\"},\"1076\":{\"name\":\"韭菜\",\"select\":\"0\",\"type\":\"3\"},\"1077\":{\"name\":\"辣酱\",\"select\":\"0\",\"type\":\"3\"},\"1080\":{\"name\":\"内存条\",\"select\":\"0\",\"type\":\"1\"},\"1081\":{\"name\":\"鞭炮\",\"select\":\"0\",\"type\":\"4\"},\"1082\":{\"name\":\"电脑包\",\"select\":\"0\",\"type\":\"1\"},\"1090\":{\"name\":\"板栗壳\",\"select\":\"0\",\"type\":\"3\"},\"1092\":{\"name\":\"豌豆壳\",\"select\":\"0\",\"type\":\"3\"},\"1093\":{\"name\":\"冰袋\",\"select\":\"0\",\"type\":\"4\"},\"1094\":{\"name\":\"龙虾壳\",\"select\":\"0\",\"type\":\"3\"},\"1097\":{\"name\":\"三明治包装\",\"select\":\"0\",\"type\":\"4\"},\"1098\":{\"name\":\"包书膜\",\"select\":\"0\",\"type\":\"4\"},\"1100\":{\"name\":\"彩色玻璃\",\"select\":\"0\",\"type\":\"1\"},\"1101\":{\"name\":\"松子\",\"select\":\"0\",\"type\":\"3\"},\"1104\":{\"name\":\"碳纤维\",\"select\":\"0\",\"type\":\"4\"},\"1106\":{\"name\":\"漂白剂罐\",\"select\":\"0\",\"type\":\"2\"},\"1107\":{\"name\":\"无纺布\",\"select\":\"0\",\"type\":\"4\"},\"1109\":{\"name\":\"腊肉\",\"select\":\"0\",\"type\":\"3\"},\"1111\":{\"name\":\"化纤衣物\",\"select\":\"0\",\"type\":\"1\"},\"1112\":{\"name\":\"毽子\",\"select\":\"0\",\"type\":\"4\"},\"1113\":{\"name\":\"可丽饼\",\"select\":\"0\",\"type\":\"3\"},\"1117\":{\"name\":\"传真机\",\"select\":\"0\",\"type\":\"5\"},\"1119\":{\"name\":\"炸鸡\",\"select\":\"0\",\"type\":\"3\"},\"1120\":{\"name\":\"发蜡\",\"select\":\"0\",\"type\":\"4\"},\"1121\":{\"name\":\"杀虫喷雾\",\"select\":\"0\",\"type\":\"2\"},\"1122\":{\"name\":\"麻辣烫\",\"select\":\"0\",\"type\":\"3\"},\"1123\":{\"name\":\"围巾\",\"select\":\"0\",\"type\":\"1\"},\"1127\":{\"name\":\"玉米\",\"select\":\"0\",\"type\":\"3\"},\"1130\":{\"name\":\"芦稷\",\"select\":\"0\",\"type\":\"3\"},\"1131\":{\"name\":\"红烧肉\",\"select\":\"0\",\"type\":\"3\"},\"1135\":{\"name\":\"螺蛳\",\"select\":\"0\",\"type\":\"3\"},\"1137\":{\"name\":\"钓鱼钩\",\"select\":\"0\",\"type\":\"4\"},\"1141\":{\"name\":\"曲奇\",\"select\":\"0\",\"type\":\"3\"},\"1144\":{\"name\":\"枇杷叶\",\"select\":\"0\",\"type\":\"3\"},\"1149\":{\"name\":\"芒果\",\"select\":\"0\",\"type\":\"3\"},\"1152\":{\"name\":\"门锁\",\"select\":\"0\",\"type\":\"1\"},\"1153\":{\"name\":\"红枣\",\"select\":\"0\",\"type\":\"3\"},\"1156\":{\"name\":\"电磁炉\",\"select\":\"0\",\"type\":\"5\"},\"1162\":{\"name\":\"烂苹果\",\"select\":\"0\",\"type\":\"3\"},\"1164\":{\"name\":\"玻璃\",\"select\":\"0\",\"type\":\"1\"},\"1167\":{\"name\":\"熟玉米棒\",\"select\":\"0\",\"type\":\"3\"},\"1170\":{\"name\":\"草莓\",\"select\":\"0\",\"type\":\"3\"},\"1175\":{\"name\":\"木塞\",\"select\":\"0\",\"type\":\"4\"},\"1180\":{\"name\":\"花卉绿植\",\"select\":\"0\",\"type\":\"3\"},\"1182\":{\"name\":\"金属\",\"select\":\"0\",\"type\":\"1\"},\"1184\":{\"name\":\"感冒药\",\"select\":\"0\",\"type\":\"2\"},\"1186\":{\"name\":\"奶酪\",\"select\":\"0\",\"type\":\"3\"},\"1197\":{\"name\":\"腰带\",\"select\":\"0\",\"type\":\"1\"},\"1198\":{\"name\":\"兔头\",\"select\":\"0\",\"type\":\"3\"},\"1200\":{\"name\":\"脱水机\",\"select\":\"0\",\"type\":\"5\"},\"1203\":{\"name\":\"姜\",\"select\":\"0\",\"type\":\"3\"},\"1204\":{\"name\":\"创口贴\",\"select\":\"0\",\"type\":\"4\"},\"1206\":{\"name\":\"电钻\",\"select\":\"0\",\"type\":\"5\"},\"1207\":{\"name\":\"槟榔壳\",\"select\":\"0\",\"type\":\"3\"},\"1208\":{\"name\":\"蛤蜊肉\",\"select\":\"0\",\"type\":\"3\"},\"1209\":{\"name\":\"蛇皮袋\",\"select\":\"0\",\"type\":\"4\"},\"1210\":{\"name\":\"马克笔\",\"select\":\"0\",\"type\":\"4\"},\"1218\":{\"name\":\"电子手表\",\"select\":\"0\",\"type\":\"5\"},\"1219\":{\"name\":\"牛肉粒包装袋\",\"select\":\"0\",\"type\":\"4\"},\"1220\":{\"name\":\"菠萝干\",\"select\":\"0\",\"type\":\"3\"},\"1222\":{\"name\":\"保龄球\",\"select\":\"0\",\"type\":\"4\"},\"1224\":{\"name\":\"废旧抹布\",\"select\":\"0\",\"type\":\"4\"},\"1225\":{\"name\":\"菱角\",\"select\":\"0\",\"type\":\"3\"},\"1226\":{\"name\":\"青椰\",\"select\":\"0\",\"type\":\"4\"},\"1228\":{\"name\":\"地瓜皮\",\"select\":\"0\",\"type\":\"3\"},\"1229\":{\"name\":\"可降解垃圾袋\",\"select\":\"0\",\"type\":\"4\"},\"1232\":{\"name\":\"充电式暖宝宝\",\"select\":\"0\",\"type\":\"5\"},\"1234\":{\"name\":\"巴旦木壳\",\"select\":\"0\",\"type\":\"3\"},\"1235\":{\"name\":\"*屏蔽的关键字*\",\"select\":\"0\",\"type\":\"3\"},\"1237\":{\"name\":\"蛋挞\",\"select\":\"0\",\"type\":\"3\"},\"1238\":{\"name\":\"数字音乐播放器\",\"select\":\"0\",\"type\":\"5\"},\"1239\":{\"name\":\"床罩\",\"select\":\"0\",\"type\":\"1\"},\"1242\":{\"name\":\"缝纫针\",\"select\":\"0\",\"type\":\"4\"},\"1246\":{\"name\":\"乐扣乐扣塑料盒\",\"select\":\"0\",\"type\":\"1\"},\"1247\":{\"name\":\"蛤蜊\",\"select\":\"0\",\"type\":\"4\"},\"1248\":{\"name\":\"梨\",\"select\":\"0\",\"type\":\"3\"},\"1249\":{\"name\":\"车厘子\",\"select\":\"0\",\"type\":\"3\"},\"1251\":{\"name\":\"香榧子仁\",\"select\":\"0\",\"type\":\"3\"},\"1252\":{\"name\":\"水斗漏网\",\"select\":\"0\",\"type\":\"4\"},\"1253\":{\"name\":\"杨梅\",\"select\":\"0\",\"type\":\"3\"},\"1255\":{\"name\":\"铝箔\",\"select\":\"0\",\"type\":\"1\"},\"1256\":{\"name\":\"充电器\",\"select\":\"0\",\"type\":\"1\"},\"1257\":{\"name\":\"创可贴\",\"select\":\"0\",\"type\":\"4\"},\"1258\":{\"name\":\"眉笔\",\"select\":\"0\",\"type\":\"4\"},\"1260\":{\"name\":\"大闸蟹\",\"select\":\"0\",\"type\":\"3\"},\"1261\":{\"name\":\"路由器\",\"select\":\"0\",\"type\":\"5\"},\"1266\":{\"name\":\"摄像机\",\"select\":\"0\",\"type\":\"5\"},\"1267\":{\"name\":\"电视机顶盒\",\"select\":\"0\",\"type\":\"5\"},\"1269\":{\"name\":\"滤网\",\"select\":\"0\",\"type\":\"4\"},\"1270\":{\"name\":\"葱油饼\",\"select\":\"0\",\"type\":\"3\"},\"1271\":{\"name\":\"水果脆\",\"select\":\"0\",\"type\":\"3\"},\"1273\":{\"name\":\"柠檬\",\"select\":\"0\",\"type\":\"3\"},\"1278\":{\"name\":\"除草剂\",\"select\":\"0\",\"type\":\"2\"},\"1280\":{\"name\":\"电熨斗\",\"select\":\"0\",\"type\":\"5\"},\"1281\":{\"name\":\"蜡笔\",\"select\":\"0\",\"type\":\"4\"},\"1285\":{\"name\":\"海绵\",\"select\":\"0\",\"type\":\"4\"},\"1287\":{\"name\":\"擦手巾\",\"select\":\"0\",\"type\":\"4\"},\"1288\":{\"name\":\"废金属\",\"select\":\"0\",\"type\":\"1\"},\"1289\":{\"name\":\"笋壳\",\"select\":\"0\",\"type\":\"3\"},\"1291\":{\"name\":\"蛋黄\",\"select\":\"0\",\"type\":\"3\"},\"1293\":{\"name\":\"豆角壳\",\"select\":\"0\",\"type\":\"3\"},\"1295\":{\"name\":\"海带\",\"select\":\"0\",\"type\":\"3\"},\"1296\":{\"name\":\"作业本\",\"select\":\"0\",\"type\":\"1\"},\"1304\":{\"name\":\"洋葱皮\",\"select\":\"0\",\"type\":\"3\"},\"1305\":{\"name\":\"烧卖\",\"select\":\"0\",\"type\":\"3\"},\"1311\":{\"name\":\"玻璃摆件\",\"select\":\"0\",\"type\":\"1\"},\"1312\":{\"name\":\"红肠\",\"select\":\"0\",\"type\":\"3\"},\"1313\":{\"name\":\"2\",\"select\":\"0\",\"type\":\"2\"},\"1315\":{\"name\":\"白板笔\",\"select\":\"0\",\"type\":\"4\"},\"1320\":{\"name\":\"葵花籽壳\",\"select\":\"0\",\"type\":\"3\"},\"1328\":{\"name\":\"双面胶带\",\"select\":\"0\",\"type\":\"4\"},\"1331\":{\"name\":\"鲍鱼\",\"select\":\"0\",\"type\":\"4\"},\"1332\":{\"name\":\"大核桃壳\",\"select\":\"0\",\"type\":\"4\"},\"1337\":{\"name\":\"防潮剂\",\"select\":\"0\",\"type\":\"4\"},\"1338\":{\"name\":\"牡蛎壳\",\"select\":\"0\",\"type\":\"4\"},\"1339\":{\"name\":\"电话簿\",\"select\":\"0\",\"type\":\"1\"},\"1341\":{\"name\":\"曲别针\",\"select\":\"0\",\"type\":\"4\"},\"1345\":{\"name\":\"废油漆桶\",\"select\":\"0\",\"type\":\"2\"},\"1346\":{\"name\":\"笔记本电脑\",\"select\":\"0\",\"type\":\"5\"},\"1351\":{\"name\":\"杏仁壳\",\"select\":\"0\",\"type\":\"3\"},\"1352\":{\"name\":\"塑料篮筐\",\"select\":\"0\",\"type\":\"1\"},\"1355\":{\"name\":\"果冻\",\"select\":\"0\",\"type\":\"3\"},\"1361\":{\"name\":\"猫砂\",\"select\":\"0\",\"type\":\"4\"},\"1363\":{\"name\":\"美容仪\",\"select\":\"0\",\"type\":\"5\"},\"1368\":{\"name\":\"鱼鳞\",\"select\":\"0\",\"type\":\"3\"},\"1369\":{\"name\":\"蟑螂\",\"select\":\"0\",\"type\":\"3\"},\"1372\":{\"name\":\"长靴\",\"select\":\"0\",\"type\":\"1\"},\"1373\":{\"name\":\"午餐肉\",\"select\":\"0\",\"type\":\"3\"},\"1377\":{\"name\":\"碧根果壳\",\"select\":\"0\",\"type\":\"4\"},\"1379\":{\"name\":\"画笔\",\"select\":\"0\",\"type\":\"4\"},\"1382\":{\"name\":\"淀粉\",\"select\":\"0\",\"type\":\"3\"},\"1383\":{\"name\":\"挂历\",\"select\":\"0\",\"type\":\"1\"},\"1390\":{\"name\":\"充电宝\",\"select\":\"0\",\"type\":\"1\"},\"1391\":{\"name\":\"夹克\",\"select\":\"0\",\"type\":\"1\"},\"1394\":{\"name\":\"酒瓶塞子\",\"select\":\"0\",\"type\":\"4\"},\"1404\":{\"name\":\"蛋糕\",\"select\":\"0\",\"type\":\"3\"},\"1405\":{\"name\":\"避孕药\",\"select\":\"0\",\"type\":\"2\"},\"1406\":{\"name\":\"消炎片\",\"select\":\"0\",\"type\":\"2\"},\"1409\":{\"name\":\"干橘子皮\",\"select\":\"0\",\"type\":\"3\"},\"1414\":{\"name\":\"施工安全帽\",\"select\":\"0\",\"type\":\"1\"},\"1415\":{\"name\":\"干拌面\",\"select\":\"0\",\"type\":\"3\"},\"1417\":{\"name\":\"鸡鸭骨头\",\"select\":\"0\",\"type\":\"3\"},\"1418\":{\"name\":\"水银血压计\",\"select\":\"0\",\"type\":\"2\"},\"1419\":{\"name\":\"宝特瓶\",\"select\":\"0\",\"type\":\"1\"},\"1420\":{\"name\":\"废花盆\",\"select\":\"0\",\"type\":\"4\"},\"1421\":{\"name\":\"过期隐形眼镜\",\"select\":\"0\",\"type\":\"4\"},\"1422\":{\"name\":\"彩色铅笔\",\"select\":\"0\",\"type\":\"4\"},\"1423\":{\"name\":\"打火机\",\"select\":\"0\",\"type\":\"4\"},\"1426\":{\"name\":\"电热水袋\",\"select\":\"0\",\"type\":\"5\"},\"1430\":{\"name\":\"腐烂蔬菜\",\"select\":\"0\",\"type\":\"3\"},\"1435\":{\"name\":\"番茄皮\",\"select\":\"0\",\"type\":\"3\"},\"1436\":{\"name\":\"松木猫砂\",\"select\":\"0\",\"type\":\"4\"},\"1439\":{\"name\":\"海胆壳\",\"select\":\"0\",\"type\":\"4\"},\"1442\":{\"name\":\"汗衫\",\"select\":\"0\",\"type\":\"1\"},\"1443\":{\"name\":\"桔柑\",\"select\":\"0\",\"type\":\"3\"},\"1445\":{\"name\":\"草席\",\"select\":\"0\",\"type\":\"4\"},\"1446\":{\"name\":\"桑叶\",\"select\":\"0\",\"type\":\"3\"},\"1448\":{\"name\":\"床单\",\"select\":\"0\",\"type\":\"1\"},\"1450\":{\"name\":\"鱼刺\",\"select\":\"0\",\"type\":\"3\"},\"1451\":{\"name\":\"番茄\",\"select\":\"0\",\"type\":\"3\"},\"1458\":{\"name\":\"钓鱼线\",\"select\":\"0\",\"type\":\"4\"},\"1461\":{\"name\":\"熟鸡蛋\",\"select\":\"0\",\"type\":\"3\"},\"1462\":{\"name\":\"除湿机\",\"select\":\"0\",\"type\":\"5\"},\"1464\":{\"name\":\"空灭火器\",\"select\":\"0\",\"type\":\"1\"},\"1466\":{\"name\":\"干燥剂\",\"select\":\"0\",\"type\":\"4\"},\"1467\":{\"name\":\"开心果\",\"select\":\"0\",\"type\":\"3\"},\"1471\":{\"name\":\"鸡毛掸子\",\"select\":\"0\",\"type\":\"4\"},\"1474\":{\"name\":\"含汞血压计\",\"select\":\"0\",\"type\":\"2\"},\"1476\":{\"name\":\"夫妻肺片\",\"select\":\"0\",\"type\":\"3\"},\"1478\":{\"name\":\"生日蜡烛\",\"select\":\"0\",\"type\":\"4\"},\"1481\":{\"name\":\"西瓜皮\",\"select\":\"0\",\"type\":\"3\"},\"1482\":{\"name\":\"蛋卷\",\"select\":\"0\",\"type\":\"3\"},\"1484\":{\"name\":\"烧鸡\",\"select\":\"0\",\"type\":\"3\"},\"1487\":{\"name\":\"方便面桶\",\"select\":\"0\",\"type\":\"4\"},\"1488\":{\"name\":\"葵花籽\",\"select\":\"0\",\"type\":\"3\"},\"1489\":{\"name\":\"帆布包\",\"select\":\"0\",\"type\":\"1\"},\"1491\":{\"name\":\"瓦楞纸\",\"select\":\"0\",\"type\":\"1\"},\"1493\":{\"name\":\"杀虫剂\",\"select\":\"0\",\"type\":\"2\"},\"1495\":{\"name\":\"飞机杯\",\"select\":\"0\",\"type\":\"4\"},\"1497\":{\"name\":\"电暖炉\",\"select\":\"0\",\"type\":\"5\"},\"1498\":{\"name\":\"星巴克纸杯\",\"select\":\"0\",\"type\":\"4\"},\"1499\":{\"name\":\"仙人球\",\"select\":\"0\",\"type\":\"3\"},\"1500\":{\"name\":\"利乐砖\",\"select\":\"0\",\"type\":\"1\"},\"1504\":{\"name\":\"泡沫板\",\"select\":\"0\",\"type\":\"1\"},\"1508\":{\"name\":\"电子游戏机\",\"select\":\"0\",\"type\":\"5\"},\"1509\":{\"name\":\"搅拌勺\",\"select\":\"0\",\"type\":\"4\"},\"1512\":{\"name\":\"护垫\",\"select\":\"0\",\"type\":\"4\"},\"1515\":{\"name\":\"水煮花生壳\",\"select\":\"0\",\"type\":\"3\"},\"1521\":{\"name\":\"痰盂罐\",\"select\":\"0\",\"type\":\"1\"},\"1522\":{\"name\":\"核桃壳\",\"select\":\"0\",\"type\":\"4\"},\"1523\":{\"name\":\"金属汤匙\",\"select\":\"0\",\"type\":\"1\"},\"1526\":{\"name\":\"卸妆棉\",\"select\":\"0\",\"type\":\"4\"},\"1530\":{\"name\":\"死昆虫\",\"select\":\"0\",\"type\":\"3\"},\"1532\":{\"name\":\"蜘蛛\",\"select\":\"0\",\"type\":\"3\"},\"1534\":{\"name\":\"死蟑螂\",\"select\":\"0\",\"type\":\"3\"},\"1535\":{\"name\":\"保鲜袋\",\"select\":\"0\",\"type\":\"4\"},\"1537\":{\"name\":\"手撕猪肉\",\"select\":\"0\",\"type\":\"3\"},\"1538\":{\"name\":\"百洁布\",\"select\":\"0\",\"type\":\"4\"},\"1539\":{\"name\":\"鸡肝\",\"select\":\"0\",\"type\":\"3\"},\"1543\":{\"name\":\"皮筋\",\"select\":\"0\",\"type\":\"4\"},\"1544\":{\"name\":\"鹅\",\"select\":\"0\",\"type\":\"3\"},\"1546\":{\"name\":\"塑料模型\",\"select\":\"0\",\"type\":\"1\"},\"1549\":{\"name\":\"麦丽素\",\"select\":\"0\",\"type\":\"3\"},\"1553\":{\"name\":\"金属包装盒\",\"select\":\"0\",\"type\":\"1\"},\"1555\":{\"name\":\"棒棒糖杆\",\"select\":\"0\",\"type\":\"4\"},\"1556\":{\"name\":\"薄型塑料袋\",\"select\":\"0\",\"type\":\"4\"},\"1557\":{\"name\":\"广告单\",\"select\":\"0\",\"type\":\"1\"},\"1562\":{\"name\":\"牛杂\",\"select\":\"0\",\"type\":\"3\"},\"1564\":{\"name\":\"蚕豆壳\",\"select\":\"0\",\"type\":\"3\"},\"1566\":{\"name\":\"紫菜\",\"select\":\"0\",\"type\":\"3\"},\"1567\":{\"name\":\"假睫毛\",\"select\":\"0\",\"type\":\"4\"},\"1570\":{\"name\":\"挂号纸\",\"select\":\"0\",\"type\":\"1\"},\"1572\":{\"name\":\"衬衫\",\"select\":\"0\",\"type\":\"1\"},\"1576\":{\"name\":\"卤素灯泡\",\"select\":\"0\",\"type\":\"2\"},\"1577\":{\"name\":\"密胺餐具\",\"select\":\"0\",\"type\":\"1\"},\"1579\":{\"name\":\"蛋白素肉包装袋\",\"select\":\"0\",\"type\":\"4\"},\"1583\":{\"name\":\"玫瑰花\",\"select\":\"0\",\"type\":\"3\"},\"1594\":{\"name\":\"硅胶\",\"select\":\"0\",\"type\":\"4\"},\"1598\":{\"name\":\"布\",\"select\":\"0\",\"type\":\"1\"},\"1601\":{\"name\":\"纽扣\",\"select\":\"0\",\"type\":\"4\"},\"1607\":{\"name\":\"艾草\",\"select\":\"0\",\"type\":\"3\"},\"1608\":{\"name\":\"调味料\",\"select\":\"0\",\"type\":\"3\"},\"1611\":{\"name\":\"鱿鱼\",\"select\":\"0\",\"type\":\"3\"},\"1613\":{\"name\":\"话梅\",\"select\":\"0\",\"type\":\"3\"},\"1615\":{\"name\":\"受过污染的纸\",\"select\":\"0\",\"type\":\"4\"},\"1616\":{\"name\":\"槟榔\",\"select\":\"0\",\"type\":\"3\"},\"1617\":{\"name\":\"花甲\",\"select\":\"0\",\"type\":\"4\"},\"1618\":{\"name\":\"电费账单\",\"select\":\"0\",\"type\":\"1\"},\"1619\":{\"name\":\"封箱带\",\"select\":\"0\",\"type\":\"4\"},\"1625\":{\"name\":\"扫把\",\"select\":\"0\",\"type\":\"4\"},\"1626\":{\"name\":\"葡萄籽\",\"select\":\"0\",\"type\":\"3\"},\"1628\":{\"name\":\"润唇膏\",\"select\":\"0\",\"type\":\"4\"},\"1629\":{\"name\":\"鸡胸\",\"select\":\"0\",\"type\":\"3\"},\"1636\":{\"name\":\"包装纸盒\",\"select\":\"0\",\"type\":\"1\"},\"1637\":{\"name\":\"玻璃灯罩\",\"select\":\"0\",\"type\":\"1\"},\"1640\":{\"name\":\"虎牙\",\"select\":\"0\",\"type\":\"4\"},\"1641\":{\"name\":\"花瓣\",\"select\":\"0\",\"type\":\"3\"},\"1644\":{\"name\":\"打包袋\",\"select\":\"0\",\"type\":\"4\"},\"1649\":{\"name\":\"订书机\",\"select\":\"0\",\"type\":\"1\"},\"1650\":{\"name\":\"布偶\",\"select\":\"0\",\"type\":\"1\"},\"1655\":{\"name\":\"笔杆\",\"select\":\"0\",\"type\":\"4\"},\"1657\":{\"name\":\"牛蛙\",\"select\":\"0\",\"type\":\"3\"},\"1659\":{\"name\":\"过期口红\",\"select\":\"0\",\"type\":\"4\"},\"1660\":{\"name\":\"除草剂罐\",\"select\":\"0\",\"type\":\"2\"},\"1661\":{\"name\":\"速冻饺子包装\",\"select\":\"0\",\"type\":\"4\"},\"1662\":{\"name\":\"杏仁\",\"select\":\"0\",\"type\":\"3\"},\"1667\":{\"name\":\"遥控器\",\"select\":\"0\",\"type\":\"5\"},\"1669\":{\"name\":\"电影胶片\",\"select\":\"0\",\"type\":\"2\"},\"1670\":{\"name\":\"臭鸡蛋\",\"select\":\"0\",\"type\":\"3\"},\"1672\":{\"name\":\"金属元件\",\"select\":\"0\",\"type\":\"1\"},\"1673\":{\"name\":\"插头\",\"select\":\"0\",\"type\":\"1\"},\"1676\":{\"name\":\"包包\",\"select\":\"0\",\"type\":\"1\"},\"1678\":{\"name\":\"便利贴\",\"select\":\"0\",\"type\":\"4\"},\"1679\":{\"name\":\"木炭\",\"select\":\"0\",\"type\":\"4\"},\"1680\":{\"name\":\"芭蕉叶\",\"select\":\"0\",\"type\":\"3\"},\"1681\":{\"name\":\"樱花\",\"select\":\"0\",\"type\":\"3\"},\"1683\":{\"name\":\"腌笃鲜\",\"select\":\"0\",\"type\":\"3\"},\"1684\":{\"name\":\"被芯\",\"select\":\"0\",\"type\":\"1\"},\"1692\":{\"name\":\"充电线\",\"select\":\"0\",\"type\":\"1\"},\"1699\":{\"name\":\"钓鱼竿\",\"select\":\"0\",\"type\":\"4\"},\"1700\":{\"name\":\"领带\",\"select\":\"0\",\"type\":\"1\"},\"1702\":{\"name\":\"*屏蔽的关键字*\",\"select\":\"0\",\"type\":\"2\"},\"1703\":{\"name\":\"三杯鸡\",\"select\":\"0\",\"type\":\"3\"},\"1705\":{\"name\":\"弹簧\",\"select\":\"0\",\"type\":\"1\"},\"1706\":{\"name\":\"卷笔刀\",\"select\":\"0\",\"type\":\"4\"},\"1707\":{\"name\":\"插座\",\"select\":\"0\",\"type\":\"1\"},\"1708\":{\"name\":\"炒面\",\"select\":\"0\",\"type\":\"3\"},\"1710\":{\"name\":\"荔枝核\",\"select\":\"0\",\"type\":\"3\"},\"1716\":{\"name\":\"蟑螂丸\",\"select\":\"0\",\"type\":\"2\"},\"1717\":{\"name\":\"麻将牌\",\"select\":\"0\",\"type\":\"4\"},\"1720\":{\"name\":\"过期猫粮\",\"select\":\"0\",\"type\":\"3\"},\"1722\":{\"name\":\"担担面\",\"select\":\"0\",\"type\":\"3\"},\"1723\":{\"name\":\"荔枝干壳\",\"select\":\"0\",\"type\":\"3\"},\"1724\":{\"name\":\"手抄报\",\"select\":\"0\",\"type\":\"4\"},\"1725\":{\"name\":\"订书钉\",\"select\":\"0\",\"type\":\"4\"},\"1726\":{\"name\":\"订书针\",\"select\":\"0\",\"type\":\"4\"},\"1727\":{\"name\":\"干辣椒\",\"select\":\"0\",\"type\":\"3\"},\"1731\":{\"name\":\"花卉\",\"select\":\"0\",\"type\":\"3\"},\"1733\":{\"name\":\"棉袄\",\"select\":\"0\",\"type\":\"1\"},\"1738\":{\"name\":\"纽扣电池\",\"select\":\"0\",\"type\":\"2\"},\"1741\":{\"name\":\"富贵竹\",\"select\":\"0\",\"type\":\"3\"},\"1742\":{\"name\":\"速冻饺子\",\"select\":\"0\",\"type\":\"3\"},\"1753\":{\"name\":\"榛子壳\",\"select\":\"0\",\"type\":\"4\"},\"1754\":{\"name\":\"加湿器\",\"select\":\"0\",\"type\":\"5\"},\"1769\":{\"name\":\"螺蛳粉\",\"select\":\"0\",\"type\":\"3\"},\"1771\":{\"name\":\"肥料\",\"select\":\"0\",\"type\":\"4\"},\"1772\":{\"name\":\"海洋球\",\"select\":\"0\",\"type\":\"1\"},\"1773\":{\"name\":\"复写纸\",\"select\":\"0\",\"type\":\"4\"},\"1775\":{\"name\":\"菠萝派\",\"select\":\"0\",\"type\":\"3\"},\"1777\":{\"name\":\"玻璃盘\",\"select\":\"0\",\"type\":\"1\"},\"1780\":{\"name\":\"毛豆结\",\"select\":\"0\",\"type\":\"3\"},\"1785\":{\"name\":\"文胸\",\"select\":\"0\",\"type\":\"4\"},\"1786\":{\"name\":\"三文鱼\",\"select\":\"0\",\"type\":\"3\"},\"1789\":{\"name\":\"燕尾夹\",\"select\":\"0\",\"type\":\"1\"},\"1790\":{\"name\":\"锅巴\",\"select\":\"0\",\"type\":\"3\"},\"1792\":{\"name\":\"白纸\",\"select\":\"0\",\"type\":\"1\"},\"1793\":{\"name\":\"芹菜叶\",\"select\":\"0\",\"type\":\"3\"},\"1794\":{\"name\":\"烂香蕉\",\"select\":\"0\",\"type\":\"3\"},\"1798\":{\"name\":\"瓷片\",\"select\":\"0\",\"type\":\"4\"},\"1803\":{\"name\":\"家禽内脏\",\"select\":\"0\",\"type\":\"3\"},\"1805\":{\"name\":\"寿司\",\"select\":\"0\",\"type\":\"3\"},\"1811\":{\"name\":\"鸡屁股\",\"select\":\"0\",\"type\":\"3\"},\"1820\":{\"name\":\"生蚝\",\"select\":\"0\",\"type\":\"4\"},\"1822\":{\"name\":\"宣传单\",\"select\":\"0\",\"type\":\"1\"},\"1823\":{\"name\":\"包装袋\",\"select\":\"0\",\"type\":\"4\"},\"1827\":{\"name\":\"鱼鳞鱼肠\",\"select\":\"0\",\"type\":\"3\"},\"1828\":{\"name\":\"茴香\",\"select\":\"0\",\"type\":\"3\"},\"1829\":{\"name\":\"羽毛\",\"select\":\"0\",\"type\":\"4\"},\"1831\":{\"name\":\"机械表\",\"select\":\"0\",\"type\":\"1\"},\"1832\":{\"name\":\"钥匙\",\"select\":\"0\",\"type\":\"1\"},\"1833\":{\"name\":\"玻璃杯\",\"select\":\"0\",\"type\":\"1\"},\"1834\":{\"name\":\"高粱\",\"select\":\"0\",\"type\":\"3\"},\"1835\":{\"name\":\"芒果核\",\"select\":\"0\",\"type\":\"3\"},\"1840\":{\"name\":\"干香菇\",\"select\":\"0\",\"type\":\"3\"},\"1842\":{\"name\":\"枸杞\",\"select\":\"0\",\"type\":\"3\"},\"1843\":{\"name\":\"牛奶瓶吸管\",\"select\":\"0\",\"type\":\"4\"},\"1845\":{\"name\":\"焊丝\",\"select\":\"0\",\"type\":\"1\"},\"1848\":{\"name\":\"梨核\",\"select\":\"0\",\"type\":\"3\"},\"1849\":{\"name\":\"笔芯\",\"select\":\"0\",\"type\":\"4\"},\"1850\":{\"name\":\"杂志\",\"select\":\"0\",\"type\":\"1\"},\"1853\":{\"name\":\"快餐盒\",\"select\":\"0\",\"type\":\"4\"},\"1854\":{\"name\":\"点钞机\",\"select\":\"0\",\"type\":\"5\"},\"1855\":{\"name\":\"蛏子壳\",\"select\":\"0\",\"type\":\"4\"},\"1858\":{\"name\":\"棒棒糖\",\"select\":\"0\",\"type\":\"3\"},\"1860\":{\"name\":\"大米\",\"select\":\"0\",\"type\":\"3\"},\"1863\":{\"name\":\"冰柜\",\"select\":\"0\",\"type\":\"5\"},\"1865\":{\"name\":\"虫子\",\"select\":\"0\",\"type\":\"3\"},\"1869\":{\"name\":\"馄饨\",\"select\":\"0\",\"type\":\"3\"},\"1872\":{\"name\":\"蜡烛\",\"select\":\"0\",\"type\":\"4\"},\"1874\":{\"name\":\"河豚\",\"select\":\"0\",\"type\":\"3\"},\"1875\":{\"name\":\"饼干\",\"select\":\"0\",\"type\":\"3\"},\"1876\":{\"name\":\"捕蚊灯\",\"select\":\"0\",\"type\":\"5\"},\"1878\":{\"name\":\"蛋挞壳\",\"select\":\"0\",\"type\":\"4\"},\"1879\":{\"name\":\"唇膏\",\"select\":\"0\",\"type\":\"4\"},\"1881\":{\"name\":\"金属衣架\",\"select\":\"0\",\"type\":\"1\"},\"1882\":{\"name\":\"金属制菜篮子\",\"select\":\"0\",\"type\":\"1\"},\"1883\":{\"name\":\"隐形眼镜\",\"select\":\"0\",\"type\":\"4\"},\"1889\":{\"name\":\"脆骨\",\"select\":\"0\",\"type\":\"3\"},\"1890\":{\"name\":\"蜜饯\",\"select\":\"0\",\"type\":\"3\"},\"1892\":{\"name\":\"菠萝蜜核\",\"select\":\"0\",\"type\":\"4\"},\"1893\":{\"name\":\"猫饲料\",\"select\":\"0\",\"type\":\"3\"},\"1896\":{\"name\":\"根茎蔬菜\",\"select\":\"0\",\"type\":\"3\"},\"1897\":{\"name\":\"鸭脖\",\"select\":\"0\",\"type\":\"3\"},\"1902\":{\"name\":\"注射器\",\"select\":\"0\",\"type\":\"4\"},\"1906\":{\"name\":\"螺帽\",\"select\":\"0\",\"type\":\"1\"},\"1908\":{\"name\":\"数据线\",\"select\":\"0\",\"type\":\"1\"},\"1911\":{\"name\":\"太阳帽\",\"select\":\"0\",\"type\":\"1\"},\"1912\":{\"name\":\"美术黏土\",\"select\":\"0\",\"type\":\"4\"},\"1913\":{\"name\":\"过期糕点\",\"select\":\"0\",\"type\":\"3\"},\"1915\":{\"name\":\"牛蛙骨头\",\"select\":\"0\",\"type\":\"3\"},\"1916\":{\"name\":\"可口可乐纸杯\",\"select\":\"0\",\"type\":\"4\"},\"1918\":{\"name\":\"含汞体温计\",\"select\":\"0\",\"type\":\"2\"},\"1920\":{\"name\":\"哈密瓜皮\",\"select\":\"0\",\"type\":\"3\"},\"1925\":{\"name\":\"熟鸡蛋壳\",\"select\":\"0\",\"type\":\"3\"},\"1926\":{\"name\":\"腰果\",\"select\":\"0\",\"type\":\"3\"},\"1931\":{\"name\":\"番茄酱\",\"select\":\"0\",\"type\":\"3\"},\"1933\":{\"name\":\"耳机\",\"select\":\"0\",\"type\":\"5\"},\"1934\":{\"name\":\"葡萄\",\"select\":\"0\",\"type\":\"3\"},\"1935\":{\"name\":\"可擦复写笔\",\"select\":\"0\",\"type\":\"4\"},\"1937\":{\"name\":\"麻袋\",\"select\":\"0\",\"type\":\"4\"}}";
}

@end
