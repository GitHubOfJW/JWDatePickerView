//
//  JWDatePickerView.h
//  JWDatePickerView
//
//  Created by 朱建伟 on 16/7/19.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

#import <UIKit/UIKit.h>

 
typedef NS_ENUM(NSUInteger,JWDatePickerMode)
{
    JWDatePickerMode_DateAndTime,// 年月日 时 分 秒  4
    JWDatePickerMode_DateAndTimeRYear,//  月日 时 分 秒 4
    JWDatePickerMode_Time,// 时分秒  3
    JWDatePickerMode_Date,// 年月日  3
    JWDatePickerMode_DateAddHour,// 年 月 日 时  4
    JWDatePickerMode_DateAndTimeRSecond,// 年月日  时 分 3
    JWDatePickerMode_DateAndTimeRYearAndSecond//月日 时 分  3
};

@class JWDatePickerView;
/**
 *  代理方法
 */
@protocol JWDatePickerViewDelegate <NSObject>

/**
 *  返回单位文字  比如说 参数NSCalendarUnitYear 返回 年  例如 2016年  没有则返回@""或者nil
 */
-(NSString*)datePickerView:(JWDatePickerView*)datePickerView unitForCalendarUnit:(NSCalendarUnit)calendarUnit;

@end

@interface JWDatePickerView : UIView

/**
 *  delegate
 */
@property(nonatomic,weak)id<JWDatePickerViewDelegate> delegate;

/**
 *   最小日期 如果是 不显示年的模式下 自动将最大日期设置在 一年内   只显示时分秒的同理
 */
@property(nonatomic,strong)NSDate* minDate;

/**
 *  当前日期  如果比最小日期小，设置最小日期为 date
 */
@property(nonatomic,strong)NSDate* date;

/**
 *   最大日起  如果是 不显示年的模式下 自动将最小日期设置在 一年内   只显示时分秒的同理
 */
@property(nonatomic,strong)NSDate* maxDate;

/**
 *  pickerModel
 */
@property(nonatomic,assign)JWDatePickerMode pickerMode;


/**
 *  font
 */
@property(nonatomic,strong)UIFont* font;
 
 

/**
 *  minuteSpace   分钟间隔  条件 minuteSpace<30&&60%minuteSpace==0
 */
@property(nonatomic,assign)NSUInteger minuteSpace;

/**
 *  secondSpace   秒间隔  条件 secondSpace<30&&60%secondSpace==0
 */
@property(nonatomic,assign)NSUInteger secondSpace;

/**
 *  刷新数据
 */
-(void)reloadData;


/**
 *  四舍五入  date 数据
 */
-(NSDate*)getRoundDateWithDate:(NSDate*)date;

/**
 *  获取一天中的  最小时间00:00:00  最大时间 23:59:59
 */
-(NSDate*)getDayLastDateWithDate:(NSDate*)date  max:(BOOL)isGetMax;

/**
 *  获取日期字符串
 */
-(NSString*)getDateStr;
/**
 *  获取日期字符串
 */
-(NSString*)getDateStrWithDateFormatterString:(NSString*)formatterStr;
@end
