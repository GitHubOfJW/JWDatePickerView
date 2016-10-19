//
//  JWDatePickerView.m
//  JWDatePickerView
//
//  Created by 朱建伟 on 16/7/19.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//
#define KSplit @"(#拆#)"//用来拆分

#define KTotalFormatter @"yyyy MM dd HH mm ss"
#define KTotalFormatterStr @"%@ %@ %@ %@ %@ %@"

#define KComUnit NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond


#import "JWDatePickerView.h"

@interface JWDatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
/**
 *  bgView
 */
@property(nonatomic,strong)UIView* bgView;
/**
 *  pickerView
 */
@property(nonatomic,strong)UIPickerView* pickerView;

/**
 *  modeDict
 */
@property(nonatomic,strong)NSMutableDictionary<NSNumber*,NSArray*>* modeDict;
/**
 *  formatterDict
 */
@property(nonatomic,strong)NSMutableDictionary* formatterDict;

/**
 *  unitdict
 */
@property(nonatomic,strong)NSMutableDictionary* unitStrDict;

/**
 *  calendar
 */
@property(nonatomic,strong)NSCalendar* calendar;

/**
 *  dateFormmater
 */
@property(nonatomic,strong)NSDateFormatter* dateF;

 
/**
 *  formmater
 */
@property(nonatomic,strong)NSDateFormatter* simpleDateF;

/**
 *  tempComps
 */
@property(nonatomic,strong)NSDateComponents *tempDateComps;


@end

@implementation JWDatePickerView

