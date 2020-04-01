//
//  QDCollectionViewDemoCell.m
//  qmuidemo
//
//  Created by QMUI Team on 15/9/24.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import "QDCollectionViewDemoCell.h"
#import "QDCommonUI.h"
@interface QDCollectionViewDemoCell ()

@property(nonatomic, strong) CALayer *prevLayer;
@property(nonatomic, strong) CALayer *nextLayer;
@property(nonatomic, strong) QMUIGhostButton *ghostButton1;
@property(nonatomic, strong) QMUIGhostButton *ghostButton2;
@property(nonatomic, strong) QMUIGhostButton *ghostButton3;
@property(nonatomic, strong) QMUIGhostButton *ghostButton4;
@property(nonatomic, strong) CALayer *separatorLayer1;
@property(nonatomic, strong) CALayer *separatorLayer2;
@property(nonatomic, strong) CALayer *separatorLayer3;
@property(nonatomic, strong) CALayer *separatorLayer4;
@property(nonatomic, strong) UIImageView *selectImage1;
@property(nonatomic, strong) UIImageView *selectImage2;
@property(nonatomic, strong) UIImageView *selectImage3;
@property(nonatomic, strong) UIImageView *selectImage4;

@property(nonatomic, strong) QMUIGhostButton *prevAnswer;
@property(nonatomic, strong) QMUIGhostButton *nextAnswer;
// 是否已选择过了
@property(nonatomic, assign) BOOL isSelect;

@end

@implementation QDCollectionViewDemoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 3;
        
        _contentLabel = [[UILabel alloc] qmui_initWithFont:UIFontLightMake(40) textColor:UIColorWhite];
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.contentLabel];
        
        _topicLabel = [[UILabel alloc] qmui_initWithFont:UIFontLightMake(80) textColor:UIColorWhite];
        self.topicLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.topicLabel];
        
        self.ghostButton1 = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorWhite];
        self.ghostButton1.titleLabel.font = UIFontMake(20);
        [self.ghostButton1 setTitle:@"可回收垃圾" forState:UIControlStateNormal];
        self.ghostButton1.tag = 1;
        [self.contentView addSubview:self.ghostButton1];
        
        self.ghostButton2 = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorWhite];
        self.ghostButton2.titleLabel.font = UIFontMake(20);
        [self.ghostButton2 setTitle:@"有害垃圾" forState:UIControlStateNormal];
        self.ghostButton2.tag = 2;
        [self.contentView addSubview:self.ghostButton2];
        
        self.ghostButton3 = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorWhite];
        self.ghostButton3.titleLabel.font = UIFontMake(20);
        [self.ghostButton3 setTitle:@"湿垃圾" forState:UIControlStateNormal];
        self.ghostButton3.tag = 3;
        [self.contentView addSubview:self.ghostButton3];
        
        self.ghostButton4 = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorWhite];
        self.ghostButton4.titleLabel.font = UIFontMake(20);
        [self.ghostButton4 setTitle:@"干垃圾" forState:UIControlStateNormal];
        self.ghostButton4.tag = 4;
        [self.contentView addSubview:self.ghostButton4];
        
        [self.ghostButton1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.ghostButton2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.ghostButton3 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.ghostButton4 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.selectImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QMUI_tips_done"]];
        self.selectImage1.frame = CGRectMake(160, 4, 36, 36);
        self.selectImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QMUI_tips_done"]];
        self.selectImage2.frame = CGRectMake(160, 4, 36, 36);
        self.selectImage3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QMUI_tips_done"]];
        self.selectImage3.frame = CGRectMake(160, 4, 36, 36);
        self.selectImage4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QMUI_tips_done"]];
        self.selectImage4.frame = CGRectMake(160, 4, 36, 36);
        self.selectImage1.hidden = YES;
        self.selectImage2.hidden = YES;
        self.selectImage3.hidden = YES;
        self.selectImage4.hidden = YES;
        
        [self.ghostButton1 addSubview:self.selectImage1];
        [self.ghostButton2 addSubview:self.selectImage2];
        [self.ghostButton3 addSubview:self.selectImage3];
        [self.ghostButton4 addSubview:self.selectImage4];

        
        self.prevAnswer = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorWhite];
        self.prevAnswer.titleLabel.font = UIFontMake(20);
        [self.prevAnswer setTitle:@"刚才那个" forState:UIControlStateNormal];
        self.prevAnswer.tag = 1;
        [self.prevAnswer addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.prevAnswer];
        
        self.nextAnswer = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorWhite];
        self.nextAnswer.titleLabel.font = UIFontMake(20);
        [self.nextAnswer setTitle:@"抬走下一个" forState:UIControlStateNormal];
        self.nextAnswer.tag = 2;
        [self.nextAnswer addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.nextAnswer];
        
        
        self.prevLayer = [CALayer layer];
        [self.prevLayer qmui_removeDefaultAnimations];
        self.prevLayer.backgroundColor = UIColorMakeWithRGBA(0, 0, 0, .3).CGColor;
        [self.contentView.layer addSublayer:self.prevLayer];
        
        self.nextLayer = [CALayer layer];
        [self.nextLayer qmui_removeDefaultAnimations];
        self.nextLayer.backgroundColor = self.prevLayer.backgroundColor;
        [self.contentView.layer addSublayer:self.nextLayer];
        
        [self.contentLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)contex
{
//    if ([self.answerType isEqualToString:@"1"]) {
//        self.selectImage1.hidden = YES;
//        self.selectImage2.hidden = YES;
//        self.selectImage3.hidden = YES;
//        self.selectImage4.hidden = YES;
//    self.isSelect = NO;
//        if ([self.selectNumberStr isEqualToString:@"1"]) {
//            self.selectImage1.hidden = NO;
//        }else if ([self.selectNumberStr isEqualToString:@"2"]) {
//            self.selectImage2.hidden = NO;
//        }else if ([self.selectNumberStr isEqualToString:@"3"]) {
//            self.selectImage3.hidden = NO;
//        }else if ([self.selectNumberStr isEqualToString:@"4"]) {
//            self.selectImage4.hidden = NO;
//        }
//    }else if([self.answerType isEqualToString:@"2"]){
    
        self.selectImage1.hidden = YES;
        self.selectImage2.hidden = YES;
        self.selectImage3.hidden = YES;
        self.selectImage4.hidden = YES;
        self.isSelect = NO;
        if (![self.selectNumberStr isEqualToString:@"0"]){
            self.isSelect = YES;
            if ([self.garbageType isEqualToString:@"1"]) {
                self.selectImage1.hidden = NO;
            }else if ([self.garbageType isEqualToString:@"2"]) {
                self.selectImage2.hidden = NO;
            }else if ([self.garbageType isEqualToString:@"3"]) {
                self.selectImage3.hidden = NO;
            }else if ([self.garbageType isEqualToString:@"4"]) {
                self.selectImage4.hidden = NO;
            }
            if (![self.selectNumberStr isEqualToString:self.garbageType]) {
                UIImage *image = [UIImage imageNamed:@"QMUI_tips_error"];
                if ([self.selectNumberStr isEqualToString:@"1"]) {
                    self.selectImage1.hidden = NO;
                    self.selectImage1.image = image;
                }else if ([self.selectNumberStr isEqualToString:@"2"]) {
                    self.selectImage2.hidden = NO;
                    self.selectImage2.image = image;
                }else if ([self.selectNumberStr isEqualToString:@"3"]) {
                    self.selectImage3.hidden = NO;
                    self.selectImage3.image = image;
                }else if ([self.selectNumberStr isEqualToString:@"4"]) {
                    self.selectImage4.hidden = NO;
                    self.selectImage4.image = image;
                }
            }
        }
//    }
}



