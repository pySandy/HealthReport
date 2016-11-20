//
//  HeartLive.h
//  iSandy
//
//  Created by qianfeng on 16/11/6.
//  Copyright © 2016年 PY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartLive : UIView

- (void)drawRateWithPoint:(NSNumber *)ponit;

/** 进度0~1之间，默认0，在最后设置进度 */
@property (nonatomic, assign) CGFloat progress;

/** 进度轨道边宽，默认20 */
@property (nonatomic, assign) CGFloat trackWidth;

/** 动画，默认YES */
@property (nonatomic, assign) BOOL animation;

/** 进度条颜色，默认红色 */
@property (nonatomic, strong) UIColor *progressColor;

/** 进度轨道颜色，默认灰色 */
@property (nonatomic, strong) UIColor *trackColor;

/** 填充内部颜色，默认clearColor */
@property (nonatomic, strong) UIColor *fillColor;

@end
