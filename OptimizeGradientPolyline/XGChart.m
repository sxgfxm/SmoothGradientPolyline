//
//  XGChart.m
//  XGChart
//
//  Created by 宋晓光 on 25/10/2016.
//  Copyright © 2016 Light. All rights reserved.
//

#import "XGChart.h"

@interface XGChart ()

//  configuration
@property(nonatomic, strong) XGChartConfiguration *configuration;
//  chartWidth
@property(nonatomic, assign) CGFloat chartWidth;
//  chartHeight
@property(nonatomic, assign) CGFloat chartHeight;
//  maxValueX
@property(nonatomic, assign) CGFloat maxValueX;
//  maxValueY
@property(nonatomic, assign) CGFloat maxValueY;
//  normalizedChartPoints
@property(nonatomic, strong)
    NSMutableArray<XGChartPoint *> *normalizedChartPoints;
//  drawingChartPoints
@property(nonatomic, strong) NSMutableArray<XGChartPoint *> *drawingChartPoints;
//  gridLayer
@property(nonatomic, strong) CALayer *gridLayer;
//  xAxisLayer
@property(nonatomic, strong) CALayer *xAxisLayer;
//  yAxisLayer
@property(nonatomic, strong) CALayer *yAxisLayer;
//  gradientLayer
@property(nonatomic, strong) CAGradientLayer *gradientLayer;
//  maskLayer
@property(nonatomic, strong) CALayer *lineLayer;

@end

@implementation XGChart

- (instancetype)initWithFrame:(CGRect)frame
                configuration:(XGChartConfiguration *)configuration {
  if (self = [super initWithFrame:frame]) {
    //  准备数据
    [self prepareDatas:configuration];
    //  创建图层
    [self setupLayers];
  }
  return self;
}

#pragma mark - Prepare Datas
- (void)prepareDatas:(XGChartConfiguration *)configuration {
  NSLog(@"XGChart: Prepare Datas");
  //  configuration
  self.configuration = configuration;
  //  图表宽高
  self.chartWidth = self.frame.size.width - self.configuration.paddingLeft -
                    self.configuration.paddingRight;
  self.chartHeight = self.frame.size.height - self.configuration.paddingTop -
                     self.configuration.paddingBottom;
  //  数据最大值，用于数据归一化
  self.maxValueX = 0;
  self.maxValueY = 0;
  for (XGChartPoint *point in self.configuration.chartPoints) {
    self.maxValueX = self.maxValueX < point.x ? point.x : self.maxValueX;
    self.maxValueY = self.maxValueY < point.y ? point.y : self.maxValueY;
  }
  self.maxValueX = self.maxValueX == 0 ? 1 : self.maxValueX;
  self.maxValueY = self.maxValueY == 0 ? 1 : self.maxValueY;
  //  数据归一化
  self.normalizedChartPoints = [NSMutableArray array];
  self.drawingChartPoints = [NSMutableArray array];
  for (XGChartPoint *point in self.configuration.chartPoints) {
    XGChartPoint *normalizedPoint =
        [[XGChartPoint alloc] initWithX:point.x / self.maxValueX
                                   andY:point.y / self.maxValueY];
    [self.normalizedChartPoints addObject:normalizedPoint];
    XGChartPoint *drawingPoint = [[XGChartPoint alloc]
        initWithX:normalizedPoint.x * self.chartWidth +
                  self.configuration.paddingLeft
             andY:(1 - normalizedPoint.y) * self.chartHeight +
                  self.configuration.paddingTop];
    [self.drawingChartPoints addObject:drawingPoint];
  }
}

#pragma mark - Setup Layers
- (void)setupLayers {
  NSLog(@"XGChart: Setup Layers");
  [self setupGridLayer];
  [self setupXAxisLayer];
  [self setupYAxisLayer];
  [self setupGradientLayer];
  [self setupLineLayer];
}

