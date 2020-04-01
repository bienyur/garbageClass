//
//  QDCollectionDemoViewController.h
//  qmuidemo
//
//  Created by QMUI Team on 16/9/8.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QDCommonViewController.h"

@interface QDCollectionDemoViewController : QDCommonViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong, readonly) UICollectionView *collectionView;
@property(nonatomic, strong, readonly) QMUICollectionViewPagingLayout *collectionViewLayout;
@property(nonatomic, strong) NSMutableArray *dataAry;
@property(nonatomic, strong) NSString *answerType; // 考试类型 刷题1 k模拟考试2
- (instancetype)initWithLayoutStyle:(QMUICollectionViewPagingLayoutStyle)style;
@end
