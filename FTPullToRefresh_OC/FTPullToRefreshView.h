//
//  FTPullToRefreshView.h
//  MotorTest
//
//  Created by LiuFengting on 2017/6/14.
//  Copyright © 2017年 MotorFans, JDD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FTPullToRefreshActionBlock)();

typedef NS_ENUM(NSUInteger, FTPullingState) {
    FTPullingStateNormal,
    FTPullingStatePulling,
    FTPullingStateTriggered,
    FTPullingStateRefreshing,
    FTPullingStateDone,
};

typedef NS_ENUM(NSUInteger, FTPullToRefreshViewPosition) {
    FTPullToRefreshViewPositionTop,
    FTPullToRefreshViewPositionBottom,
};


static NSString * const FTPullToRefreshKeyPathContentOffset = @"contentOffset";
static NSString * const FTPullToRefreshKeyPathContentSize = @"contentSize";
static NSString * const FTPullToRefreshKeyPathPanGestureState = @"state";

@interface FTPullToRefreshView : UIView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;


@property (nonatomic, assign) BOOL isHeaderRefreshEnabled;
@property (nonatomic, assign) BOOL isFooterRefreshEnabled;
@property (nonatomic, assign) CGFloat pullingPercentage;
@property (nonatomic, assign) FTPullingState pullingState;
@property (nonatomic, assign) UIEdgeInsets originalContentInset;
@property (nonatomic, assign) FTPullToRefreshViewPosition position;
@property (nonatomic, strong) FTPullToRefreshActionBlock refreshingHeaderBlock;
@property (nonatomic, strong) FTPullToRefreshActionBlock refreshingFooterBlock;

- (void)beginRefreshing;

- (void)endRefreshing;

@end
