//
//  QDNewsCollectionListViewController.m
//  qmuidemo
//
//  Created by QMUI Team on 15/9/24.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import "QDNewsCollectionListViewController.h"
#import "QDCollectionDemoViewController.h"
#import "QDCollectionStackDemoViewController.h"
#import "QDshowImageViewController.h"

@interface QDNewsCollectionListViewController ()

@end

@implementation QDNewsCollectionListViewController

- (void)initDataSource {
    [super initDataSource];
    self.dataSource = @[@"干垃圾如何区分?",
                        @"湿垃圾如何区分?",
                        @"有害垃圾如何区分?",
                        @"可回收物如何区分?"];
}

- (void)didSelectCellWithTitle:(NSString *)title {
    QDCollectionDemoViewController *viewController;
    QDshowImageViewController *imagevc = [[QDshowImageViewController alloc] init];
    if ([title isEqualToString:@"干垃圾如何区分?"]) {
        imagevc.bgImageName = @"干垃圾";
    }
    if ([title isEqualToString:@"湿垃圾如何区分?"]) {
        imagevc.bgImageName = @"湿垃圾";
    }
    if ([title isEqualToString:@"有害垃圾如何区分?"]) {
        imagevc.bgImageName = @"有害垃圾";
    }
    if ([title isEqualToString:@"可回收物如何区分?"]) {
        imagevc.bgImageName = @"可回收物";
    }
    // TODO
//    else if ([title isEqualToString:@"叠加"]) {
//        viewController = [[QDCollectionStackDemoViewController alloc] init];
//    }
    viewController.title = title;
    imagevc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:imagevc animated:YES];
}
@end
