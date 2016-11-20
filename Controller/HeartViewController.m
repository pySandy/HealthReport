//
//  HeartViewController.m
//  iSandy
//
//  Created by qianfeng on 16/11/6.
//  Copyright © 2016年 PY. All rights reserved.
//

#import "HeartViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "AppDelegate.h"

#define pi 3.14159265359
#define DEGREES_TO_RADIANS(degress) ((pi * degress)/180)

@interface HeartViewController ()<HeartBeatDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) HeartLive *live;

@property (strong, nonatomic) UILabel *label;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (strong, nonatomic) IBOutlet UISwitch *select;

@property (strong, nonatomic) IBOutlet UILabel *stepLbl;
@property (strong, nonatomic) IBOutlet UILabel *switchLbl;

@property(nonatomic,strong)CMPedometer *pedometer;

@end

@implementation HeartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.select.hidden = YES;
    self.stepLbl.hidden = YES;
    self.switchLbl.hidden = YES;
    //创建一个心电图的view
    self.live = [[HeartLive alloc] initWithFrame:CGRectMake(self.view.mj_w/2-100, 100,200,200)];
    self.live.backgroundColor = [UIColor colorWithRed:186/255.0 green:251/255.0 blue:231/255.0 alpha:0.9];
    self.live.layer.cornerRadius = 100;
    self.live.layer.masksToBounds = YES;
    
    // 设置轨道的厚度
    self.live.trackWidth = 20;
    
    // 动画
    self.live.animation = YES;
    
    // 轨道的颜色
    self.live.trackColor = [UIColor grayColor];
    
    // 进度条颜色
    self.live.progressColor = [UIColor redColor];
    self.live.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.live];
   
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.live.mj_h+self.live.mj_y+10, self.view.frame.size.width, 30)];
    self.label.layer.borderColor = [UIColor blackColor].CGColor;

    self.label.textColor = [UIColor blackColor];
    self.label.font = [UIFont systemFontOfSize:28];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];

    [self showAlertView];


//    self.stepLbl.text =@"当前步行了0步";
    
//    [self.select addTarget:self action:@selector(openOrCloseCollectStep:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 计步功能
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfStepsChanged:) name:@"numberOfSteps" object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"numberOfSteps" object:nil];
    
}
-(void)numberOfStepsChanged:(NSNotification *)notif{
    
    
    NSString * numberOfSteps = [[notif userInfo] objectForKey:@"numberOfSteps"];
    
    NSLog(@"***********   ********** numberOfSteps  %@   *************",numberOfSteps);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.stepLbl.text =[NSString stringWithFormat:@"当前步行了%@步",numberOfSteps];
        
    });
    
    
    
}



-(void)openOrCloseCollectStep:(UISwitch *)switchBtn{
    
    
    if (switchBtn.on) {
        
        [self  gotoOpenStepCountFunction];
        
    }else{
        
        [self gotoCloseStepCountFucntion];
        
    }
}






-(void)gotoOpenStepCountFunction{
    
    _pedometer = [[AppDelegate share ] sharedPedometer];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"startStepCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([CMPedometer isStepCountingAvailable]) {
        [_pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"error====%@",error);
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"startStepCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }else {
                NSLog(@"BBB步数====%@",pedometerData.numberOfSteps);
                NSLog(@"BBB距离====%@",pedometerData.distance);
                
                NSDictionary *dic =[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",pedometerData.numberOfSteps],@"numberOfSteps", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"numberOfSteps" object:nil userInfo:dic];
                
                
            }
            
        }];
        
    }else{
        
        NSLog(@"计步器不可用");
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"startStepCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
}

-(void)gotoCloseStepCountFucntion{
    
    if ([CMPedometer isStepCountingAvailable]) {
        
        _pedometer = [[AppDelegate share] sharedPedometer];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"startStepCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_pedometer stopPedometerUpdates];
        
    }
    
}



//是否要开启检测心率
- (void)showAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您是否要开启检测心率" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];

    [alert show];
  

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //    开启测心率方法
        [HeartBeat shareManager].delegate = self;
        [[HeartBeat shareManager] start];

    }
}

- (IBAction)startBtn:(UIButton *)sender
{
    [[HeartBeat shareManager] start];
    
}

- (IBAction)stopButton:(UIButton *)sender
{
    [[HeartBeat shareManager] stop];

}



#pragma mark - 测心率回调
- (void)startHeartDelegateRatePoint:(NSDictionary *)point
{
    NSNumber *n = [[point allValues] firstObject];
    //拿到的数据传给心电图的view
    [self.live drawRateWithPoint:n];

}

- (void)startHeartDelegateRateError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)startHeartDelegateRateFrequency:(NSInteger)frequency
{
    NSLog(@"\n瞬时心率:%ld",(long)frequency);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = [NSString stringWithFormat:@"%ld次/分",(long)frequency];
    });

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
