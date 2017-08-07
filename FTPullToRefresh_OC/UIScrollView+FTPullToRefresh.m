//
//  UIScrollView+FTPullToRefresh.m
//  MotorTest
//
//  Created by LiuFengting on 2017/6/14.
//  Copyright © 2017年 MotorFans, JDD. All rights reserved.
//

#import "UIScrollView+FTPullToRefresh.h"
#import <objc/runtime.h>

@implementation UIScrollView (FTPullToRefresh)

static char const * const refreshViewAssociateKey = "FTPullToRefreshRefreshViewAssociateKey";
static char const * const refreshIsObservingAssociateKey = "FTPullToRefreshrRefreshIsObservingAssociateKey";

#pragma mark - setter and getter

- (FTPullToRefreshView *)refreshView
{
    return objc_getAssociatedObject(self, &refreshViewAssociateKey);
}

- (void)setRefreshView:(FTPullToRefreshView *)refreshView
{
    objc_setAssociatedObject(self, &refreshViewAssociateKey, refreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)isObserving
{
    return objc_getAssociatedObject(self, &refreshIsObservingAssociateKey);
}

- (void)setIsObserving:(NSNumber *)isObserving
{
    objc_setAssociatedObject(self, &refreshIsObservingAssociateKey, isObserving, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public methods

- (void)addPullRefreshHeaderWithRefreshBlock:(void(^)())refreshBlock
{
    [self createRefreshViewIfNeededIsHeader:YES];
    [self addObservers];
    self.refreshView.refreshingHeaderBlock = refreshBlock;
}

- (void)addPullRefreshFooterWithRefreshBlock:(void(^)())refreshBlock
{
    [self createRefreshViewIfNeededIsHeader:NO];
    [self addObservers];
    self.refreshView.refreshingFooterBlock = refreshBlock;
}

- (void)triggerHeaderPullRefresh
{
    [self prepareRefreshViewWithPosition:FTPullToRefreshViewPositionTop percentage:1];
    if (self.refreshView.isHeaderRefreshEnabled) {
        self.refreshView.pullingState = FTPullingStateRefreshing;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.ft_inset_top = 60 + self.refreshView.originalContentInset.top;
                             self.ft_offset_y = - (60 + self.refreshView.originalContentInset.top);
                         } completion:^(BOOL finished) {
                             [self.refreshView beginRefreshing];
                         }];
    }
}

- (void)triggerFooterPullRefresh
{

    [self prepareRefreshViewWithPosition:FTPullToRefreshViewPositionBottom percentage:1];
    if (self.refreshView.isFooterRefreshEnabled) {
        self.refreshView.pullingState = FTPullingStateRefreshing;
        if (self.contentSize.height > self.bounds.size.height) {
            self.ft_inset_bottom = 60;
            self.ft_offset_y = self.contentSize.height - self.bounds.size.height + 60;
        }
        [self.refreshView beginRefreshing];
    }
}

- (void)stopRefreshing
{
    if (self.refreshView.pullingState == FTPullingStateRefreshing) {
        if (self.refreshView.position == FTPullToRefreshViewPositionTop) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.ft_inset_top = self.refreshView.originalContentInset.top;
                                 self.ft_offset_y = -self.refreshView.originalContentInset.top;
                             }];
        }else{
            if (self.contentSize.height > self.bounds.size.height) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.ft_inset_bottom = 0;
//                                     self.ft_offset_y = self.contentSize.height - self.bounds.size.height;
                                 }];
            }
        }
        [self.refreshView endRefreshing];
    }

}


#pragma mark - private methods

- (void)addObservers
{
    if (!self.isObserving || [self.isObserving integerValue] == 0) {
        [self addObserver:self forKeyPath:FTPullToRefreshKeyPathContentOffset options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:FTPullToRefreshKeyPathContentSize options:NSKeyValueObservingOptionNew context:nil];
        [self.panGestureRecognizer addObserver:self forKeyPath:FTPullToRefreshKeyPathPanGestureState options:NSKeyValueObservingOptionNew context:nil];
        self.isObserving = [NSNumber numberWithInteger:1];
    }
}

- (void)removeObservers
{
    if (self.isObserving && [self.isObserving integerValue] == 1) {
        [self removeObserver:self forKeyPath:FTPullToRefreshKeyPathContentOffset];
        [self removeObserver:self forKeyPath:FTPullToRefreshKeyPathContentSize];
        [self removeObserver:self forKeyPath:FTPullToRefreshKeyPathPanGestureState];
        self.isObserving = [NSNumber numberWithInteger:0];
    }
}