/**
 *  初始化控件
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.minuteSpace = 1;
        self.secondSpace = 1;
        
        self.bgView = [[UIView alloc] init]; 
        [self addSubview:self.bgView];
        
        //模式
        self.pickerMode =  JWDatePickerMode_DateAddHour;
        self.font = [UIFont boldSystemFontOfSize:16];
        
        //pickerView
        self.pickerView =  [[UIPickerView alloc] init];
        self.pickerView.backgroundColor = [UIColor whiteColor];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        [self.bgView addSubview:self.pickerView];
        
    }
    return self;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //返回对应模式下的compsCount
//    if (self.pickerMode==JWDatePickerMode_DateAndTime||self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAddHour) {
//        return 4;
//    }else if (self.pickerMode==JWDatePickerMode_TimeRSecond)
//    {
//        return 2;
//    }
//    return 3;
    return   [self.modeDict objectForKey:@(self.pickerMode)].count;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray* groupUnitArray  = self.modeDict[@(self.pickerMode)];
    if (component>=groupUnitArray.count) {
        return 0;
    }
    NSNumber* number =  [groupUnitArray[component] lastObject];
    
    switch (number.unsignedIntegerValue) {
        case NSCalendarUnitYear:
        {
            NSInteger  year=  [self.calendar component:number.unsignedIntegerValue fromDate:[self getMaxDate]]-[self.calendar component:number.unsignedIntegerValue fromDate:[self getMinDate]]+1;
 

            return year;
            break;
        }
        case NSCalendarUnitMonth:
            return 12;
            break;
        case NSCalendarUnitDay:
        {
             if (self.pickerMode==JWDatePickerMode_Date||self.pickerMode==JWDatePickerMode_DateAddHour) {//这个模式下 年 月 日  或者  年 月 日 时
                 //根据年月日刷新 天数
                 NSInteger days =[self getMonthDaysWithYear:self.tempDateComps.year andMoth:self.tempDateComps.month];
                 return days;
             }else
             {
                 
                 return  [self.calendar components:number.unsignedIntegerValue fromDate:[self getMinDate]  toDate:[self getMaxDate] options:NSCalendarMatchLast].day+1;
             }
            break;
        }
        case NSCalendarUnitHour:
            return 24;
            break;
        
        case NSCalendarUnitMinute: 
            return 60/self.minuteSpace;
            break;
        
        case NSCalendarUnitSecond: 
            return 60/self.secondSpace;
            break;
        default:
            break;
    }
    
    return 1;
}



-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    
    NSArray* groupUnitArray  = self.modeDict[@(self.pickerMode)];
    
    if (component>=groupUnitArray.count) {
        return @"";
    }
    NSNumber* number =  [groupUnitArray[component] lastObject];
    
    switch (number.unsignedIntegerValue) {
        case NSCalendarUnitYear:// 年月日 模式下用
        {
            NSDateComponents*dateComps = [[NSDateComponents alloc] init];
            dateComps.year = row;
            NSDate* date =  [self.calendar dateByAddingComponents:dateComps toDate:[self getMinDate] options:NSCalendarMatchLast];
            
            NSArray*dateArray = [[self.dateF stringFromDate:date] componentsSeparatedByString:KSplit];
            
            return dateArray[component];
            break;
        }
        case NSCalendarUnitMonth://年 月 日  模式下用
        {
            return  [NSString stringWithFormat:@"%02zd%@",row+1,self.unitStrDict[@(NSCalendarUnitMonth)]];
            break;
        }
        case NSCalendarUnitDay:
        {
            if (self.pickerMode==JWDatePickerMode_Date||self.pickerMode==JWDatePickerMode_DateAddHour) {//这个模式下 单独选择日期
                return [NSString stringWithFormat:@"%02zd%@",row+1,self.unitStrDict[@(NSCalendarUnitDay)]];
            }else
            {
                NSDateComponents*dateComps = [[NSDateComponents alloc] init];
                dateComps.day = row;
                NSDate* date =  [self.calendar dateByAddingComponents:dateComps toDate:[self getMinDate] options:NSCalendarMatchLast];
                
                NSArray*dateArray = [[self.dateF stringFromDate:date] componentsSeparatedByString:KSplit];
                
                return dateArray[component];
            }
            break;
        }
        case NSCalendarUnitHour:
        {
            return  [NSString stringWithFormat:@"%02zd%@",row,self.unitStrDict[@(NSCalendarUnitHour)]];
            break;
        }
        case NSCalendarUnitMinute:
        {
            return [NSString stringWithFormat:@"%02zd%@",self.minuteSpace*row,self.unitStrDict[@(NSCalendarUnitMinute)]];
            break;
        }
        case NSCalendarUnitSecond:
        {
            return [NSString stringWithFormat:@"%02zd%@",self.secondSpace*row,self.unitStrDict[@(NSCalendarUnitSecond)]];
            break;
        }
        default:
        {
            return  @"return void";
            break;
        }
    }
    
}

/**
 *  选中完日期之后
 */
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
  
          //用于拼接日期
        __block  NSMutableString* m_str = [NSMutableString string];
        
    
        if (self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAndTimeRYearAndSecond) {//前面拼 年
            //同年可用
            NSInteger yearRow = [self.pickerView selectedRowInComponent:0];
            NSDateComponents*dateComps = [[NSDateComponents alloc] init];
            dateComps.day = yearRow;
            NSDate* date =  [self.calendar dateByAddingComponents:dateComps toDate:[self getMinDate] options:NSCalendarMatchLast];
            NSDateComponents* comps = [self.calendar components:KComUnit fromDate:date];

             [m_str appendFormat:@"%@%@",[NSString stringWithFormat:@"%02zd",comps.year],self.unitStrDict[@(NSCalendarUnitYear)]];
        }else if (self.pickerMode == JWDatePickerMode_Time||self.pickerMode==JWDatePickerMode_TimeRSecond)//前面拼接 年月日
        {
            //同年可用
            NSDateComponents* comps = [self.calendar components:KComUnit fromDate:[self getMinDate]];
            //yyyy年MM月dd号
            [m_str appendFormat:@"%@%@%@%@%@%@%@",[NSString stringWithFormat:@"%02zd",comps.year],self.unitStrDict[@(NSCalendarUnitYear)],[NSString stringWithFormat:@"%02zd",comps.month],self.unitStrDict[@(NSCalendarUnitMonth)],[NSString stringWithFormat:@"%02zd",comps.day],self.unitStrDict[@(NSCalendarUnitDay)],KSplit];
        }
    
        NSArray* groupArray = self.modeDict[@(self.pickerMode)];
    
    
        [groupArray enumerateObjectsUsingBlock:^(NSArray* _Nonnull unitArray, NSUInteger idxOut, BOOL * _Nonnull stop) {
            //拼接拆分
            if (idxOut!=0) {
                [m_str appendString:KSplit];
            }
            //选择项
            NSInteger row =  [self.pickerView selectedRowInComponent:idxOut];
             NSString *title = [self pickerView:pickerView titleForRow:row forComponent:idxOut];
            
            if (self.pickerMode==JWDatePickerMode_Date||self.pickerMode==JWDatePickerMode_DateAddHour){
                //记录 day 对应的component
                if ([unitArray.lastObject unsignedIntegerValue]==NSCalendarUnitYear) {
                    NSDateComponents*dateComps = [[NSDateComponents alloc] init];
                    dateComps.year = row;
                    NSDate* date =  [self.calendar dateByAddingComponents:dateComps toDate:[self getMinDate] options:NSCalendarMatchLast];
                    self.tempDateComps.year = [self.calendar components:KComUnit fromDate:date].year;
                    
                }else if ([unitArray.lastObject unsignedIntegerValue]==NSCalendarUnitMonth)
                {
                    
                    self.tempDateComps.month = row+1;
                }
                else if ([unitArray.lastObject unsignedIntegerValue]==NSCalendarUnitDay) {
                    //获取到当前row  和刷新后的rowCount 比较
                    NSInteger newRowCount= [self pickerView:pickerView numberOfRowsInComponent:idxOut];
                    if (row>=newRowCount) {
                        [self.pickerView selectRow:newRowCount-1 inComponent:idxOut animated:NO];
                        
                        title = [NSString stringWithFormat:@"%02zd%@",newRowCount,self.unitStrDict[@(NSCalendarUnitDay)]];
                    }
                    [self.pickerView reloadAllComponents];
                }
            }
            [m_str appendString:title];
            
        }];
    
    
    NSDate* date = [self.simpleDateF dateFromString:m_str];
    
    if (!date) {
        NSLog(@"Date is nil");
        return;
    }
   
    if(date){[self checkWithSelectedDate:date];}else{NSLog(@"Date 为 nil");}
    
        
}


