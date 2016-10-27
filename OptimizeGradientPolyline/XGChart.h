//
//  XGChart.h
//  XGChart
//
//  Created by 宋晓光 on 25/10/2016.
//  Copyright © 2016 Light. All rights reserved.
//

//  图表参数类
#import "XGChartConfiguration.h"

@interface XGChart : UIView

//  初始化方法
//  frame:  图表frame
//  configuration:  图表参数
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(XGChartConfiguration *)configuration;

@end
