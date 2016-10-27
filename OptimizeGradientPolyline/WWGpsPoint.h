//
//  WWGpsPoint.h
//  TicweariOS
//
//  Created by 娄晓丹 on 16/9/27.
//  Copyright © 2016年 mobvoi. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface WWGpsPoint : NSObject

@property(nonatomic) double speed;                     // 该gps点的速度
@property(nonatomic) double distance;                  // 若为整公里，则显示公里数，否则显示为-1
@property(nonatomic) CLLocationCoordinate2D location;  // gps信息

@end
