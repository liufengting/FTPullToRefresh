//
//  FTPullToRefreshView.m
//  MotorTest
//
//  Created by LiuFengting on 2017/6/14.
//  Copyright © 2017年 MotorFans, JDD. All rights reserved.
//

#import "FTPullToRefreshView.h"
#import <ImageIO/ImageIO.h>

@implementation FTPullToRefreshView


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.originalContentInset = ((UIScrollView *)newSuperview).contentInset;
    }
}


- (void)setPullingPercentage:(CGFloat)pullingPercentage
{
    _pullingPercentage = pullingPercentage;

    NSLog(@"pullingPercentage  %@ %f",NSStringFromUIEdgeInsets(self.originalContentInset)  , pullingPercentage);
    if (pullingPercentage == 0) {
        self.pullingState = FTPullingStateNormal;
    }else if (fabs(pullingPercentage) >= 1) {
        self.pullingState = FTPullingStateTriggered;
    }else{
        self.pullingState = FTPullingStatePulling;
    }
//    self.updateStateLabel()

}

- (void)updateViewWithPullingPercentage
{

}

- (void)beginRefreshing
{
    self.pullingState = FTPullingStateRefreshing;

    if (self.position == FTPullToRefreshViewPositionTop) {
        if (self.refreshingHeaderBlock) {
            self.refreshingHeaderBlock();
        }
    }else{
        if (self.refreshingFooterBlock) {
            self.refreshingFooterBlock();
        }
    }


}

- (void)endRefreshing
{
    self.pullingState = FTPullingStateDone;

    NSLog(@"endRefreshing");

}

+(NSMutableArray *)refreshStateArrayWithGifName:(NSString *)gifName
{
    NSString *path=[[NSBundle mainBundle]pathForResource:gifName ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGFloat animationTime = 0.f;
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            if (img) {
                UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale*1.5 orientation:UIImageOrientationUp];
                [frames addObject:image];
                CGImageRelease(img);
            }
        }
        CFRelease(src);
    }
    return frames;
}

@end

