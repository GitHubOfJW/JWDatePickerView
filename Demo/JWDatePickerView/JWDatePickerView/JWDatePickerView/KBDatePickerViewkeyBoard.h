//
//  KBSexkeyBoard.h
//  SunCarGuide
//
//  Created by 朱建伟 on 15/12/17.
//  Copyright © 2015年 jryghq. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "JWDatePickerView.h"

@interface KBDatePickerViewkeyBoard : UIView

/**
 *  快捷初始化
 */
-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title currentDayName:(NSString*)currentDayName;


@property(nonatomic,strong,readonly)JWDatePickerView *pickerView;


@property(nonatomic,copy)NSString *title;


@property(nonatomic,copy)void(^didSelectedBlock)(NSDate *date,NSString* dateStr);

 
 
@end
