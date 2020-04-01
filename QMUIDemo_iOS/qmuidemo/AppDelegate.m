//
//  AppDelegate.m
//  qmuidemo
//
//  Created by QMUI Team on 15/4/13.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "AppDelegate.h"
#import "QDUIHelper.h"
#import "QDCommonUI.h"
#import "QDTabBarViewController.h"
#import "QDNavigationController.h"
#import "QDUIKitViewController.h"
#import "QDComponentsViewController.h"
#import "QDLabViewController.h"
#import "QDSearchViewController.h"
#import "QDCollectionListViewController.h"
#import "QDAnswerViewController.h"
#import "UMMobClick/MobClick.h"
#import "SpeechViewController.h"
#import "QDHomeViewController.h"
#import "QDNewsCollectionListViewController.h"
// 通用型设置数据
#define kSetUserDefaults(key, value)  ([USER_DEFAULT setObject:value forKey:key], [USER_DEFAULT synchronize])
// 通用型获取数据
#define kUserDefaults(key) [USER_DEFAULT objectForKey:key]

#define USER_DEFAULT  [NSUserDefaults standardUserDefaults]


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // QMUIConsole 默认只在 DEBUG 下会显示，作为 Demo，改为不管什么环境都允许显示
    [QMUIConsole sharedInstance].canShow = YES;
    
    // QD自定义的全局样式渲染
    [QDCommonUI renderGlobalAppearances];
    
    // 预加载 QQ 表情，避免第一次使用时卡顿
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [QDUIHelper qmuiEmotions];
    });
    
    // 界面
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self createTabBarController];
    
    // 启动动画
    [self startLaunchingAnimation];
    [MobClick setCrashReportEnabled:YES];
    //    [MobClick startWithAppkey:key reportPolicy:(ReportPolicy) BATCH channelId:channel];
    UMConfigInstance.appKey = @"5d22019a4ca357276800039c";
    UMConfigInstance.channelId = @"iOS";
    UMConfigInstance.ePolicy = BATCH;
    [MobClick startWithConfigure:UMConfigInstance];
    
    [MobClick setLogEnabled:YES];
    
    NSString *fastOpen =  kUserDefaults(@"fastOpen");
    if (!fastOpen) {
        [self showAppearanceDialogViewController:@"小提醒" text:@"此app只做参考，具体以当地专业部门为准" type:0];
        kSetUserDefaults(@"fastOpen", @"1");
    }
    
    return YES;
}

