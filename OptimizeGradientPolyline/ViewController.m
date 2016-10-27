//
//  ViewController.m
//  OptimizeGradientPolyline
//
//  Created by 宋晓光 on 26/10/2016.
//  Copyright © 2016 Light. All rights reserved.
//

#import "ViewController.h"
#import "WWGpsPoint.h"
#import "XGChart.h"
#import <MapKit/MapKit.h>

@interface ViewController ()

@property(nonatomic, strong) NSMutableArray<WWGpsPoint *> *points;

@property(nonatomic, strong) NSMutableArray<WWGpsPoint *> *points2;

@property(nonatomic, strong) NSMutableArray<WWGpsPoint *> *points3;

@property(nonatomic, strong) NSMutableArray<WWGpsPoint *> *points4;

@property(nonatomic, strong) MKMapView *mapView;

@property(nonatomic, strong) MKMapView *mapView2;

@property(nonatomic, strong) MKMapView *mapView3;

@property(nonatomic, strong) MKMapView *mapView4;

@property(nonatomic, strong) UIView *route;

@property(nonatomic, strong) UIView *route2;

@property(nonatomic, strong) UIView *route3;

@property(nonatomic, strong) UIView *route4;

@property(nonatomic, assign) NSInteger count;

@property(nonatomic, assign) CGFloat maxSpeed;

