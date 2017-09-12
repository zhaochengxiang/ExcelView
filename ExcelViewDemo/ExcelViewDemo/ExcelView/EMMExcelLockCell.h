//
//  EMMExcelLockCell.h
//
//
//  Created by zcx on 2017/9/11.
//  Copyright © 2017年 keymobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMExcelLockCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UITableView *lockViewTableView;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) UITableView *scrollViewTableView;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *fristColumnWidth;

-(void) setXTableDatas:(NSArray*)xTableDatas;
-(void) setYTableDatas:(NSArray*)yTableDatas;
-(void) setColumeMaxWidths:(NSArray*)mColumeMaxWidths;
-(void) setRowMaxHeights:(NSArray*)mRowMaxHeights;
-(void) setCellTextFont:(UIFont*)mTextFont;
-(void) setCellTextColor:(UIColor*)mTextColor;
-(void) setCellBorderWidth:(CGFloat)mBorderWidth;
-(void) setCellBorderColor:(UIColor*)mBorderColor;
-(void) setCellSingleBackgroundColor:(UIColor*)mSingleBG;
-(void) setCellDoubleBackgroundColor:(UIColor*)mDoubleBG;

-(void) initView;

@end