/**
 *  根据选择的时间  验证最大时间和最小时间 可以择调用回调
 */
-(void)checkWithSelectedDate:(NSDate*)date
{
    if ([date compare:self.maxDate]==NSOrderedDescending){
        _date  = self.maxDate;
        [self scrollToCurrentDate:self.date animated:YES];
    }else if ([date compare:self.minDate]==NSOrderedAscending) {
        _date =  self.minDate;
        [self scrollToCurrentDate:self.date animated:YES];
    }else
    {
         _date = date;
    }
}


/**
 *  四舍五入  date 数据
 */
-(NSDate*)getRoundDateWithDate:(NSDate*)date
{
    NSDateComponents *com  = [self.calendar components:KComUnit fromDate:date];
     
    NSInteger day = com.day;

    NSInteger hour = com.hour;
    
    NSInteger addMinute = 0;
    
    
    NSInteger second =  (com.second%self.secondSpace?com.second/self.secondSpace+1:com.second/self.secondSpace)*self.secondSpace;
   
    if (second>(60-self.secondSpace)) {//进分钟
        second = 0;
        addMinute = 1;
    }
    
    NSInteger minute =  ((com.minute+addMinute)%self.minuteSpace?(com.minute+addMinute)/self.minuteSpace+1:(com.minute+addMinute)/self.minuteSpace)*self.minuteSpace;
    
    NSDateComponents*coms = [[NSDateComponents alloc] init];
    coms.day = day-com.day;
    coms.hour =  hour-com.hour;
    coms.minute =  minute-com.minute;
    coms.second =  second-com.second;
    NSDate *newDate = [self.calendar dateByAddingComponents:coms toDate:date options:NSCalendarMatchLast];
    return newDate;
}

 

/**
 *  宽度
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    NSInteger coms = [self numberOfComponentsInPickerView:self.pickerView];
    CGFloat width =  self.bounds.size.width-(coms-1)*10;
    
    NSString* formatterStr  = [self getDateFormatterWithPickModel:self.pickerMode];
    NSArray* array = [formatterStr componentsSeparatedByString:KSplit];
    
    __block NSUInteger maxLength = 0;
    [array enumerateObjectsUsingBlock:^(NSString*  _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        maxLength+=str.length;
    }];
    return width/maxLength*[array[component] length];
}

/**
 *  高度
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return (self.bounds.size.height-20)/4;
}




-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel* label = nil;
    if (view&&[view isKindOfClass:[UILabel class]]) {
        label =(UILabel*)view;
    }else
    {
        label= [[UILabel alloc] init];
        label.textAlignment =NSTextAlignmentCenter;
        label.font =self.font?self.font:[UIFont systemFontOfSize:16];
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}



/**
 *  布局
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgView.frame = self.bounds;
    
    CGFloat pickerX = 0;
    CGFloat pickerY = 10;
    CGFloat pickerW = self.bounds.size.width;
    CGFloat pickerH = self.bounds.size.height-20;
    self.pickerView.frame= CGRectMake(pickerX, pickerY, pickerW, pickerH);
    
}



/**
 *  设置dateFormmater
 */
