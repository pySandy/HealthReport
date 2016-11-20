//
//  HeartBeat.h
//  iSandy
//
//  Created by qianfeng on 16/11/4.
//  Copyright © 2016年 PY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol  HeartBeatDelegate <NSObject>

- (void)startHeartDelegateRatePoint:(NSDictionary *)point;

@optional
- (void)startHeartDelegateRateError:(NSError *)error;
- (void)startHeartDelegateRateFrequency:(NSInteger)frequency;
@end


@interface HeartBeat : NSObject

@property (copy, nonatomic) void ((^backPoint)(NSDictionary *));
@property (copy, nonatomic) void ((^frequency)(NSInteger));
@property (copy, nonatomic) void ((^Error)(NSError *));
@property (weak, nonatomic) id <HeartBeatDelegate> delegate;

//单例
+ (instancetype)shareManager;

- (void)start;
/*调用摄像头的方法
 *@param backPonit 浮点和时间戳的实时回调
 *                  * 数据类型 字典
 *                  * 数据格式 { “1473386373135.52” = “0.3798618”}
 *                       * 字典key: NSNumber类型double浮点数->时间戳 小数点精确到毫秒
 *                       * 字典Value: NSNumber 类型float浮点数 数据未处理全部返回
 */
- (void)startHeartRatePoint:(void(^)(NSDictionary *point))backPoint Frequency:(void(^)(NSInteger fre))frequency Error:(void(^)(NSError *error))error;

//结束方法
- (void)stop;


@end