- (void)setupGridLayer {
  NSLog(@"XGChart: Setup GridLayer");
  self.gridLayer = [CALayer layer];
  self.gridLayer.frame = self.layer.bounds;
  CGFloat xGridWidth, yGridWidth;
  //  x grid
  if (self.configuration.xGridCount) {
    NSLog(@"XGChart: Setup XGridLayer");
    xGridWidth = self.chartWidth / self.configuration.xGridCount;
    CAShapeLayer *xGridLayer = [CAShapeLayer layer];
    xGridLayer.frame = self.gridLayer.bounds;
    UIBezierPath *xGridPath = [UIBezierPath bezierPath];
    for (int i = 1; i < self.configuration.xGridCount; i++) {
      [xGridPath moveToPoint:CGPointMake(self.configuration.paddingLeft +
                                             xGridWidth * i,
                                         self.configuration.paddingTop)];
      [xGridPath
          addLineToPoint:CGPointMake(
                             self.configuration.paddingLeft + xGridWidth * i,
                             self.configuration.paddingTop + self.chartHeight)];
    }
    xGridLayer.path = xGridPath.CGPath;
    xGridLayer.lineWidth = 1;
    xGridLayer.lineDashPattern = @[ @(3) ];
    xGridLayer.strokeColor = self.configuration.gridColor.CGColor;
    xGridLayer.fillColor = [UIColor clearColor].CGColor;
    [self.gridLayer addSublayer:xGridLayer];
  }
  //  y grid
  if (self.configuration.yGridCount) {
    NSLog(@"XGChart: Setup YGridLayer");
    yGridWidth = self.chartHeight / self.configuration.yGridCount;
    CAShapeLayer *yGridLayer = [CAShapeLayer layer];
    yGridLayer.frame = self.gridLayer.bounds;
    UIBezierPath *yGridPath = [UIBezierPath bezierPath];
    for (int i = 1; i < self.configuration.yGridCount; i++) {
      [yGridPath moveToPoint:CGPointMake(self.configuration.paddingLeft,
                                         self.configuration.paddingTop +
                                             i * yGridWidth)];
      [yGridPath
          addLineToPoint:CGPointMake(
                             self.configuration.paddingLeft + self.chartWidth,
                             self.configuration.paddingTop + i * yGridWidth)];
    }
    yGridLayer.path = yGridPath.CGPath;
    yGridLayer.lineWidth = 1;
    yGridLayer.lineDashPattern = @[ @(3) ];
    yGridLayer.strokeColor = self.configuration.gridColor.CGColor;
    yGridLayer.fillColor = [UIColor clearColor].CGColor;
    [self.gridLayer addSublayer:yGridLayer];
  }
  //  add gridLayer
  [self.layer addSublayer:self.gridLayer];
}

