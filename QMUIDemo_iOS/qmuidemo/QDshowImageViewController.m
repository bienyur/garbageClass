//
//  QDImageViewController.m
//  qmuidemo
//
//  Created by bieny on 2019/8/3.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "QDshowImageViewController.h"

@interface QDshowImageViewController ()
@property (strong, nonatomic) UIButton *backBtn;
@end

#define appWidth  [UIScreen mainScreen].bounds.size.width
//屏幕能显示的区域高度 考虑到了热点状态栏的情况
#define appHeight  [UIScreen mainScreen].bounds.size.height
@implementation QDshowImageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.bgImageName]];
    image.frame = CGRectMake(0, 0, appWidth, appHeight);
    [self.view addSubview:image];
    
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 60, 40)];
    [self.backBtn setTitle:@"<back" forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    // Do any additional setup after loading the view.
}
- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
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