- (void)createTabBarController {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    
    // QMUIKit
    QDUIKitViewController *uikitViewController = [[QDUIKitViewController alloc] init];
    uikitViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *uikitNavController = [[QDNavigationController alloc] initWithRootViewController:uikitViewController];
    uikitNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"QMUIKit" image:[UIImageMake(@"icon_tabbar_uikit") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_uikit_selected") tag:0];
    AddAccessibilityHint(uikitNavController.tabBarItem, @"展示一系列对系统原生控件的拓展的能力");
    
    // UIComponents
    QDComponentsViewController *componentViewController = [[QDComponentsViewController alloc] init];
    componentViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:componentViewController];
    componentNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"Components" image:[UIImageMake(@"icon_tabbar_uikit") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_uikit_selected") tag:2];
    AddAccessibilityHint(componentNavController.tabBarItem, @"展示 QMUI 自己的组件库");
    
    // Lab
    QDLabViewController *labViewController = [[QDLabViewController alloc] init];
    labViewController.hidesBottomBarWhenPushed = NO;
    QDNavigationController *labNavController = [[QDNavigationController alloc] initWithRootViewController:labViewController];
    labNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"设置" image:[UIImageMake(@"icon_tabbar_lab") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_lab_selected") tag:3];
    AddAccessibilityHint(labNavController.tabBarItem, @"集合一些非正式但可能很有用的小功能");
    
//    QDSearchViewController *searchViewController = [[QDSearchViewController alloc] init];
//    searchViewController.hidesBottomBarWhenPushed = NO;
//    QDNavigationController *searchNavController = [[QDNavigationController alloc] initWithRootViewController:searchViewController];
    
//    searchNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"搜索" image:[UIImageMake(@"icon_tabbar_component") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_component_selected") tag:1];
//    AddAccessibilityHint(searchNavController.tabBarItem, @"展示 QMUI 自己的组件库");
  
    QDNewsCollectionListViewController *newsvc =  [[QDNewsCollectionListViewController alloc] init];
    UINavigationController *navnews = [[UINavigationController alloc] initWithRootViewController:newsvc];
    
    
//    QDCollectionListViewController *viewController = [[QDCollectionListViewController alloc] init];
//
//    QDAnswerViewController *answerNav = [[QDAnswerViewController alloc] initWithRootViewController:viewController];
    navnews.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"分类技巧" image:[UIImageMake(@"icon_tabbar_uikit") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_uikit_selected") tag:1];
    newsvc.hidesBottomBarWhenPushed = NO;
    
    
    QDHomeViewController *homevc = [[QDHomeViewController alloc] init];
    UINavigationController *navhome = [[UINavigationController alloc] initWithRootViewController:homevc];
    navhome.hidesBottomBarWhenPushed = NO;
    navhome.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"搜索" image:[UIImageMake(@"icon_tabbar_component") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_component_selected") tag:1];
    AddAccessibilityHint(navhome.tabBarItem, @"首页");
    
    
    
    
    tabBarViewController.viewControllers = @[navhome,navnews,labNavController];
    self.window.rootViewController = tabBarViewController;
    [self.window makeKeyAndVisible];
}

- (void)startLaunchingAnimation {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *launchScreenView = [[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil].firstObject;
    launchScreenView.frame = window.bounds;
    [window addSubview:launchScreenView];
    
    UIImageView *backgroundImageView = launchScreenView.subviews[0];
    backgroundImageView.clipsToBounds = YES;
    
    UIImageView *logoImageView = launchScreenView.subviews[1];
    UILabel *copyrightLabel = launchScreenView.subviews.lastObject;
    
    UIView *maskView = [[UIView alloc] initWithFrame:launchScreenView.bounds];
    maskView.backgroundColor = UIColorWhite;
    [launchScreenView insertSubview:maskView belowSubview:backgroundImageView];
    
    [launchScreenView layoutIfNeeded];
    
    
    [launchScreenView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:@"bottomAlign"]) {
            obj.active = NO;
            [NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:launchScreenView attribute:NSLayoutAttributeTop multiplier:1 constant:NavigationContentTop].active = YES;
            *stop = YES;
        }
    }];
    
    [UIView animateWithDuration:.15 delay:0.9 options:QMUIViewAnimationOptionsCurveOut animations:^{
        [launchScreenView layoutIfNeeded];
        logoImageView.alpha = 0.0;
        copyrightLabel.alpha = 0;
    } completion:nil];
    [UIView animateWithDuration:1.2 delay:0.9 options:UIViewAnimationOptionCurveEaseOut animations:^{
        maskView.alpha = 0;
        backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [launchScreenView removeFromSuperview];
    }];
}


- (void)showAppearanceDialogViewController:(NSString *)title text:(NSString *)text type:(int)type{
    
    QMUIDialogViewController *dialogViewController = [[QMUIDialogViewController alloc] init];
    dialogViewController.title = title;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    contentView.backgroundColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    UILabel *label = [[UILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorWhite];
    label.text = text;
    [label sizeToFit];
    label.center = CGPointMake(CGRectGetWidth(contentView.bounds) / 2.0, CGRectGetHeight(contentView.bounds) / 2.0);
    [contentView addSubview:label];
    dialogViewController.contentView = contentView;
    
    [dialogViewController addCancelButtonWithText:@"已阅" block:nil];

    
    // 自定义样式
    dialogViewController.headerViewBackgroundColor = [QDThemeManager sharedInstance].currentTheme.themeTintColor;
    dialogViewController.headerSeparatorColor = nil;
    dialogViewController.footerSeparatorColor = nil;
    dialogViewController.titleTintColor = UIColorWhite;
    dialogViewController.titleView.horizontalTitleFont = UIFontBoldMake(17);
    dialogViewController.buttonHighlightedBackgroundColor = [dialogViewController.headerViewBackgroundColor qmui_colorWithAlphaAddedToWhite:.3];
    NSMutableDictionary *buttonTitleAttributes = dialogViewController.buttonTitleAttributes.mutableCopy;
    buttonTitleAttributes[NSForegroundColorAttributeName] = dialogViewController.headerViewBackgroundColor;
    dialogViewController.buttonTitleAttributes = buttonTitleAttributes;
    //    [dialogViewController.submitButton setImage:[[UIImageMake(@"icon_emotion") qmui_imageResizedInLimitedSize:CGSizeMake(18, 18) resizingMode:QMUIImageResizingModeScaleToFill] qmui_imageWithTintColor:buttonTitleAttributes[NSForegroundColorAttributeName]] forState:UIControlStateNormal];
    //    dialogViewController.submitButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    
    [dialogViewController show];
}

@end