-(NSString*)getDateFormatterWithPickModel:(JWDatePickerMode)mode
{
   __block  NSMutableString* m_str = [NSMutableString string];
    
    NSArray* groupArray = self.modeDict[@(mode)];
    
    
    [groupArray enumerateObjectsUsingBlock:^(NSArray* _Nonnull unitArray, NSUInteger idx, BOOL * _Nonnull stop) {
        //拼接拆分
        if (idx!=0) {
            [m_str appendString:KSplit];
        }
        //遍历模式
        [unitArray enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull unitNumber, NSUInteger idx, BOOL * _Nonnull stop) {
            //拼接日历格式化字符串
            [m_str appendString:(self.formatterDict[unitNumber])];
            
            //拼接单位
            if (self.delegate&&[self.delegate respondsToSelector:@selector(datePickerView:unitForCalendarUnit:)]) {
                NSString* unitStr = self.unitStrDict[unitNumber];
                 [m_str appendString:unitStr];
            }
        }];
    }];
   return   m_str;
    
}



/**
 *  滚动到指定的位置
 */
-(void)reloadDataNeedScrollTo:(BOOL)need
{
    
    [self.pickerView reloadAllComponents];
    
    
    [self.pickerView setNeedsLayout];
    
    
    if([self getCurrentDate]&&need)//滑动到显示时间
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollToCurrentDate:[self getCurrentDate] animated:YES];
        });
    }
}

/**
 *  滚动到指定的时间
 */
-(void)scrollToCurrentDate:(NSDate*)date animated:(BOOL)animated
{
   
    NSArray* groupUnitArray  = self.modeDict[@(self.pickerMode)];
    
    [groupUnitArray enumerateObjectsUsingBlock:^(NSArray*  _Nonnull unitArray, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSNumber *number = unitArray.lastObject;
        //获取的对应的组的rowCount
        NSInteger maxRowCount =  [self pickerView:self.pickerView numberOfRowsInComponent:idx];
        //分项处理
        switch (number.unsignedIntegerValue) {
            case NSCalendarUnitYear:// 年月日 模式下用
            {
                NSInteger  year=  [self.calendar component:number.unsignedIntegerValue fromDate:date]-[self.calendar component:number.unsignedIntegerValue fromDate:[self getMinDate]];
                
                if (year<maxRowCount) {
                    [self.pickerView selectRow:year inComponent:idx animated:animated];
                }
                break;
            }
            case NSCalendarUnitMonth://年 月 日  模式下用
            {
                
                NSInteger month= [self.calendar component:number.unsignedIntegerValue fromDate:date];
                if (month-1<maxRowCount) {
                    [self.pickerView selectRow:month-1 inComponent:idx animated:animated];
                }
                break;
            }
            case NSCalendarUnitDay:
            {
                if(self.pickerMode==JWDatePickerMode_Date||self.pickerMode==JWDatePickerMode_DateAddHour)//年月日
                {
                    NSInteger day = [self.calendar component:number.unsignedIntegerValue fromDate:date];
                    if (day-1<maxRowCount) {
                        [self.pickerView selectRow:day-1 inComponent:idx animated:animated];
                    }
                }else
                {
                    NSInteger day= [self.calendar components:number.unsignedIntegerValue fromDate:[self getMinDate] toDate:date options:NSCalendarMatchLast].day;
                    if (day<maxRowCount) {
                        [self.pickerView selectRow:day inComponent:idx animated:animated];
                    }
                }
                break;
            }
            case NSCalendarUnitHour:
            {
                NSInteger hour= [self.calendar component:number.unsignedIntegerValue fromDate:date];
                if (hour<maxRowCount) {
                    [self.pickerView selectRow:hour inComponent:idx animated:animated];
                }
                break;
            }
            case NSCalendarUnitMinute:
            {
                NSInteger minute= [self.calendar component:number.unsignedIntegerValue fromDate:date];
                if (minute/self.minuteSpace<maxRowCount) {
                    [self.pickerView selectRow:minute/self.minuteSpace inComponent:idx animated:animated];
                }
                break;
            }
            case NSCalendarUnitSecond:
            {
                NSInteger second= [self.calendar component:number.unsignedIntegerValue fromDate:date];
                if (second/self.secondSpace<maxRowCount) {
                    [self.pickerView selectRow:second/self.secondSpace inComponent:idx animated:animated];
                }

                break;
            }
            default:
            { 
                break;
            }
        }
    }];
}

/**
 *  设置当前日期
 */
