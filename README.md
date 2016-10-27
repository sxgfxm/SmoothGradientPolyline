# SmoothGradientPolyline
iOS Gradient Polyline, 平滑渐变路径,CAGradientLayer,CAShapeLayer 

## Introduction

近年来，人们越来越注重运动锻炼，运动相关App层出不穷。其中运动路径追踪是一个重要的功能点。可以很容易的使用**MKPolyline**实现单色路径追踪。更进一步，如果想通过路径的不同颜色反映出运动过程中的速度变化，如**Nike+**类似的效果，需要更多的工作。本文主要讨论如何绘制**平滑渐变**的运动路径。

<!-- more -->

![](http://ofj92itlz.bkt.clouddn.com/GradientPolyline:nike+.jpeg)

![](http://ofj92itlz.bkt.clouddn.com/GradientPolyline:ditongfilter.jpeg)

上图为优化后的渐变色路径，图下方红色曲线为运动过程的速度曲线。

## 主要流程

1. 获取运动过程中GPS信息及对应的速度值；
2. 使用**低通滤波**处理速度数据；
3. 通过**MKMapView**转换坐标至对应大小的UIView；
4. 使用**CAGradientLayer**及**CAShaperLayer**分段绘制渐变路径；

## 获取运动过程中GPS信息及对应的速度值

可以使用**CoreLocation**获取GPS信息并计算对应的速度值。关于GPS坐标在中国大陆偏移及GPS坐标是否在中国大陆的判断方法，请参考[另一篇博文](https://sxgfxm.github.io/blog/2016/10/19/iospan-duan-gpszuo-biao-shi-fou-zai-zhong-guo/)。本文着重探讨路径的绘制，所以模拟产生随机的GPS和速度数据。

## 使用**低通滤波**处理速度数据

因为所绘路径的颜色不同，所以只能分段绘制。

如果各分段为纯色，则绘制出的路径略显生硬，无法体现出过渡效果（如下图）。

![](http://ofj92itlz.bkt.clouddn.com/GradientPolyline:pure.jpeg)

如果根据速度直接绘制成渐变色，因为速度波动的原因，渐变效果并不理想（如下图）。

![](http://ofj92itlz.bkt.clouddn.com/GradientPolyline:Gradient.jpeg)

所以需要预先处理速度数据，使速度数据变得平滑，渐变的效果才好。本人分别使用了**滑动窗口滤波**和**低通滤波**，对比之下，**低通滤波**表现更好。

![](http://ofj92itlz.bkt.clouddn.com/GradientPolyline:origin.jpeg)

上图为原数据效果。

![](http://ofj92itlz.bkt.clouddn.com/GradientPolyline:smoothwindow.jpeg)

上图为滑动窗口平滑效果。

![](http://ofj92itlz.bkt.clouddn.com/GradientPolyline:ditongfilter.jpeg)

上图为低通滤波平滑效果，滤波参数可以根据需要调整。

## 通过**MKMapView**转换坐标至对应大小的UIView

首先需要说明的是，本文的方法将路径绘制在与MKMapView大小一致的UIView上，而非直接以MKOverlay的形式绘制在MKMapView上，所以只能看到路径大致的轮廓而不能像地图一样缩放。如果想要在地图上直接绘制渐变路径，需要自定义**MKOverlayPathRenderer**，如有需要我再放出来。

坐标转换方法，调用MKMapView的`convertCoordinate:toPointToView:`方法，即可把地图上的GPS坐标，转换为与地图大小相同的CGPoint，为绘制路径做准备。

## 使用**CAGradientLayer**及**CAShaperLayer**分段绘制渐变路径

### 在**CAGradientLayer**上绘制对应的渐变颜色；

1、渐变方向需要根据路径方向计算；

```objective-c
gradientLayer.startPoint =
        CGPointMake(lastPoint.x / gradientView.frame.size.width,
                    lastPoint.y / gradientView.frame.size.height);
gradientLayer.endPoint =
        CGPointMake(newPoint.x / gradientView.frame.size.width,
                    newPoint.y / gradientView.frame.size.height);
```

2、渐变颜色为路径两端速度值映射后的颜色，推荐使用HSB颜色值映射；

```objective-c
CGFloat hue = points[i].speed / self.maxSpeed * self.maxHue;
UIColor *newColor =
        [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
gradientLayer.colors =
        @[ (__bridge id)(lastColor.CGColor), (__bridge id)(newColor.CGColor) ];
```

3、渐变起止可按需要自行控制；

```objective-c
gradientLayer.locations = @[ @(0.2), @(0.8) ];
```

### 在**CAShapeLayer**上绘制对应的路径；

1、路径的起止坐标为转换后的CGPoint；

2、注意设置`shapeLayer.lineCap = kCALineCapRound;`，否则路径会断；

3、注意`shapeLayer.strokeColor`不能为透明色，否则无法mask；

### 设置`gradientLayer.mask = shapeLayer`；

## 总结

绘制平滑渐变路径的关键在于速度数据的处理，大家可以尝试不同的滤波算法改进绘制效果。绘制路径的技巧也在文中列出，如有问题可以和我交流，大家共同探讨学习。

## Github源码

[SmoothGradientPolyline](https://github.com/sxgfxm/SmoothGradientPolyline)

