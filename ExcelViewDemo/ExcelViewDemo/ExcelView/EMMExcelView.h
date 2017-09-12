//
//  EMMExcelView.h
//
//
//  Created by zcx on 2017/9/11.
//  Copyright © 2017年 keymobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMExcelView : UIView

/*
 * 报表所需数据
*/
@property (nonatomic,strong) NSMutableArray* allTableDatas;

/*
 * 报表头部字体大小
 * 默认为 [UIFont systemFontOfSize:14.0]
*/
@property (nonatomic,strong) UIFont* headerTextFont;

/*
 * 报表头部字体颜色
 * 默认为[UIColor colorWithRed:(79)/255.0 green:(79)/255.0 blue:(79)/255.0 alpha:1.0]
*/
@property (nonatomic,strong) UIColor* headerTextColor;

/*
 * 报表头部背景颜色
 * 默认为[UIColor colorWithRed:(247)/255.0 green:(247)/255.0 blue:(247)/255.0 alpha:1.0]
*/
@property (nonatomic,strong) UIColor* headerBackground;

/*
 * 报表头部边框宽度
 * 默认为0.5
*/
@property (nonatomic) CGFloat headerBorderWidth;

/*
 * 报表头部边框颜色
 * 默认为[UIColor colorWithRed:(170)/255.0 green:(170)/255.0 blue:(170)/255.0 alpha:1.0]
*/
@property (nonatomic,strong) UIColor* headerBorderColor;

/*
 * 报表字体大小
 * 默认为[UIFont systemFontOfSize:14.0]
*/
@property (nonatomic,strong) UIFont* textFont;

/*
 * 报表字体颜色
 * 默认为[UIColor colorWithRed:(79)/255.0 green:(79)/255.0 blue:(79)/255.0 alpha:1.0]
*/
@property (nonatomic,strong) UIColor* textColor;

/*
 * 报表单行背景颜色
 * 默认为[UIColor whiteColor]
 */
@property (nonatomic,strong) UIColor* singleBackground;

/*
 * 报表双行背景颜色
 * 默认为[UIColor colorWithRed:(239)/255.0 green:(249)/255.0 blue:(255)/255.0 alpha:1.0]
*/
@property (nonatomic,strong) UIColor* doubleBackground;

/*
 * 报表边框宽度
 *默认为0.0
*/
@property (nonatomic) CGFloat borderWidth;

/*
 * 报表边框颜色
 * 默认为[UIColor clearColor]
*/
@property (nonatomic,strong) UIColor* borderColor;

/*
 * 列最大宽度
 * 默认为200.0
*/
@property(nonatomic) CGFloat columnMaxWidth;

/*
 * 列最小宽度
 * 默认为100.0
*/
@property(nonatomic) CGFloat columnMinWidth;

/*
 * 列最小高度
 *默认为45.0
*/
@property(nonatomic) CGFloat columnMinHeight;

/*
 * 显示，必须调用该方法,视图才会展现
*/
-(void)show;

@end