-(void)setDate:(NSDate *)date
{
    if (!date) {
        return;
    }
    
    _date = [self getRoundDateWithDate:date];
    
    //年 月  日 单选
    if(self.pickerMode==JWDatePickerMode_Date||self.pickerMode==JWDatePickerMode_DateAddHour){
        NSDateComponents *comps= [self.calendar components:KComUnit fromDate:_date];
        self.tempDateComps.year=comps.year;
        self.tempDateComps.month =  comps.month;
    }
    //如果当前日期比最小日期大 那么最小日期就是当前日期
    if (self.minDate) {
        if ([self.minDate compare:_date]==NSOrderedDescending) {
            self.minDate = _date;
        }
    }else
    {
        self.minDate = date;
    }
    
    [self reloadDataNeedScrollTo:YES];
}


/**
 *  设置最小时间
 */
-(void)setMinDate:(NSDate *)minDate
{
    if (!minDate) {
        return;
    }
    
    //验证
    if (self.maxDate&&[_minDate compare:self.maxDate]==NSOrderedDescending) {
        return;
    }
    
    _minDate= [self getRoundDateWithDate:minDate];
    
    
    //如果当前日期没有值 设置当前日期为最小日期 ，如果存在则判断
    if (!self.date) {
        self.date = _minDate;
    }else
    {
        //如果最小日期的时间 比 当前时间大 那么当前时间就设置为最小日期的时间
        if ([self.minDate compare:self.date]==NSOrderedDescending) {
            self.date = self.minDate;
        }
    }
    
    //1.判断当前的最大时间有没有值 如果没有值 则计算赋值
    if(self.maxDate)//如果最小时间有值的话则 验证时差
    {
        if (self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAndTimeRYearAndSecond) {//同一年
            // 最大时间1年前的时间 compare 最小时间
            NSDateComponents*dateComps = [[NSDateComponents alloc] init];
            dateComps.year = 1;
            dateComps.day = -1;
            NSDate* lastMaxDate =  [self.calendar dateByAddingComponents:dateComps toDate:self.minDate options:NSCalendarMatchLast];
            if ([lastMaxDate compare:self.maxDate]==NSOrderedAscending) {
                self.maxDate = lastMaxDate;
            }
        }else if (self.pickerMode==JWDatePickerMode_Time||self.pickerMode==JWDatePickerMode_TimeRSecond)//同一天
        {
            NSDate* lastMaxDate =  [self getDayLastDateWithDate:self.minDate max:YES];
            if ([lastMaxDate compare:self.maxDate]==NSOrderedAscending) {
                self.maxDate = lastMaxDate;
            }
        }
    }

    if (!self.date) {
        self.date = self.minDate;
    }
    
    [self reloadDataNeedScrollTo:NO];
    
}

/**
 *  设置最大日期
 */
-(void)setMaxDate:(NSDate *)maxDate
{
    if (!maxDate) {
        return;
    }
    
    //验证 最大日期不能比最小日期小
    if(self.minDate&&[_maxDate compare:self.minDate]==NSOrderedAscending)
    {
        return;
    }

    
    _maxDate= [self getRoundDateWithDate:maxDate];
    
    
    //1.判断当前的最小时间有没有值 如果没有值 则计算赋值
    if(self.minDate)
    {
        
        if (self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAndTimeRYearAndSecond) {//同一年
            // 最大时间1年前的时间 compare 最小时间
            NSDateComponents*dateComps = [[NSDateComponents alloc] init];
            dateComps.year = -1;
            dateComps.day = 1;
            NSDate* lastMinDate =  [self.calendar dateByAddingComponents:dateComps toDate:self.minDate options:NSCalendarMatchLast];
            if ([lastMinDate compare:self.minDate]==NSOrderedDescending) {
                self.minDate = lastMinDate;
            }
        }else if (self.pickerMode==JWDatePickerMode_Time||self.pickerMode ==JWDatePickerMode_TimeRSecond)//同一天
        {
            NSDate* lastMinDate =  [self getDayLastDateWithDate:self.maxDate max:NO];
            if ([lastMinDate compare:self.minDate]==NSOrderedDescending) {
                self.minDate = lastMinDate;
            }
        }
    }
    
    [self reloadDataNeedScrollTo:NO];
}


/**
 *  刷新
 */
-(void)reloadData
{ 
    [self scrollToCurrentDate:[self getCurrentDate] animated:YES];
}

/**
 *  日历
 */
-(NSCalendar *)calendar
{
    if (_calendar==nil) {
        _calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
    }
    return _calendar;
}

/**
 *  字典
 */