- (void)createRefreshViewIfNeededIsHeader:(BOOL)isHeader
{
    if (self.refreshView) {
        if (isHeader) {
            self.refreshView.isHeaderRefreshEnabled = YES;
        }else{
            self.refreshView.isFooterRefreshEnabled = YES;
        }
        return;
    }

    self.refreshView = [[FTPullToRefreshView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 60)];
    self.refreshView.backgroundColor = [UIColor redColor];
    self.refreshView.position = isHeader ? FTPullToRefreshViewPositionTop : FTPullToRefreshViewPositionBottom;
    if (isHeader) {
        self.refreshView.isHeaderRefreshEnabled = YES;
    }else{
        self.refreshView.isFooterRefreshEnabled = YES;
    }
    [self addSubview:self.refreshView];
    [self repositionRefreshView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSValue *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if ([keyPath isEqualToString:FTPullToRefreshKeyPathContentOffset]) {
        [self scrollViewDidScrollWithContentOffset:newValue.CGPointValue];
    }else if ([keyPath isEqualToString:FTPullToRefreshKeyPathContentSize]) {
        [self scrollViewDidChangeWithContentSize:newValue.CGSizeValue];
    }else if ([keyPath isEqualToString:FTPullToRefreshKeyPathPanGestureState]) {
        [self panGestureDidChangeWithPanGestureState:((NSNumber *)newValue).integerValue];
    }
}



- (void)scrollViewDidScrollWithContentOffset:(CGPoint)contentOffset
{
    if (self.refreshView.pullingState == FTPullingStateRefreshing) {
        return;
    }

    if (!self.isDragging) {
        self.refreshView.originalContentInset = self.contentInset;
    }

    CGFloat pullingPercentage = 0;

    if (contentOffset.y < 0 - (self.refreshView.originalContentInset.top)) {
        if (contentOffset.y < -self.ft_inset_top) {
            pullingPercentage = fabs((self.ft_inset_top + self.ft_offset_y)/60.0);
            [self prepareRefreshViewWithPosition:FTPullToRefreshViewPositionTop percentage:pullingPercentage];
        }
    }else if (self.contentSize.height > self.bounds.size.height) {
        if (contentOffset.y > self.contentSize.height - self.bounds.size.height) {
            pullingPercentage = fabs((contentOffset.y - (self.contentSize.height - self.bounds.size.height))/60.0);
            [self prepareRefreshViewWithPosition:FTPullToRefreshViewPositionBottom percentage:pullingPercentage];
        }
    }else if (self.contentSize.height < self.bounds.size.height) {
        if (contentOffset.y > self.contentSize.height - self.bounds.size.height) {
            pullingPercentage = fabs((self.refreshView.originalContentInset.top + contentOffset.y)/60.0);
            [self prepareRefreshViewWithPosition:FTPullToRefreshViewPositionBottom percentage:pullingPercentage];
        }
    }
}


- (void)scrollViewDidChangeWithContentSize:(CGSize)contentSize
{
    [self repositionRefreshView];
}


- (void)panGestureDidChangeWithPanGestureState:(UIGestureRecognizerState)state
{
    if (state == UIGestureRecognizerStateEnded) {
        if (self.refreshView.position == FTPullToRefreshViewPositionTop && self.refreshView.isHeaderRefreshEnabled) {
            if (self.refreshView.pullingState == FTPullingStateTriggered) {
                self.ft_inset_top = 60 + self.refreshView.originalContentInset.top;
                self.ft_offset_y = - (60 + self.refreshView.originalContentInset.top);
                [self.refreshView beginRefreshing];
            }
        }else if (self.refreshView.position == FTPullToRefreshViewPositionBottom && self.refreshView.isFooterRefreshEnabled) {
            if (self.refreshView.pullingState == FTPullingStateTriggered) {
                if (self.contentSize.height > self.bounds.size.height) {
                    self.ft_inset_bottom = 60;
                    self.ft_offset_y = self.contentSize.height - self.bounds.size.height + 60;
                    [self.refreshView beginRefreshing];
                }else{
                    [self.refreshView beginRefreshing];
                }
            }
        }
    }
}






- (void)prepareRefreshViewWithPosition:(FTPullToRefreshViewPosition)position percentage:(CGFloat)percentage
{
    if (self.refreshView.position != position) {
        self.refreshView.position = position;
        [self repositionRefreshView];
    }
    self.refreshView.pullingPercentage = percentage;
}

- (void)repositionRefreshView
{
    if (self.refreshView.position == FTPullToRefreshViewPositionTop) {
        if (self.refreshView.isHeaderRefreshEnabled) {
            self.refreshView.frame = CGRectMake(0, -60, self.bounds.size.width, 60);
        }
    }else{
        if (self.refreshView.isFooterRefreshEnabled) {
            self.refreshView.frame = CGRectMake(0, self.contentSize.height, self.bounds.size.width, 60);
        }
    }
}




@end


@implementation UIScrollView (functions)

- (CGFloat)ft_offset_y
{
    return self.contentOffset.y;
}

- (void)setFt_offset_y:(CGFloat)ft_offset_y
{
    CGPoint point = self.contentOffset;
    point.y = ft_offset_y;
    self.contentOffset = point;
}

- (CGFloat)ft_inset_top
{
    return self.contentInset.top;
}

- (void)setFt_inset_top:(CGFloat)ft_inset_top
{
    UIEdgeInsets inset = self.contentInset;
    inset.top = ft_inset_top;
    self.contentInset = inset;
}

- (CGFloat)ft_inset_bottom
{
    return self.contentInset.bottom;
}

- (void)setFt_inset_bottom:(CGFloat)ft_inset_bottom
{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = ft_inset_bottom;
    self.contentInset = inset;
}

@end
