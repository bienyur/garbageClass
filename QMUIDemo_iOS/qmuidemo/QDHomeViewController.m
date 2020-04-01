//
//  QDHomeViewController.m
//  qmuidemo
//
//  Created by bieny on 2019/8/3.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "QDHomeViewController.h"
#import "QDSearchViewController.h"
#import "SpeechViewController.h"
#import "QDCollectionListViewController.h"

@interface QDHomeViewController ()
@property (strong, nonatomic) QMUILabel *searchSpeechLabel;
@property (strong, nonatomic) QMUILabel *searchTextLabel;
@property (strong, nonatomic) QMUILabel *answerTextLabel;
@end
#define appWidth  [UIScreen mainScreen].bounds.size.width
//屏幕能显示的区域高度 考虑到了热点状态栏的情况
#define appHeight  [UIScreen mainScreen].bounds.size.height

@implementation QDHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-2688h"]];
    image.frame = CGRectMake(0, 0, appWidth, appHeight);
    [self.view addSubview:image];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:YES];
    _searchSpeechLabel = [[QMUILabel alloc] init];
    self.searchSpeechLabel.text = @"语音搜索";
    self.searchSpeechLabel.font = UIFontMake(50);
    self.searchSpeechLabel.textColor = UIColorWhite;
    self.searchSpeechLabel.canPerformCopyAction = YES;
    self.searchSpeechLabel.textAlignment = 1;
    [self.searchSpeechLabel sizeToFit];
    self.searchSpeechLabel.frame = CGRectMake(0, appHeight/2-200, appWidth, 100);
    self.searchSpeechLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *speechLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(speechLabelTouchUpInside:)];
    [self.searchSpeechLabel addGestureRecognizer:speechLabelTapGestureRecognizer];
    [self.view addSubview:self.searchSpeechLabel];
    
    
    _searchTextLabel = [[QMUILabel alloc] init];
    self.searchTextLabel.text = @"文字搜索";
    self.searchTextLabel.font = UIFontMake(50);
    self.searchTextLabel.textColor = UIColorWhite;
    self.searchTextLabel.canPerformCopyAction = YES;
    self.searchTextLabel.textAlignment = 1;
    [self.searchTextLabel sizeToFit];
    self.searchTextLabel.frame = CGRectMake(0, CGRectGetMaxY(self.searchSpeechLabel.frame)+20, appWidth, 100);
    self.searchTextLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self.searchTextLabel addGestureRecognizer:labelTapGestureRecognizer];
    [self.view addSubview:self.searchTextLabel];
    
    _answerTextLabel = [[QMUILabel alloc] init];
    self.answerTextLabel.text = @"刷题练习";
    self.answerTextLabel.font = UIFontMake(50);
    self.answerTextLabel.textColor = UIColorWhite;
    self.answerTextLabel.canPerformCopyAction = YES;
    self.answerTextLabel.textAlignment = 1;
    [self.answerTextLabel sizeToFit];
    self.answerTextLabel.frame = CGRectMake(0, CGRectGetMaxY(self.searchTextLabel.frame)+20, appWidth, 100);
    self.answerTextLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *answerLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(answerLabelTouchUpInside:)];
    [self.answerTextLabel addGestureRecognizer:answerLabelTapGestureRecognizer];
    [self.view addSubview:self.answerTextLabel];
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:YES];
}

-(void) speechLabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    SpeechViewController *speechVC = [[SpeechViewController alloc] init];
    speechVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:speechVC animated:YES];

}

-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    
    QDSearchViewController *searchViewController = [[QDSearchViewController alloc] init];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
-(void) answerLabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    
    QDCollectionListViewController *viewController = [[QDCollectionListViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
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
