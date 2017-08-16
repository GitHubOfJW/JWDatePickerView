//
//  KBSexkeyBoard.m
//  SunCarGuide
//
//  Created by 朱建伟 on 15/12/17.
//  Copyright © 2015年 jryghq. All rights reserved.
//
#import "KBDatePickerViewkeyBoard.h" 
@interface KBDatePickerViewkeyBoard()
@property(nonatomic,strong)UIControl *cover;

@property(nonatomic,strong)UIView *titleView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIButton *cancelBtn;
@property(nonatomic,strong)UIButton *confirmBtn;


@property(nonatomic,strong)NSString *currentTitle;

@property(nonatomic,assign)BOOL isRemove;

@property(nonatomic,assign)BOOL flag;
 

@end

@implementation KBDatePickerViewkeyBoard

/**
 *  快捷初始化
 */
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title currentDayName:(NSString *)currentDayName
{
    if (self = [self initWithFrame:frame]) {
        self.title =title;
        self.titleLabel.text = title;
        self.currentTitle = currentDayName;
    }
    return self;
}


/**
 *  初始化
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    { 
        self.flag = YES;
     
        [self setClipsToBounds:NO];
        
        _cover = [[UIControl alloc] init];
        _cover.backgroundColor = [UIColor blackColor];
        [_cover addTarget:self
                   action:@selector(ExitKeyboard) forControlEvents:(UIControlEventTouchUpInside)];
        _cover.alpha = 0.4;
        
        //标题View
        _titleView = [[UIView alloc] init];
        [self addSubview:_titleView ];
        
        //标题
        _titleLabel  =[[UILabel alloc] init];
        _titleLabel.text = @"请选择";
//        CGFloat titleValue = 160;
        _titleLabel.textColor = [UIColor orangeColor];//[UIColor colorWithRed:(titleValue/255.0) green:(titleValue/255.0) blue:(titleValue/255.0) alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleView addSubview:_titleLabel];
        
        //取消
        _cancelBtn  = [[UIButton alloc] init];
        [_cancelBtn setTitleColor:[UIColor orangeColor]forState:(UIControlStateNormal)];
        [_cancelBtn setTitle:NSLocalizedString(@"取消",nil) forState:(UIControlStateNormal)];
        _cancelBtn.titleLabel.font =[UIFont systemFontOfSize:16];
        _cancelBtn.tag = 0;
        [_cancelBtn addTarget:self
                       action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView addSubview:_cancelBtn];
        
        //确定
        _confirmBtn = [[UIButton alloc] init];
        [_confirmBtn setTitleColor:[UIColor orangeColor]forState:(UIControlStateNormal)];
        [_confirmBtn setTitle:NSLocalizedString(@"确定",nil) forState:(UIControlStateNormal)];
        _confirmBtn.titleLabel.font =[UIFont systemFontOfSize:16];
        _confirmBtn.tag = 1;
        [_confirmBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView addSubview:_confirmBtn];
        
        
        //pickerView
        _pickerView =[[JWDatePickerView alloc] init];
        _pickerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pickerView];
       
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height  = 216;
    CGFloat margin = 10;
    
    CGFloat btnW = 80;
    
    CGFloat titleViewW = width;
    CGFloat titleViewH = 44;
    CGFloat titleViewX =0;
    CGFloat titleViewY =0;
    self.titleView.frame = CGRectMake(titleViewX, titleViewY, titleViewW, titleViewH);
    
    CGFloat cancelBtnW =btnW;
    CGFloat cancelBtnH = titleViewH;
    CGFloat cancelBtnX = margin;
    CGFloat cancelBtnY = 0;
    self.cancelBtn.frame =CGRectMake(cancelBtnX, cancelBtnY, cancelBtnW, cancelBtnH);
    
    
    CGFloat confirmBtnW = btnW;
    CGFloat confirmBtnH = titleViewH;
    CGFloat confirmBtnX = width - margin - confirmBtnW;
    CGFloat confirmBtnY = 0;
    self.confirmBtn.frame =CGRectMake(confirmBtnX, confirmBtnY, confirmBtnW, confirmBtnH);
    
    
    CGFloat titleLabelH = titleViewH;
    CGFloat titleLabelX = (cancelBtnX+cancelBtnW);
    CGFloat titleLabelW = confirmBtnX - titleLabelX;
    CGFloat titleLabelY = 0;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    
    CGFloat pickerViewX = 0;
    CGFloat pickerViewY = titleViewH;
    CGFloat pickerViewW = width;
    CGFloat pickerViewH = height - pickerViewY+margin;
    self.pickerView.frame = CGRectMake(pickerViewX, pickerViewY, pickerViewW, pickerViewH);
    
}


-(void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = title;
    
}


/**
 *  此方法当 自定键盘移动到窗口上调用
 */
-(void)didMoveToWindow
{
    [super didMoveToWindow];
    if (!self.isRemove) {
        UIWindow *window =  [UIApplication sharedApplication].keyWindow;
        self.cover.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.cover.alpha = 0.4;
        [window addSubview:self.cover];
    }else
    {
        self.isRemove = NO;
    }
}



/**
 *  移除时 将蒙板一并移除
 */
-(void)removeFromSuperview
{
    self.isRemove = YES;
    [self.cover removeFromSuperview];
    [super  removeFromSuperview];
}


-(void)btnClick:(UIButton*)btn
{
    if (btn.tag) {//确定
        if (self.didSelectedBlock&&self.pickerView.date) {
            self.didSelectedBlock(self.pickerView.date,[self.pickerView getDateStr]);
        }
    }
    
    self.cover.alpha = 0.021;
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}


-(void)ExitKeyboard{
    self.cover.alpha = 0.021;
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

@end
