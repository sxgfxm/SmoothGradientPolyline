//
//  XGChartConfiguration.m
//  XGChart
//
//  Created by 宋晓光 on 25/10/2016.
//  Copyright © 2016 Light. All rights reserved.
//

#import "XGChartConfiguration.h"

@implementation XGChartConfiguration

- (instancetype)init {
  if (self = [super init]) {
    _chartType = XGChartTypeLineChart;
    _paddingTop = 20;
    _paddingLeft = 20;
    _paddingBottom = 20;
    _paddingRight = 20;
    _xGridCount = 3;
    _yGridCount = 4;
    _gridColor = [UIColor grayColor];
    _xAxisLabelColor = [UIColor whiteColor];
    _xAxisLabelFontSize = 12;
    _yAxisLabelColor = [UIColor whiteColor];
    _yAxisLabelFontSize = 12;
    _strokeColor = [UIColor redColor];
    _fillColor = [UIColor redColor];
    _lineWidth = 3;
  }
  return self;
}

@end

@implementation XGChartPoint

- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y {
  if (self = [super init]) {
    _x = x;
    _y = y;
  }
  return self;
}

@end