- (void)btnClick:(QMUIGhostButton *)sender{

//    if ([self.answerType isEqualToString:@"1"]) {
//        UIImage *image = [UIImage imageNamed:@"QMUI_tips_done"];
//        if (sender.tag != [self.garbageType intValue]) {
//            image = [UIImage imageNamed:@"QMUI_tips_error"];
//        }
//        if(sender.tag == 1){
//            self.selectImage1.image = image;
//            self.selectImage1.hidden = NO;
//        }else if(sender.tag == 2){
//            self.selectImage2.image = image;
//            self.selectImage2.hidden = NO;
//        }else if(sender.tag == 3){
//            self.selectImage3.image = image;
//            self.selectImage3.hidden = NO;
//        }else if(sender.tag == 4){
//            self.selectImage4.image = image;
//            self.selectImage4.hidden = NO;
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"kDATAARYUPDATE" object:@{@"contentNumber":[NSString stringWithFormat:@"%ld",self.contentLabel.tag],@"selectNumber":[NSString stringWithFormat:@"%ld",sender.tag]}];
//        self.isSelect = YES;
//    }else if([self.answerType isEqualToString:@"2"]){
    
        if (!self.isSelect) {
             UIImage *image = [UIImage imageNamed:@"QMUI_tips_error"];
            if (sender.tag != [self.garbageType intValue]) {
                // 打错了的话显示X
                if(sender.tag == 1){
                    self.selectImage1.image = image;
                    self.selectImage1.hidden = NO;
                }
                if(sender.tag == 2){
                    self.selectImage2.image = image;
                    self.selectImage2.hidden = NO;
                }
                if(sender.tag == 3){
                    self.selectImage3.image = image;
                    self.selectImage3.hidden = NO;
                }
                if(sender.tag == 4){
                    self.selectImage4.image = image;
                    self.selectImage4.hidden = NO;
                }
                NSString *garbageType;
                if ([self.garbageType intValue] == 1) {
                    garbageType = @"可回收垃圾";
                }else if ([self.garbageType intValue] == 2) {
                    garbageType = @"有害垃圾";
                }else if ([self.garbageType intValue] == 3) {
                    garbageType = @"湿垃圾";
                }else if ([self.garbageType intValue] == 4) {
                    garbageType = @"干垃圾";
                }
                NSString *str = [NSString stringWithFormat:@"%@ 是 %@",self.topicLabel.text,garbageType];
                
                [self showAppearanceDialogViewController:@"答错了" text:str type:0];
            }
            // 显示正确的
            if(1 == [self.garbageType intValue]){
                self.selectImage1.hidden = NO;
                self.selectImage1.image = [UIImage imageNamed:@"QMUI_tips_done"];
            }else if(2 == [self.garbageType intValue]){
                self.selectImage2.hidden = NO;
                 self.selectImage2.image = [UIImage imageNamed:@"QMUI_tips_done"];
            }else if(3 == [self.garbageType intValue]){
                self.selectImage3.hidden = NO;
                 self.selectImage3.image = [UIImage imageNamed:@"QMUI_tips_done"];
            }else if(4 == [self.garbageType intValue]){
                self.selectImage4.hidden = NO;
                 self.selectImage4.image = [UIImage imageNamed:@"QMUI_tips_done"];
            }
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kDATAARYUPDATE" object:@{@"contentNumber":[NSString stringWithFormat:@"%ld",self.contentLabel.tag],@"selectNumber":[NSString stringWithFormat:@"%ld",sender.tag]}];
            self.isSelect = YES;
//        }

        

    }
    
}



