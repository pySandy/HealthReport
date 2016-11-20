//
//  HeartLive.m
//  iSandy
//
//  Created by qianfeng on 16/11/6.
//  Copyright © 2016年 PY. All rights reserved.
//

#import "HeartLive.h"
//#import <QuartzCore/QuartzCore.h>

@interface HeartLive ()

@property (strong, nonatomic) NSMutableArray *points;

@end

static CGFloat grid_w = 30.0f;

@implementation HeartLive
{
    /** 轨道图层 */
    CAShapeLayer *_YGtrackLayer;
    /** 进度图层 */
    CAShapeLayer *_YGprogressLayer;
    
    /** 轨道曲线 */
    UIBezierPath *_YGtrackBezier;
    /** 进度曲线 */
    UIBezierPath *_YGprogressBezier;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.points = [[NSMutableArray alloc] init];
        self.clearsContextBeforeDrawing = YES;
        [self setUp];
    }
    return self;
}

/**
 初始化图层
 */
- (void)setUp
{
    // 设置初始值
    _animation = YES;
    _trackWidth = 20;
    _trackColor = [UIColor grayColor];
    _progressColor = [UIColor redColor];
    _fillColor = [UIColor clearColor];
    
//    self.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor blueColor];
    // 初始化图层
    _YGtrackLayer = [CAShapeLayer layer];
    // 图层的frame
    _YGtrackLayer.frame = self.bounds;
    // 线条宽度
    _YGtrackLayer.lineWidth = _trackWidth;
    // 填充透明
    _YGtrackLayer.fillColor = _fillColor.CGColor;
    
    _YGprogressLayer = [CAShapeLayer layer];
    _YGprogressLayer.frame = self.bounds;
    _YGprogressLayer.lineWidth = _trackWidth;
    _YGprogressLayer.lineCap = kCALineCapRound;
    // 填充内部色
    _YGprogressLayer.fillColor = _fillColor.CGColor;
    
    [self.layer addSublayer:_YGtrackLayer];
    [self.layer addSublayer:_YGprogressLayer];
    
    // 设置默认值
    [self setProgressColor:_progressColor];
    [self setTrackColor:_trackColor];
    [self setTrackWidth:_trackWidth];
}

/**
 设置进度颜色
 */
- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    
    // 设置进度颜色
    _YGprogressLayer.strokeColor = _progressColor.CGColor;
}

/**
 设置轨道进度颜色
 */
- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
    
    // 设置轨道进度颜色
    _YGtrackLayer.strokeColor = _trackColor.CGColor;
}

/**
 设置填充色
 */
- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    
    // 设置填充色
    _YGtrackLayer.fillColor = _fillColor.CGColor;

}

/**
 设置进度轨道的宽度
 */
- (void)setTrackWidth:(CGFloat)trackWidth
{
    _trackWidth = trackWidth;
    
    _YGtrackLayer.lineWidth = _trackWidth;
    
    _YGprogressLayer.lineWidth = _trackWidth;
    
    // 设置轨道曲线
    _YGtrackBezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:(MIN(self.bounds.size.width, self.bounds.size.height)-self.trackWidth)/2.0 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    _YGtrackLayer.path = _YGtrackBezier.CGPath;
}

/**
 设置进度
 */
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    if (_animation)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressAnimation:) userInfo:nil repeats:YES];
    }
    else
    {
        [self drawProgressBezier:_progress];
    }
}

/**
 动画
 */
- (void)progressAnimation:(NSTimer *)timer
{
    static CGFloat tempProgress = 0.0;
    
    tempProgress += 0.01;
    
    if (tempProgress >= _progress)
    {
        [timer invalidate];
        timer = nil;
        tempProgress = 0.0;
    }
    else
    {
        [self drawProgressBezier:tempProgress];
    }
}

/**
 绘制进度曲线
 */
- (void)drawProgressBezier:(CGFloat)progress
{
    // 设置进度曲线
    _YGprogressBezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:(MIN(self.bounds.size.width, self.bounds.size.height)-self.trackWidth)/2.0 startAngle:-M_PI_4 endAngle:(2*M_PI)*progress - M_PI_4 clockwise:YES];
    
    _YGprogressLayer.path = _YGprogressBezier.CGPath;
}

#pragma mark -添加view

- (void)drawRateWithPoint:(NSNumber *)ponit
{
    //倒序插入数组
    [self.points insertObject:ponit atIndex:0];
    
    //删除溢出屏幕数据
    if (self.points.count > self.frame.size.width/6)
    {
        [self.points removeLastObject];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //这个方法自动调取 drawRect:方法
        [self setNeedsDisplay];
    });
}

- (void)drawRate
{
    CGFloat ww = self.frame.size.width;
    CGFloat hh = self.frame.size.height;
    CGFloat pos_x = ww;
    CGFloat pos_y = hh/2;
    //获取当前画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    //折线宽度
    CGContextSetLineWidth(context, 1.0);
    //折现颜色
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, pos_x, pos_y);
    for (int i = 0; i<self.points.count; i++) {
        float h = [self.points[i] floatValue];
        pos_y = hh/2 + (h * hh/2);
        CGContextAddLineToPoint(context, pos_x, pos_y);
        pos_x -= 6;
    }
    CGContextStrokePath(context);
}

#pragma mark- 网络
- (void)builfGrid
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    //获取当前画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat pos_x = 0.0f;
    CGFloat pos_y = 0.0f;
    
    //在width范围内画竖线
    while (pos_x < width) {
        //设置网格线宽度
        CGContextSetLineWidth(context, 0.2);
        //设置网格线颜色
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        //起点
        CGContextMoveToPoint(context, pos_x, 1.0f);
        //终点
        CGContextAddLineToPoint(context, pos_x, height);
        pos_x += grid_w;
        //开始划线
        CGContextStrokePath(context);
    }
    //在height范围内划横线
    while (pos_y < height) {
        CGContextSetLineWidth(context, 0.2);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextMoveToPoint(context, 1.0f, pos_y);
        CGContextAddLineToPoint(context, width, pos_y);
        pos_y += grid_w;
        CGContextStrokePath(context);
    }
    pos_x = 0.0f;
    pos_y = 0.0f;
    
    //在width范围内竖线
    while (pos_x < width) {
        CGContextSetLineWidth(context, 0.1);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextMoveToPoint(context, pos_x, 1.0f);
        CGContextAddLineToPoint(context, pos_x, height);
        pos_x += grid_w/5;
        CGContextStrokePath(context);
    }
    
    //在height范围内画横线
    while (pos_y < height)
    {
        CGContextSetLineWidth(context, 0.1);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextMoveToPoint(context, 1.0f, pos_y);
        CGContextAddLineToPoint(context, width, pos_y);
        pos_y += grid_w/5;
        CGContextStrokePath(context);
    }
}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame])
//    {
//        self.backgroundColor = [UIColor blackColor];
//        self.points = [[NSMutableArray alloc] init];
//        self.clearsContextBeforeDrawing = YES;
//    }
//    return self;
//}

- (void)drawRect:(CGRect)rect
{
    [self builfGrid];
    [self drawRate];

}
//
//-(void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius {
//    CGRect rect = self.bounds;
//    
//    // Create the path
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
//                                                   byRoundingCorners:corners
//                                                         cornerRadii:CGSizeMake(radius, radius)];
//    
//    // Create the shape layer and set its path
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = rect;
//    maskLayer.path = maskPath.CGPath;
//    
//    // Set the newly created shape layer as the mask for the view's layer
//    self.layer.mask = maskLayer;
//    self.layer.shouldRasterize = YES;
//}






@end
