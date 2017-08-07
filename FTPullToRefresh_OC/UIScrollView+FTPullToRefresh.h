//
//  UIScrollView+FTPullToRefresh.h
//  MotorTest
//
//  Created by LiuFengting on 2017/6/14.
//  Copyright © 2017年 MotorFans, JDD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTPullToRefreshView.h"

@interface UIScrollView (FTPullToRefresh)

@property (nonatomic, strong) FTPullToRefreshView *refreshView;
@property (nonatomic, strong) NSNumber *isObserving;


- (void)addPullRefreshHeaderWithRefreshBlock:(void(^)())refreshBlock;

- (void)addPullRefreshFooterWithRefreshBlock:(void(^)())refreshBlock;

- (void)triggerHeaderPullRefresh;

- (void)triggerFooterPullRefresh;

- (void)stopRefreshing;

@end



@interface UIScrollView (functions)


@property (assign, nonatomic) CGFloat ft_offset_y;
@property (assign, nonatomic) CGFloat ft_inset_top;
@property (assign, nonatomic) CGFloat ft_inset_bottom;

@end