- (void)setDebug:(BOOL)debug {
    _debug = debug;
    self.prevLayer.hidden = !debug;
    self.nextLayer.hidden = !debug;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentLabel sizeToFit];
    [self.topicLabel sizeToFit];
    self.contentLabel.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) / 2, 50);
    self.topicLabel.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) / 2, 140);
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        self.prevLayer.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) * (1 - self.pagingThreshold), CGRectGetWidth(self.contentView.bounds), PixelOne);
        self.nextLayer.frame = CGRectSetY(self.prevLayer.frame, CGRectGetHeight(self.contentView.bounds) * self.pagingThreshold);
    } else {
        self.prevLayer.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) * (1 - self.pagingThreshold), 0, PixelOne, CGRectGetHeight(self.contentView.bounds));
        self.nextLayer.frame = CGRectSetX(self.prevLayer.frame, CGRectGetWidth(self.contentView.bounds) * self.pagingThreshold);
    }

    CGFloat jiange = 60;
    
    self.ghostButton1.frame = CGRectMake(0, CGRectGetMaxY(self.topicLabel.frame)+60, 200, 44);
    self.ghostButton2.frame = CGRectMake(0, CGRectGetMaxY(self.ghostButton1.frame)+20, 200, 44);
    self.ghostButton3.frame = CGRectMake(0, CGRectGetMaxY(self.ghostButton2.frame)+20, 200, 44);
    self.ghostButton4.frame = CGRectMake(0, CGRectGetMaxY(self.ghostButton3.frame)+20, 200, 44);
    self.ghostButton1.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) / 2, 220 + jiange);
    self.ghostButton2.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) / 2, 220 + jiange*2);
    self.ghostButton3.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) / 2, 220 + jiange*3);
    self.ghostButton4.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) / 2, 220 + jiange*4);
    
    
    CGFloat W = self.contentView.frame.size.width/2 -20;
    
    self.prevAnswer.frame = CGRectMake(10,  CGRectGetMaxY(self.ghostButton4.frame)+35, W, 44);
    self.nextAnswer.frame = CGRectMake(self.contentView.frame.size.width - W -10,  CGRectGetMaxY(self.ghostButton4.frame)+35, W, 44);
    
}

- (void)next:(QMUIGhostButton *)sender{
    if (sender.tag == 1) {
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNEXTITEM" object:@{@"paging":[NSString stringWithFormat:@"%ld",sender.tag]}];
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
    
//    [dialogViewController addCancelButtonWithText:@"再看看" block:nil];
    [dialogViewController addSubmitButtonWithText:@"确定" block:^(QMUIDialogViewController *aDialogViewController) {
        [aDialogViewController hide];
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

@end