-(NSMutableDictionary<NSNumber*,NSArray*>*)modeDict
{
    if (_modeDict==nil) {
        _modeDict =  [NSMutableDictionary dictionary];
        //        JWDatePickerMode_DateAndTime,// 年月日 时分秒
        _modeDict[@(JWDatePickerMode_DateAndTime)]= @[@[@(NSCalendarUnitYear),@(NSCalendarUnitMonth),@(NSCalendarUnitDay)],@[@(NSCalendarUnitHour)],@[@(NSCalendarUnitMinute)],@[@(NSCalendarUnitSecond)]];
        
        //        JWDatePickerMode_Time,// 时分秒
        _modeDict[@(JWDatePickerMode_Time)]= @[@[@(NSCalendarUnitHour)],@[@(NSCalendarUnitMinute)],@[@(NSCalendarUnitSecond)]];
        
        
        //        JWDatePickerMode_TimeRSecond,// 时分
        _modeDict[@(JWDatePickerMode_TimeRSecond)]= @[@[@(NSCalendarUnitHour)],@[@(NSCalendarUnitMinute)]];
        
        //        JWDatePickerMode_Date,// 年月日
        _modeDict[@(JWDatePickerMode_Date)]= @[@[@(NSCalendarUnitYear)],@[@(NSCalendarUnitMonth)],@[@(NSCalendarUnitDay)]];
        
        //        JWDatePickerMode_DateAndTimeRYear,//  月日 时 分 秒
        _modeDict[@(JWDatePickerMode_DateAndTimeRYear)]= @[@[@(NSCalendarUnitMonth),@(NSCalendarUnitDay)],@[@(NSCalendarUnitHour)],@[@(NSCalendarUnitMinute)],@[@(NSCalendarUnitSecond)]];
        
        //        JWDatePickerMode_DateAddHour,// 年月日 时 分
        _modeDict[@(JWDatePickerMode_DateAddHour)]= @[@[@(NSCalendarUnitYear)],@[@(NSCalendarUnitMonth)],@[@(NSCalendarUnitDay)],@[@(NSCalendarUnitHour)]];
        
        //        JWDatePickerMode_DateAndTimeRSecond,// 年月日 时 分
        _modeDict[@(JWDatePickerMode_DateAndTimeRSecond)]= @[@[@(NSCalendarUnitYear),@(NSCalendarUnitMonth),@(NSCalendarUnitDay)],@[@(NSCalendarUnitHour)],@[@(NSCalendarUnitMinute)]];
        
        
        //        JWDatePickerMode_DateAndTimeRYearAndSecond,//月日 时分
        _modeDict[@(JWDatePickerMode_DateAndTimeRYearAndSecond)]= @[@[@(NSCalendarUnitMonth),@(NSCalendarUnitDay)],@[@(NSCalendarUnitHour)],@[@(NSCalendarUnitMinute)]];
        
    }
    
    return _modeDict;
}

/**
 *   格式化字符串
 */
-(NSDateFormatter *)dateF
{
    if (_dateF==nil) {
        _dateF = [[NSDateFormatter alloc] init];
    }
    return _dateF;
}

-(NSMutableDictionary *)unitStrDict
{
    if (_unitStrDict ==nil&&self.delegate) {
        _unitStrDict = [NSMutableDictionary dictionary];
        
        [self.formatterDict enumerateKeysAndObjectsUsingBlock:^(NSNumber*  _Nonnull unitNumber, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString* unitStr = @"";
            
            if (self.delegate&&[self.delegate respondsToSelector:@selector(datePickerView:unitForCalendarUnit:)]) {
                unitStr = [self.delegate datePickerView:self unitForCalendarUnit:unitNumber.unsignedIntegerValue];
                //验证拆分
                if([unitStr rangeOfString:KSplit].location!=NSNotFound)
                {
                    unitStr = @"";
                }
            }
            _unitStrDict[unitNumber] = unitStr;
        }];
        
    }
    return _unitStrDict;
}

/**
 *  格式化
 */
-(NSMutableDictionary *)formatterDict
{
    if (_formatterDict ==nil) {
        _formatterDict = [NSMutableDictionary dictionary];
        _formatterDict[@(NSCalendarUnitYear)]= @"yyyy";
        _formatterDict[@(NSCalendarUnitMonth)]= @"MM";
        _formatterDict[@(NSCalendarUnitDay)]= @"dd";
        _formatterDict[@(NSCalendarUnitHour)]= @"HH";
        _formatterDict[@(NSCalendarUnitMinute)]= @"mm";
        _formatterDict[@(NSCalendarUnitSecond)]= @"ss";
    }
    return _formatterDict;
}

/**
 *  设置日期格式
 */
