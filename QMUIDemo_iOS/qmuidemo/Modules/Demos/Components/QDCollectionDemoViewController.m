//
//  QDCollectionDemoViewController.m
//  qmuidemo
//
//  Created by QMUI Team on 16/9/8.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QDCollectionDemoViewController.h"
#import "QDCollectionViewDemoCell.h"

@implementation QDCollectionDemoViewController

- (instancetype)initWithLayoutStyle:(QMUICollectionViewPagingLayoutStyle)style {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _collectionViewLayout = [[QMUICollectionViewPagingLayout alloc] initWithStyle:style];
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithLayoutStyle:QMUICollectionViewPagingLayoutStyleDefault];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.titleView.userInteractionEnabled = YES;
    [self.titleView addTarget:self action:@selector(handleTitleViewTouchEvent) forControlEvents:UIControlEventTouchUpInside];
    if ([self.answerType isEqualToString:@"2"]) {
        self.navigationItem.rightBarButtonItems = @[[UIBarButtonItem qmui_itemWithTitle:@"交卷" target:self action:@selector(submit)]];
    }
    
//    self.navigationItem.rightBarButtonItems = @[[UIBarButtonItem qmui_itemWithTitle:self.collectionViewLayout.debug ? @"普通模式" : @"调试模式" target:self action:@selector(handleDebugItemEvent)],
//                                                [UIBarButtonItem qmui_itemWithTitle:self.collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical ? @"水平" : @"垂直" target:self action:@selector(handleDirectionItemEvent)]];
}

-(void)submit{
    int correctCount = 0;
    int errorCount = 0;
    int notSelectCount = 0;
    for (int i = 0; i < self.dataAry.count; i++) {
        if([self.dataAry[i][@"select"] isEqualToString:self.dataAry[i][@"type"] ]){
            correctCount+=1;
        }else if([self.dataAry[i][@"select"] isEqualToString:@"0"]) {
            notSelectCount+=1;
        }else{
            errorCount+=1;
        }
    }
    
    [self showAppearanceDialogViewController:@"成绩" text:[NSString stringWithFormat:@"得分:%d   正确:%d   错误:%d  未选题：%d",correctCount*2,correctCount,errorCount,notSelectCount] type:0];
    
    NSLog(@"得分:%d   正确:%d   错误:%d  其中未选择的有：%d",correctCount*2,correctCount,errorCount,notSelectCount);
}

- (void)initSubviews {
    [super initSubviews];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewLayout];
    self.collectionView.backgroundColor = UIColorClear;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[QDCollectionViewDemoCell class] forCellWithReuseIdentifier:@"cell"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAryRefresh:) name:@"kDATAARYUPDATE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextItem:) name:@"kNEXTITEM" object:nil];
    [self.view addSubview:self.collectionView];
    
    self.collectionViewLayout.sectionInset = [self sectionInset];
}

- (void)dataAryRefresh:(NSNotification *) notification{
    NSDictionary * infoDic = [notification object];
    NSInteger contentNumber = [infoDic[@"contentNumber"] intValue];
    [(NSMutableDictionary *)self.dataAry[contentNumber] setValue:[NSString stringWithFormat:@"%@",infoDic[@"selectNumber"]] forKey:@"select"];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGSizeEqualToSize(self.collectionView.bounds.size, self.view.bounds.size)) {
        self.collectionView.frame = self.view.bounds;
        self.collectionViewLayout.sectionInset = [self sectionInset];
        [self.collectionViewLayout invalidateLayout];
    }
}

- (void)handleTitleViewTouchEvent {
    [self.collectionView qmui_scrollToTopAnimated:YES];
}

- (void)handleDirectionItemEvent {
    self.collectionViewLayout.scrollDirection = self.collectionViewLayout.scrollDirection == UICollectionViewScrollDirectionVertical ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
    [self.collectionViewLayout invalidateLayout];
    [self.collectionView qmui_scrollToTopAnimated:YES];
    [self.collectionView reloadData];
    
    [self setupNavigationItems];
    [self.view setNeedsLayout];
}

- (void)handleDebugItemEvent {
    self.collectionViewLayout.debug = !self.collectionViewLayout.debug;
    self.collectionViewLayout.sectionInset = [self sectionInset];
    [self.collectionViewLayout invalidateLayout];
    [self.collectionView qmui_scrollToTopAnimated:YES];
    [self.collectionView reloadData];
    
    [self setupNavigationItems];
}

- (UIEdgeInsets)sectionInset {
    if (self.collectionViewLayout.debug) {
        CGSize itemSize = CGSizeMake(100, 100);
        CGFloat horizontalInset = (CGRectGetWidth(self.collectionView.bounds) - UIEdgeInsetsGetHorizontalValue(self.collectionView.qmui_contentInset) - itemSize.width) / 2;
        CGFloat verticalInset = (CGRectGetHeight(self.collectionView.bounds) - UIEdgeInsetsGetVerticalValue(self.collectionView.qmui_contentInset) - itemSize.height) / 2;
        return UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, CGRectGetWidth(self.collectionView.bounds) - horizontalInset - itemSize.width - UIEdgeInsetsGetHorizontalValue(self.collectionView.qmui_contentInset));
    } else {
        return UIEdgeInsetsMake(36, 36, 36, 36);
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.answerType isEqualToString:@"2"]) {
        return 50;
    }
    return 500;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QDCollectionViewDemoCell *cell = (QDCollectionViewDemoCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.debug = self.collectionViewLayout.debug;
    cell.pagingThreshold = self.collectionViewLayout.pagingThreshold;
    cell.scrollDirection = self.collectionViewLayout.scrollDirection;
    cell.contentLabel.tag = indexPath.row;
    cell.garbageType = self.dataAry[indexPath.row][@"type"];
    cell.answerType = self.answerType;
    if([self.dataAry[indexPath.row][@"select"] isEqualToString:@"0"]){
        cell.selectNumberStr = @"0";
    }else{
        cell.selectNumberStr = self.dataAry[indexPath.row][@"select"];
    }
    cell.contentLabel.text =[NSString stringWithFormat:@"第 %@ 题",[NSString qmui_stringWithNSInteger:(indexPath.item+1)]];
    cell.topicLabel.text =self.dataAry[indexPath.row][@"name"];
    cell.topicLabel.font = [UIFont qmui_lightSystemFontOfSize:60];
    cell.backgroundColor = [QDCommonUI randomThemeColor];
    [cell setNeedsLayout];
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionViewLayout.debug) {
        return CGSizeMake(100, 100);
    }
    
    CGSize size = CGSizeMake(CGRectGetWidth(collectionView.bounds) - UIEdgeInsetsGetHorizontalValue(self.collectionViewLayout.sectionInset) - UIEdgeInsetsGetHorizontalValue(self.collectionView.qmui_contentInset), CGRectGetHeight(collectionView.bounds) - UIEdgeInsetsGetVerticalValue(self.collectionViewLayout.sectionInset) - UIEdgeInsetsGetVerticalValue(self.collectionView.qmui_contentInset));
    return size;
}

- (void)nextItem:(NSNotification *)notification{
    NSLog(@"1");
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
    
    [dialogViewController addCancelButtonWithText:@"继续答题" block:nil];
    [dialogViewController addSubmitButtonWithText:@"退出考试" block:^(QMUIDialogViewController *aDialogViewController) {
        [aDialogViewController hide];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
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

- (void)dealloc {
    //单条移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kDATAARYUPDATE" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNEXTITEM" object:nil];
    //移除所有观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