@property(nonatomic, assign) CGFloat maxHue;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  //  count
  self.count = 200;
  //  max range
  self.maxSpeed = 10.0;
  self.maxHue = 0.3;
  //  模拟运动过程中GPS信息及对应的速度值
  //  points
  self.points = [[NSMutableArray alloc] init];
  CGFloat delta = 0.00001;
  CLLocationCoordinate2D coord =
      CLLocationCoordinate2DMake(39.9821418489, 116.3054959822);
  for (int i = 0; i < self.count / 4; i++) {
    WWGpsPoint *point = [[WWGpsPoint alloc] init];
    point.speed = arc4random_uniform(25) / 10.0 + arc4random_uniform(75) / 10.0;
    coord.latitude = coord.latitude + point.speed * delta;
    point.location = coord;
    [self.points addObject:point];
  }
  for (int i = 0; i < self.count / 4; i++) {
    WWGpsPoint *point = [[WWGpsPoint alloc] init];
    point.speed = arc4random_uniform(25) / 10.0 + arc4random_uniform(25) / 10.0;
    coord.longitude = coord.longitude + point.speed * delta;
    point.location = coord;
    [self.points addObject:point];
  }
  for (int i = 0; i < self.count / 4; i++) {
    WWGpsPoint *point = [[WWGpsPoint alloc] init];
    point.speed = arc4random_uniform(25) / 10.0 + arc4random_uniform(50) / 10.0;
    coord.latitude = coord.latitude - point.speed * delta;
    point.location = coord;
    [self.points addObject:point];
  }
  for (int i = 0; i < self.count / 4; i++) {
    WWGpsPoint *point = [[WWGpsPoint alloc] init];
    point.speed = arc4random_uniform(50) / 10.0 + arc4random_uniform(50) / 10.0;
    coord.longitude = coord.longitude - point.speed * delta;
    point.location = coord;
    [self.points addObject:point];
  }
  //  使用滑动窗口平滑和低通滤波处理速度数据
  //  points2
  self.points2 = [self filteredPoints2WithPoints:self.points unitWidth:5];
  //  points3
  self.points3 = [self filteredPoints3WithPoints:self.points];
  //  points4
  self.points4 = [self filteredPoints4WithPoints:self.points];

  //  scroll
  UIScrollView *scrollView =
      [[UIScrollView alloc] initWithFrame:self.view.bounds];
  scrollView.contentSize =
      CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 2);
  [self.view addSubview:scrollView];
  //  region
  CGFloat latMax = 0, lngMax = 0, latMin = 200, lngMin = 200;
  for (WWGpsPoint *point in self.points) {
    latMax =
        latMax < point.location.latitude ? point.location.latitude : latMax;
    lngMax =
        lngMax < point.location.longitude ? point.location.longitude : lngMax;
    latMin =
        latMin > point.location.latitude ? point.location.latitude : latMin;
    lngMin =
        lngMin > point.location.longitude ? point.location.longitude : lngMin;
  }
  //  mapView
  self.mapView = [[MKMapView alloc]
      initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 300)];
  self.mapView.showsBuildings = NO;
  self.mapView.showsPointsOfInterest = NO;
  self.mapView.region = MKCoordinateRegionMake(
      CLLocationCoordinate2DMake((latMin + latMax) / 2, (lngMin + lngMax) / 2),
      MKCoordinateSpanMake(latMax - latMin + 0.0005, lngMax - lngMin + 0.0005));
  [scrollView addSubview:self.mapView];
  //  mapView2
  self.mapView2 = [[MKMapView alloc]
      initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame) + 5,
                               self.view.bounds.size.width, 300)];
  self.mapView2.showsBuildings = NO;
  self.mapView2.showsPointsOfInterest = NO;
  self.mapView2.region = MKCoordinateRegionMake(
      CLLocationCoordinate2DMake((latMin + latMax) / 2, (lngMin + lngMax) / 2),
      MKCoordinateSpanMake(latMax - latMin + 0.0005, lngMax - lngMin + 0.0005));
  [scrollView addSubview:self.mapView2];
  //  mapView3
  self.mapView3 = [[MKMapView alloc]
      initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView2.frame) + 5,
                               self.view.bounds.size.width, 300)];
  self.mapView3.showsBuildings = NO;
  self.mapView3.showsPointsOfInterest = NO;
  self.mapView3.region = MKCoordinateRegionMake(
      CLLocationCoordinate2DMake((latMin + latMax) / 2, (lngMin + lngMax) / 2),
      MKCoordinateSpanMake(latMax - latMin + 0.0005, lngMax - lngMin + 0.0005));
  [scrollView addSubview:self.mapView3];
  //  mapView4
  self.mapView4 = [[MKMapView alloc]
      initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView3.frame) + 5,
                               self.view.bounds.size.width, 300)];
  self.mapView4.showsBuildings = NO;
  self.mapView4.showsPointsOfInterest = NO;
  self.mapView4.region = MKCoordinateRegionMake(
      CLLocationCoordinate2DMake((latMin + latMax) / 2, (lngMin + lngMax) / 2),
      MKCoordinateSpanMake(latMax - latMin + 0.0005, lngMax - lngMin + 0.0005));
  [scrollView addSubview:self.mapView4];

  //  route
  self.route = [self gradientViewWithMap:self.mapView points:self.points];
  self.route.backgroundColor =
      [[UIColor blackColor] colorWithAlphaComponent:0.5];
  [scrollView addSubview:self.route];
  //  route2
  self.route2 = [self gradientViewWithMap:self.mapView2 points:self.points2];
  self.route2.backgroundColor =
      [[UIColor blackColor] colorWithAlphaComponent:0.5];
  [scrollView addSubview:self.route2];
  //  route3
  self.route3 = [self gradientViewWithMap:self.mapView3 points:self.points3];
  self.route3.backgroundColor =
      [[UIColor blackColor] colorWithAlphaComponent:0.5];
  [scrollView addSubview:self.route3];
  //  route4
  self.route4 = [self gradientViewWithMap:self.mapView4 points:self.points4];
  self.route4.backgroundColor =
      [[UIColor blackColor] colorWithAlphaComponent:0.5];
  [scrollView addSubview:self.route4];

  //  configuration
  XGChartConfiguration *configuration = [[XGChartConfiguration alloc] init];
  configuration.chartType = XGChartTypeLineChart;
  configuration.paddingTop = 20;
  configuration.paddingLeft = 20;
  configuration.paddingBottom = 20;
  configuration.paddingRight = 20;
  configuration.xGridCount = 0;
  configuration.yGridCount = 4;
  configuration.gridColor = [UIColor grayColor];
  configuration.xAxisLabelColor = [UIColor whiteColor];
  configuration.xAxisLabelFontSize = 12;
  configuration.yAxisLabelColor = [UIColor whiteColor];
  configuration.yAxisLabelFontSize = 12;
  NSMutableArray<XGChartPoint *> *chartPoints = [[NSMutableArray alloc] init];
  for (int i = 0; i < self.points.count; i++) {
    XGChartPoint *point =
        [[XGChartPoint alloc] initWithX:i andY:self.points[i].speed];
    [chartPoints addObject:point];
  }
  configuration.chartPoints = chartPoints;
  configuration.strokeColor = [UIColor redColor];
  configuration.fillColor = [UIColor redColor];
  configuration.lineWidth = 1;
  //  line chart
  XGChart *lineChart = [[XGChart alloc]
      initWithFrame:CGRectMake(0, CGRectGetMaxY(self.route.frame) -
                                      self.route.bounds.size.height / 2 + 10,
                               self.view.bounds.size.width,
                               self.route.bounds.size.height / 2 - 10)
      configuration:configuration];

  [scrollView addSubview:lineChart];
  //  line chart2
  NSMutableArray<XGChartPoint *> *chartPoints2 = [[NSMutableArray alloc] init];
  for (int i = 0; i < self.points2.count; i++) {
    XGChartPoint *point =
        [[XGChartPoint alloc] initWithX:i andY:self.points2[i].speed];
    [chartPoints2 addObject:point];
  }
  configuration.chartPoints = chartPoints2;
  XGChart *lineChart2 = [[XGChart alloc]
      initWithFrame:CGRectMake(0, CGRectGetMaxY(self.route2.frame) -
                                      self.route.bounds.size.height / 2 + 10,
                               self.view.bounds.size.width,
                               self.route.bounds.size.height / 2 - 10)
      configuration:configuration];

  [scrollView addSubview:lineChart2];

  //  line chart3
  NSMutableArray<XGChartPoint *> *chartPoints3 = [[NSMutableArray alloc] init];
  for (int i = 0; i < self.points3.count; i++) {
    XGChartPoint *point =
        [[XGChartPoint alloc] initWithX:i andY:self.points3[i].speed];
    [chartPoints3 addObject:point];
  }
  configuration.chartPoints = chartPoints3;
  XGChart *lineChart3 = [[XGChart alloc]
      initWithFrame:CGRectMake(0, CGRectGetMaxY(self.route3.frame) -
                                      self.route.bounds.size.height / 2 + 10,
                               self.view.bounds.size.width,
                               self.route.bounds.size.height / 2 - 10)
      configuration:configuration];

  [scrollView addSubview:lineChart3];

  //  line chart4
  NSMutableArray<XGChartPoint *> *chartPoints4 = [[NSMutableArray alloc] init];
  for (int i = 0; i < self.points4.count; i++) {
    XGChartPoint *point =
        [[XGChartPoint alloc] initWithX:i andY:self.points4[i].speed];
    [chartPoints4 addObject:point];
  }
  configuration.chartPoints = chartPoints4;
  XGChart *lineChart4 = [[XGChart alloc]
      initWithFrame:CGRectMake(0, CGRectGetMaxY(self.route4.frame) -
                                      self.route.bounds.size.height / 2 + 10,
                               self.view.bounds.size.width,
                               self.route.bounds.size.height / 2 - 10)
      configuration:configuration];

  [scrollView addSubview:lineChart4];
}