-(void)setDateFDateFormatter
{
    //1.获取到当前模式下的 格式化字符串
    NSString *dateFormatterStr = [self getDateFormatterWithPickModel:self.pickerMode];
    self.dateF.dateFormat = dateFormatterStr;
    
    //2.拼接 转换选中模式下的格式化字符串
    NSString* sourceFormatter =  @"";
    if (self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAndTimeRYearAndSecond) {//前面拼 年
        sourceFormatter = [NSString stringWithFormat:@"yyyy%@",self.unitStrDict[@(NSCalendarUnitYear)]];
    }else if (self.pickerMode == JWDatePickerMode_Time||self.pickerMode==JWDatePickerMode_TimeRSecond)//前面拼接 年月日
    {
        sourceFormatter =[NSString stringWithFormat:@"yyyy%@MM%@dd%@%@",self.unitStrDict[@(NSCalendarUnitYear)],self.unitStrDict[@(NSCalendarUnitMonth)],self.unitStrDict[@(NSCalendarUnitDay)],KSplit];
    }
    
    //3.完整拼接
    NSString* lastFormatterStr = [NSString stringWithFormat:@"%@%@",sourceFormatter,dateFormatterStr];
    
    //4.设置格式化字符串
    self.simpleDateF.dateFormat= lastFormatterStr;
    
}



/**
 *  获取最大时间
 */
-(NSDate*)getMinDate
{
    if (self.minDate==nil) {
       
        if (self.maxDate) {//设置 最小日期的时候
            if (self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAndTimeRYearAndSecond) {//同一年
                NSDateComponents *addComps = [[NSDateComponents alloc] init];
                addComps.year = -1;
                addComps.day = 1;
                self.minDate  = [self.calendar dateByAddingComponents:addComps toDate:self.maxDate options:NSCalendarMatchLast];
            }else if (self.pickerMode==JWDatePickerMode_Time||self.pickerMode==JWDatePickerMode_TimeRSecond)//同一天
            {
                self.minDate  = [self getDayLastDateWithDate:self.maxDate max:NO];
            }
            else{
                NSDateComponents* comps = [[NSDateComponents alloc] init];
                comps.year = -1;
                self.minDate = [self.calendar dateByAddingComponents:comps toDate:self.maxDate options:NSCalendarMatchLast];
            }
        }else
        {
            self.minDate = [NSDate date];
        }
    }
    return self.minDate;
}

/**
 *  获取最小时间
 */
-(NSDate*)getMaxDate
{
    if (self.maxDate ==nil) {
        if (self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAndTimeRYearAndSecond) {//同一年
            NSDateComponents *addComps = [[NSDateComponents alloc] init];
            addComps.year = 1;
            addComps.day = -1;
            _maxDate =  [self.calendar dateByAddingComponents:addComps toDate:[self getMinDate] options:NSCalendarMatchLast];
        }else if (self.pickerMode==JWDatePickerMode_Time||self.pickerMode==JWDatePickerMode_TimeRSecond)//同一天
        {
            _maxDate  = [self getDayLastDateWithDate:self.minDate max:YES];
        }
        else{
            NSDateComponents* comps = [[NSDateComponents alloc] init];
            comps.year = 1;
            _maxDate = [self.calendar dateByAddingComponents:comps toDate:[self getMinDate] options:NSCalendarMatchLast];
        }
    }
    return self.maxDate;
}

/**
 *  获取当前时间
 */
-(NSDate*)getCurrentDate
{
    if (self.date ==nil) {
        self.date = [self getMinDate];
    }
    return self.date;
}



/**
 *  切换模式时刷新
 */
