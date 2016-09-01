//
//  ViewController.m
//  JWDatePickerView
//
//  Created by 朱建伟 on 16/7/19.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//
#import "KBDatePickerViewkeyBoard.h"
#import "JWDatePickerView.h"
#import "ViewController.h"

@interface ViewController ()<JWDatePickerViewDelegate,UITextFieldDelegate>
/**
 *  pickerView
 */
@property(nonatomic,strong)JWDatePickerView* pickerView;

/**
 *  textField
 */
@property(nonatomic,strong)UITextField* txtField;

/**
 *  kb
 */
@property(nonatomic,strong)KBDatePickerViewkeyBoard* keyboard;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title =  @"日期键盘";
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换模式" style:(UIBarButtonItemStyleDone) target:self action:@selector(change)];
    
//    [self.view addSubview:self.pickerView];
    
    [self.view addSubview:self.txtField];
}

-(void)change
{
    if(self.pickerView.pickerMode<JWDatePickerMode_DateAndTimeRYearAndSecond)
    {
        self.pickerView.pickerMode++;
        self.keyboard.pickerView.pickerMode++;
    }else
    {
        self.pickerView.pickerMode = JWDatePickerMode_DateAndTime;
        self.keyboard.pickerView.pickerMode= JWDatePickerMode_DateAndTime;
    }
    
    NSDateComponents *comps  =[[NSDateComponents alloc] init];
    comps.day =-250;
    NSDate*date = [NSDate date];
    NSDate* setDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:date options:NSCalendarMatchLast];
    
    comps.day = 10;
    NSDate* maxDate =  [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:date options:NSCalendarMatchLast];

    
    self.pickerView.minDate = setDate;
    self.pickerView.date = date;
    self.pickerView.maxDate = maxDate;
}

-(NSString *)datePickerView:(JWDatePickerView *)datePickerView unitForCalendarUnit:(NSCalendarUnit)calendarUnit
{
    
    switch (calendarUnit) {
        case NSCalendarUnitYear:
            return @"年";
            break;
        case NSCalendarUnitMonth:
            return @"月";
            break;
        case NSCalendarUnitDay:
            return @"日";
            break;
        case NSCalendarUnitHour:
            return @"时";
            break;
        case NSCalendarUnitMinute:
            return @"分";
            break;
        case NSCalendarUnitSecond:
            return @"秒";
            break;
        default:
            break;
    }
    return @" ";
}

-(JWDatePickerView *)pickerView
{
    if (_pickerView==nil) {
        _pickerView = [[JWDatePickerView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 200)];
        _pickerView.backgroundColor = [UIColor orangeColor];
        
        NSDateComponents *comps  =[[NSDateComponents alloc] init];
        comps.day =-250;
        NSDate*date = [NSDate date];
        NSDate* setDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:date options:NSCalendarMatchLast];
        
        comps.day = 10;
        NSDate* maxDate =  [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:date options:NSCalendarMatchLast];

        
        _pickerView.minDate = setDate;
        _pickerView.date = date;
        _pickerView.maxDate = maxDate;
        
        _pickerView.delegate = self;
    }
    return _pickerView;
}

-(UITextField *)txtField
{
    if (_txtField==nil) {
        _txtField= [[UITextField alloc] initWithFrame:CGRectMake(20, 330, self.view.bounds.size.width-40, 30)];
        _txtField.backgroundColor = [UIColor redColor];
        _txtField.placeholder= @"日期";
        _txtField.delegate = self;
        _txtField.inputView = self.keyboard; // self.pickerView;
    }
    return _txtField;
}

-(KBDatePickerViewkeyBoard *)keyboard
{
    if (_keyboard==nil) {
        _keyboard = [[KBDatePickerViewkeyBoard alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 216)];
        _keyboard.pickerView.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        _keyboard.didSelectedBlock = ^(NSDate* date,NSString* dateStr)
        {
            if (date) {
                weakSelf.txtField.text = dateStr;
            }
        };
    }
    return _keyboard;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSDateFormatter* dateF = [[NSDateFormatter alloc] init];
    dateF.dateFormat =@"yyyy-MM-dd HH:mm:ss";
    
    NSDateComponents *comps  =[[NSDateComponents alloc] init];
    comps.day =-250;
    NSDate*date = [NSDate date];
    NSDate* setDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:date options:NSCalendarMatchLast];
    
    comps.day = 10;
    
//    NSDate* maxDate =  [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:date options:NSCalendarMatchLast];
    
    self.keyboard.pickerView.pickerMode = JWDatePickerMode_TimeRSecond;
    self.keyboard.pickerView.minDate = [NSDate date];
    
//    self.keyboard.pickerView.date = date;
//    self.keyboard.pickerView.maxDate = [self.keyboard.pickerView getDayLastDateWithDate:date max:YES]; //maxDate;
    
//    self.pickerView.minDate = setDate;
//    self.pickerView.date = date;
//    self.pickerView.maxDate = maxDate;
    
    return YES;
}
@end