#pragma mark - filters
//  滑动窗口滤波
- (NSMutableArray<WWGpsPoint *> *)
filteredPoints2WithPoints:(NSMutableArray<WWGpsPoint *> *)points
                unitWidth:(NSInteger)unitWidht {
  NSMutableArray *filterdPoints = [[NSMutableArray alloc] init];

  NSInteger index = 0;
  while (index < points.count - unitWidht) {
    CGFloat speed = 0;
    CGFloat max = 0, min = 20;
    for (NSInteger i = index; i < unitWidht + index; i++) {
      max = max < points[i].speed ? points[i].speed : max;
      min = min > points[i].speed ? points[i].speed : min;
      speed += points[i].speed;
    }
    WWGpsPoint *point = [[WWGpsPoint alloc] init];
    point.location = points[index].location;
    point.speed = (speed - max - min) / (unitWidht - 2);
    [filterdPoints addObject:point];

    index = index + 1;
  }

  return filterdPoints;
}

//  低通滤波
- (NSMutableArray<WWGpsPoint *> *)filteredPoints3WithPoints:
    (NSMutableArray<WWGpsPoint *> *)points {
  NSMutableArray *filterdPoints = [[NSMutableArray alloc] init];
  CGFloat speed = 0;
  CGFloat alpha = 0.05;
  BOOL isFirst = YES;
  for (WWGpsPoint *point in points) {
    if (isFirst) {
      isFirst = NO;
      speed = point.speed;
      WWGpsPoint *point2 = [[WWGpsPoint alloc] init];
      point2.location = point.location;
      point2.speed = speed;
      [filterdPoints addObject:point2];
    } else {
      speed = alpha * point.speed + (1 - alpha) * speed;
      WWGpsPoint *point2 = [[WWGpsPoint alloc] init];
      point2.location = point.location;
      point2.speed = speed;
      [filterdPoints addObject:point2];
    }
  }
  return filterdPoints;
}

