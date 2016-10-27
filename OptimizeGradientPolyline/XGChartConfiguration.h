//
//  XGChartConfiguration.h
//  XGChart
//
//  Created by 宋晓光 on 25/10/2016.
//  Copyright © 2016 Light. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//  图表类型
typedef enum : NSUInteger {
  XGChartTypeLineChart,  //  折线图
  XGChartTypeBarChart,   //  条形图
  XGChartTypeCurveChart, //  曲线图
} XGChartType;

//  数据点
@interface XGChartPoint : NSObject

@property(nonatomic, assign, readonly) CGFloat x;
@property(nonatomic, assign, readonly) CGFloat y;

//  初始化方法
- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y;

@end

//  图表参数父类
@interface XGChartConfiguration : NSObject

//  图表类型
@property(nonatomic, assign) XGChartType chartType;
//  图表背景
@property(nonatomic, strong) UIColor *backgroundColor;
//  图表边距
@property(nonatomic, assign) CGFloat paddingTop;
@property(nonatomic, assign) CGFloat paddingLeft;
@property(nonatomic, assign) CGFloat paddingBottom;
@property(nonatomic, assign) CGFloat paddingRight;
//  grid数目
@property(nonatomic, assign) NSUInteger xGridCount;
@property(nonatomic, assign) NSUInteger yGridCount;
//  grid颜色
@property(nonatomic, strong) UIColor *gridColor;
//  x轴
@property(nonatomic, strong) UIColor *xAxisLabelColor;
@property(nonatomic, assign) CGFloat xAxisLabelFontSize;
//  y轴
@property(nonatomic, strong) UIColor *yAxisLabelColor;
@property(nonatomic, assign) CGFloat yAxisLabelFontSize;
//  数据点
@property(nonatomic, strong) NSArray<XGChartPoint *> *chartPoints;
//  线条颜色
@property(nonatomic, strong) UIColor *strokeColor;
//  填充颜色
@property(nonatomic, strong) UIColor *fillColor;
//  线条宽度
@property(nonatomic, assign) CGFloat lineWidth;

@end