-(void)setPickerMode:(JWDatePickerMode)pickerMode
{
    
    _pickerMode =  pickerMode;
    
    
    [self setDateFDateFormatter];
    
    //年 月  日 单选
    if(self.pickerMode==JWDatePickerMode_Date||self.pickerMode==JWDatePickerMode_DateAddHour){
        if (!self.date) {
            self.date = [self getMinDate];
        }
        NSDateComponents *comps= [self.calendar components:KComUnit fromDate:self.date];
        self.tempDateComps.year=comps.year;
        self.tempDateComps.month =  comps.month;
    }
    
    if (self.minDate&&self.maxDate) {
        if (self.pickerMode==JWDatePickerMode_DateAndTimeRYear||self.pickerMode==JWDatePickerMode_DateAndTimeRYearAndSecond) {//同一年
            // 最小时间1年后的时间 compare 最大时间
            NSDateComponents *addComps = [[NSDateComponents alloc] init];
            addComps.year = 1;
            addComps.day = -1;
            NSDate* lastMaxDate =  [self.calendar dateByAddingComponents:addComps toDate:self.minDate options:NSCalendarMatchLast];
            if ([lastMaxDate compare:self.maxDate]==NSOrderedAscending) {

                self.maxDate = lastMaxDate;
                [self.pickerView reloadAllComponents];
            }
        }else if (self.pickerMode==JWDatePickerMode_Time||self.pickerMode==JWDatePickerMode_TimeRSecond)//同一天
        {
            NSDate* lastMaxDate =  [self getDayLastDateWithDate:self.minDate max:YES];
            
            if ([lastMaxDate compare:self.maxDate]==NSOrderedAscending) {
                self.maxDate  = lastMaxDate;
                [self.pickerView reloadAllComponents];
            }
        }
    }
    
    [self reloadDataNeedScrollTo:YES];
    
}

/**
 *  设置代理是刷新
 */
-(void)setDelegate:(id<JWDatePickerViewDelegate>)delegate
{
    if (delegate) {
        _delegate = delegate;
        
        [self setDateFDateFormatter];
        
        [self reloadData];
    }
}

/**
 *   用于转换 选择的时间
 */
-(NSDateFormatter *)simpleDateF
{
    if (_simpleDateF==nil) {
        _simpleDateF = [[NSDateFormatter alloc] init];
    }
    return _simpleDateF;
}


/**
 *  限制间隔
 */
-(void)setMinuteSpace:(NSUInteger)minuteSpace
{
    if (minuteSpace<30&&60%minuteSpace==0) {
        _minuteSpace =  minuteSpace;
    }
    
}

/**
 *  限制间隔
 */
-(void)setSecondSpace:(NSUInteger)secondSpace
{
    if (secondSpace<30&&60%secondSpace==0) {
        _secondSpace =  secondSpace;
    }
}


/**
 *  是否是闰年
 */
-(BOOL)isLeapYear:(NSInteger)year
{
    if (year%4==0) {
        if (year%100==0) {
            if (year%400==0) {
                return YES;
            }
            //能被 4 100  整除 不能被400 整除的 不是闰年
            return NO;
        }
        //能被4整除 不能被100整除的 是闰年
        return YES;
    }
    //不能为4整除 不是闰年
    return NO;
}

/**
 *  根据对应的年 和月  返回当月对应的天数
 */
-(NSInteger)getMonthDaysWithYear:(NSInteger)year andMoth:(NSInteger)moth
{
    // 31  28  31  30  31  30  31  31  30  31  30  31
    NSArray *daysOfMonth=@[@31,@28,@31,@30,@31,@30,@31,@31,@30,@31,@30,@31];
    
    NSUInteger days=[daysOfMonth[moth-1] integerValue];
    
    if (days==28) {
        if ([self isLeapYear:year])days=29;
    }
    return days;
}

-(NSDateComponents *)tempDateComps
{
    if (_tempDateComps==nil) {
        _tempDateComps = [[NSDateComponents alloc] init];
    }
    return _tempDateComps;
}


-(NSString *)getDateStrWithDateFormatterString:(NSString *)formatterStr
{
    if (self.date&&formatterStr&&formatterStr.length) {
        
    }
    return @"格式化字符串不合法";
}

-(NSString *)getDateStr
{
    if (self.date) {
        return [[self.simpleDateF stringFromDate:self.date] stringByReplacingOccurrencesOfString:KSplit withString:@""];
    }
    return @"NO Date";
}

/**
 *  获取一天中的  最小时间   最大时间
 */
-(NSDate*)getDayLastDateWithDate:(NSDate*)date  max:(BOOL)isGetMax
{
    if (!date) {
        return [NSDate date];
    }
    
    NSDateComponents*dateComps = [self.calendar components:KComUnit fromDate:date];
    NSInteger hour = dateComps.hour;
    NSInteger minute = dateComps.minute;
    NSInteger second = dateComps.second;
    
    NSDateComponents *newDateComp = [NSDateComponents new];
    if (isGetMax) {
        newDateComp.hour = 24-hour-1;
        newDateComp.minute = 60 - minute -1;
        newDateComp.second = 60 - second -1;
    }else
    {
        newDateComp.hour = -hour;
        newDateComp.minute = -minute;
        newDateComp.second = -second;
    }
    NSDate* lastDate  =  [self.calendar dateByAddingComponents:newDateComp toDate:date options:NSCalendarMatchLast];
    return lastDate;
}
@end