- (void)setupXAxisLayer {
  NSLog(@"XGChart: Setup XAxisLayer");
  self.xAxisLayer = [CALayer layer];
  self.xAxisLayer.frame = self.layer.bounds;
  //  axis
  CAShapeLayer *axisLayer = [CAShapeLayer layer];
  axisLayer.frame = self.xAxisLayer.bounds;
  UIBezierPath *axisPath = [UIBezierPath bezierPath];
  [axisPath moveToPoint:CGPointMake(self.configuration.paddingLeft,
                                    self.configuration.paddingTop +
                                        self.chartHeight)];
  [axisPath
      addLineToPoint:CGPointMake(
                         self.configuration.paddingLeft + self.chartWidth,
                         self.configuration.paddingTop + self.chartHeight)];
  axisLayer.path = axisPath.CGPath;
  axisLayer.lineWidth = 1;
  axisLayer.strokeColor =
      [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
  axisLayer.fillColor = [UIColor clearColor].CGColor;
  [self.xAxisLayer addSublayer:axisLayer];
  //  label
  if (self.configuration.xGridCount) {
    CGFloat xGridWidth = self.chartWidth / self.configuration.xGridCount;
    CGFloat xUnitValue = self.maxValueX / self.configuration.xGridCount;
    for (int i = 0; i < self.configuration.xGridCount + 1; i++) {
      //  value size
      NSString *stringOfValue =
          [NSString stringWithFormat:@"%.0f", xUnitValue * i];
      CGSize size =
          [stringOfValue
              boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                           options:NSStringDrawingUsesFontLeading
                        attributes:@{
                          NSFontAttributeName :
                              [UIFont systemFontOfSize:self.configuration
                                                           .xAxisLabelFontSize]
                        }
                           context:nil]
              .size;
      CATextLayer *textLayer = [CATextLayer layer];
      if (i == 0) {
        textLayer.frame =
            CGRectMake(self.configuration.paddingLeft + i * xGridWidth,
                       self.configuration.paddingTop + self.chartHeight +
                           (self.configuration.paddingBottom - size.height) / 2,
                       size.width, size.height);
      } else if (i == self.configuration.xGridCount) {
        textLayer.frame = CGRectMake(
            self.configuration.paddingLeft + i * xGridWidth - size.width,
            self.configuration.paddingTop + self.chartHeight +
                (self.configuration.paddingBottom - size.height) / 2,
            size.width, size.height);

      } else {
        textLayer.frame = CGRectMake(
            self.configuration.paddingLeft + i * xGridWidth - size.width / 2,
            self.configuration.paddingTop + self.chartHeight +
                (self.configuration.paddingBottom - size.height) / 2,
            size.width, size.height);
      }
      [textLayer setString:stringOfValue];
      [textLayer setFontSize:self.configuration.xAxisLabelFontSize];
      [textLayer setForegroundColor:self.configuration.xAxisLabelColor.CGColor];
      [textLayer setContentsScale:2.0];
      [self.xAxisLayer addSublayer:textLayer];
    }
  }
  //  add xAxisLayer
  [self.layer addSublayer:self.xAxisLayer];
}

- (void)setupYAxisLayer {
  NSLog(@"XGChart: Setup YAxisLayer");
  self.yAxisLayer = [CALayer layer];
  self.yAxisLayer.frame = self.layer.bounds;
  //  axis
  CAShapeLayer *axisLayer = [CAShapeLayer layer];
  axisLayer.frame = self.xAxisLayer.bounds;
  UIBezierPath *axisPath = [UIBezierPath bezierPath];
  [axisPath moveToPoint:CGPointMake(self.configuration.paddingLeft,
                                    self.configuration.paddingTop)];
  [axisPath addLineToPoint:CGPointMake(self.configuration.paddingLeft,
                                       self.configuration.paddingTop +
                                           self.chartHeight)];
  axisLayer.path = axisPath.CGPath;
  axisLayer.lineWidth = 1;
  axisLayer.strokeColor =
      [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
  axisLayer.fillColor = [UIColor clearColor].CGColor;
  [self.yAxisLayer addSublayer:axisLayer];
  //  label
  if (self.configuration.yGridCount) {
    CGFloat yGridWidth = self.chartHeight / self.configuration.yGridCount;
    CGFloat yUnitValue = self.maxValueY / self.configuration.yGridCount;
    for (int i = 0; i < self.configuration.yGridCount + 1; i++) {
      //  value size
      NSString *stringOfValue =
          [NSString stringWithFormat:@"%.0f", self.maxValueY - yUnitValue * i];
      CGSize size =
          [stringOfValue
              boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                           options:NSStringDrawingUsesFontLeading
                        attributes:@{
                          NSFontAttributeName :
                              [UIFont systemFontOfSize:self.configuration
                                                           .yAxisLabelFontSize]
                        }
                           context:nil]
              .size;
      CATextLayer *textLayer = [CATextLayer layer];
      if (i == 0) {
        textLayer.frame =
            CGRectMake((self.configuration.paddingLeft - size.width) / 2,
                       self.configuration.paddingTop + i * yGridWidth,
                       size.width, size.height);
      } else if (i == self.configuration.yGridCount) {
        textLayer.frame = CGRectMake(
            (self.configuration.paddingLeft - size.width) / 2,
            self.configuration.paddingTop + i * yGridWidth - size.height,
            size.width, size.height);

      } else {
        textLayer.frame = CGRectMake(
            (self.configuration.paddingLeft - size.width) / 2,
            self.configuration.paddingTop + i * yGridWidth - size.height / 2,
            size.width, size.height);
      }
      [textLayer setString:stringOfValue];
      [textLayer setFontSize:self.configuration.yAxisLabelFontSize];
      [textLayer setForegroundColor:self.configuration.yAxisLabelColor.CGColor];
      [textLayer setContentsScale:2.0];
      [self.yAxisLayer addSublayer:textLayer];
    }
  }
  //  add xAxisLayer
  [self.layer addSublayer:self.yAxisLayer];
}

- (void)setupGradientLayer {
  if (self.configuration.chartType == XGChartTypeBarChart) {
    return;
  }
  NSLog(@"XGChart: Setup GradientLayer");
  self.gradientLayer = [CAGradientLayer layer];
  self.gradientLayer.frame = self.layer.bounds;
  self.gradientLayer.locations = @[ @(0.1), @(0.9) ];
  self.gradientLayer.colors = @[
    (__bridge id)(
        [self.configuration.fillColor colorWithAlphaComponent:0.5].CGColor),
    (__bridge id)(
        [self.configuration.fillColor colorWithAlphaComponent:0.1].CGColor)
  ];
  self.gradientLayer.startPoint = CGPointMake(0, 0);
  self.gradientLayer.endPoint = CGPointMake(0, 1);
  [self.layer addSublayer:self.gradientLayer];
  //  fill
  CAShapeLayer *fillLayer = [CAShapeLayer layer];
  fillLayer.frame = self.lineLayer.bounds;
  UIBezierPath *path = [self bezierPathOfStrokeLayer];
  [path addLineToPoint:CGPointMake([self.drawingChartPoints lastObject].x,
                                   self.configuration.paddingTop +
                                       self.chartHeight)];
  [path addLineToPoint:CGPointMake([self.drawingChartPoints firstObject].x,
                                   self.configuration.paddingTop +
                                       self.chartHeight)];
  [path closePath];
  fillLayer.path = path.CGPath;
  fillLayer.fillColor = [UIColor whiteColor].CGColor;
  fillLayer.strokeColor = [UIColor whiteColor].CGColor;
  self.gradientLayer.mask = fillLayer;
}

- (void)setupLineLayer {
  NSLog(@"XGChart: Setup LineLayer");
  self.lineLayer = [CALayer layer];
  self.lineLayer.frame = self.layer.bounds;
  //  stroke
  CAShapeLayer *strokeLayer = [CAShapeLayer layer];
  strokeLayer.frame = self.lineLayer.bounds;
  strokeLayer.path = [self bezierPathOfStrokeLayer].CGPath;
  strokeLayer.strokeColor = self.configuration.strokeColor.CGColor;
  strokeLayer.fillColor = [UIColor clearColor].CGColor;
  strokeLayer.lineWidth = self.configuration.lineWidth;
  strokeLayer.lineJoin = kCALineJoinRound;
  strokeLayer.lineCap = kCALineCapRound;
  if (self.configuration.chartType == XGChartTypeBarChart) {
    strokeLayer.strokeColor = self.configuration.fillColor.CGColor;
    strokeLayer.lineCap = kCALineCapButt;
    if (strokeLayer.lineWidth >
        (self.chartWidth / self.drawingChartPoints.count - 2)) {
      strokeLayer.lineWidth =
          self.chartWidth / self.drawingChartPoints.count - 2;
    }
  }
  [self.lineLayer addSublayer:strokeLayer];
  //  add lineLayer
  [self.layer addSublayer:self.lineLayer];
}

- (UIBezierPath *)bezierPathOfStrokeLayer {
  UIBezierPath *path = [UIBezierPath bezierPath];
  if (self.configuration.chartType == XGChartTypeLineChart) {
    BOOL isFirst = YES;
    for (XGChartPoint *point in self.drawingChartPoints) {
      if (isFirst) {
        [path moveToPoint:CGPointMake(point.x, point.y)];
        isFirst = NO;
      } else {
        [path addLineToPoint:CGPointMake(point.x, point.y)];
      }
    }
  }
  if (self.configuration.chartType == XGChartTypeCurveChart) {
    BOOL isFirst = YES;
    CGPoint lastPoint;
    for (XGChartPoint *point in self.drawingChartPoints) {
      if (isFirst) {
        [path moveToPoint:CGPointMake(point.x, point.y)];
        lastPoint = CGPointMake(point.x, point.y);
        isFirst = NO;
      } else {
        CGPoint mid, cp1, cp2;
        CGFloat delta;
        mid.x = (lastPoint.x + point.x) / 2;
        mid.y = (lastPoint.y + point.y) / 2;
        //  cp1
        cp1.x = (lastPoint.x + mid.x) / 2;
        cp1.y = (lastPoint.y + mid.y) / 2;
        delta = fabs(mid.y - cp1.y);
        if (cp1.y > mid.y) {
          cp1.y += delta;
        } else {
          cp1.y -= delta;
        }
        //  cp2
        cp2.x = (mid.x + point.x) / 2;
        cp2.y = (mid.y + point.y) / 2;
        delta = fabs(point.y - cp2.y);
        if (cp2.y < point.y) {
          cp2.y += delta;
        } else {
          cp2.y -= delta;
        }
        //  curve
        [path addQuadCurveToPoint:mid controlPoint:cp1];
        [path addQuadCurveToPoint:CGPointMake(point.x, point.y)
                     controlPoint:cp2];
        //  更新lastPoint
        lastPoint = CGPointMake(point.x, point.y);
      }
    }
  }
  if (self.configuration.chartType == XGChartTypeBarChart) {
    for (XGChartPoint *point in self.drawingChartPoints) {
      [path moveToPoint:CGPointMake(point.x, point.y)];
      [path addLineToPoint:CGPointMake(point.x,
                                       self.chartHeight +
                                           self.configuration.paddingTop)];
    }
  }
  return path;
}

@end