//  低通滤波
- (NSMutableArray<WWGpsPoint *> *)filteredPoints4WithPoints:
    (NSMutableArray<WWGpsPoint *> *)points {
  NSMutableArray *filterdPoints = [[NSMutableArray alloc] init];
  CGFloat speed = 0;
  CGFloat alpha = 0.025;
  BOOL isFirst = YES;
  for (WWGpsPoint *point in points) {
    if (isFirst) {
      isFirst = NO;
      speed = point.speed;
      WWGpsPoint *point2 = [[WWGpsPoint alloc] init];
      point2.location = point.location;
      point2.speed = speed;
      [filterdPoints addObject:point2];
    } else {
      speed = alpha * point.speed + (1 - alpha) * speed;
      WWGpsPoint *point2 = [[WWGpsPoint alloc] init];
      point2.location = point.location;
      point2.speed = speed;
      [filterdPoints addObject:point2];
    }
  }

  return filterdPoints;
}

#pragma mark - gradient polyline
//  gradient polyline
- (UIView *)gradientViewWithMap:(MKMapView *)mapView
                         points:(NSMutableArray<WWGpsPoint *> *)points {
  UIView *gradientView = [[UIView alloc] initWithFrame:mapView.frame];
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  //  通过MKMapView转换坐标至对应大小的UIView
  for (WWGpsPoint *point in points) {
    [arr addObject:[NSValue
                       valueWithCGPoint:[mapView
                                            convertCoordinate:point.location
                                                toPointToView:gradientView]]];
  }
  //  画线
  UIBezierPath *path = [UIBezierPath bezierPath];
  UIColor *lastColor =
      [UIColor colorWithHue:0 saturation:1 brightness:1 alpha:1];
  for (int i = 1; i < arr.count; i++) {
    CGPoint lastPoint = [arr[i - 1] CGPointValue];
    CGPoint newPoint = [arr[i] CGPointValue];
    //  gradientLayer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = gradientView.bounds;
    CGFloat hue = points[i].speed / self.maxSpeed * self.maxHue;
    UIColor *newColor =
        [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    gradientLayer.colors =
        @[ (__bridge id)(lastColor.CGColor), (__bridge id)(newColor.CGColor) ];
    gradientLayer.locations = @[ @(0.2), @(0.8) ];
    gradientLayer.startPoint =
        CGPointMake(lastPoint.x / gradientView.frame.size.width,
                    lastPoint.y / gradientView.frame.size.height);
    gradientLayer.endPoint =
        CGPointMake(newPoint.x / gradientView.frame.size.width,
                    newPoint.y / gradientView.frame.size.height);
    [gradientView.layer addSublayer:gradientLayer];
    //  shapeLayer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = gradientView.bounds;
    [path moveToPoint:lastPoint];
    [path addLineToPoint:newPoint];
    shapeLayer.path = path.CGPath;
    shapeLayer.lineWidth = 5;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    gradientLayer.mask = shapeLayer;
    //  reset
    [path removeAllPoints];
    lastColor = newColor;
  }
  return gradientView;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
