//
//  QDCollectionViewDemoCell.h
//  qmuidemo
//
//  Created by QMUI Team on 15/9/24.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDCollectionViewDemoCell : UICollectionViewCell

@property(nonatomic, strong, readonly) UILabel *contentLabel; // 第几题
@property(nonatomic, strong, readonly) UILabel *topicLabel; //题目
@property(nonatomic, assign) BOOL debug;
@property(nonatomic, assign) CGFloat pagingThreshold;
@property(nonatomic, strong) NSString *selectNumberStr;
@property(nonatomic, assign) NSString *garbageType; // 垃圾类型  正确答案
@property(nonatomic, strong) NSString *answerType; // 答题类型 刷题或者模拟考试
@property(nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@end
