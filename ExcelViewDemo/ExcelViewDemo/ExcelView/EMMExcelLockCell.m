//
//  EMMExcelLockCell.m
//
//
//  Created by zcx on 2017/9/11.
//  Copyright © 2017年 keymobile. All rights reserved.
//

#import "EMMExcelLockCell.h"
#import "EMMLockViewCell.h"
#import "EMMScrollViewCell.h"

static NSString* EMMScrollViewCellIdentifier = @"EMMScrollViewCellIdentifier";
static NSString* EMMLockViewCellIdentifier = @"EMMLockViewCellIdentifier";

@interface EMMExcelLockCell()<UITableViewDelegate,UITableViewDataSource>

//横向单行数据
@property (nonatomic,strong) NSMutableArray* mXTableDatas;

//第一列数据
@property (nonatomic,strong) NSMutableArray* mYTableDatas;

//每列最大宽度
@property (nonatomic,strong) NSMutableArray* mColumeMaxWidths;

//每行最大高度
@property (nonatomic,strong) NSMutableArray* mRowMaxHeights;

@property (nonatomic,strong) UIFont* textFont;
@property (nonatomic,strong) UIColor* textColor;
@property CGFloat borderWidth;
@property (nonatomic,strong) UIColor* borderColor;
@property (nonatomic,strong) UIColor* singleBackground;
@property (nonatomic,strong) UIColor* doubleBackground;

@property CGFloat mScrollViewContentWidth;//滚动视图内容宽度
@property CGFloat mScrollViewContentHeight;//滚动视图内容高度

@end

@implementation EMMExcelLockCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void) initView{
    self.mScrollViewContentWidth=0;
    self.mScrollViewContentHeight=0;
    
    [self.mColumeMaxWidths enumerateObjectsUsingBlock:^(NSNumber* num, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx>0) {
            self.mScrollViewContentWidth += [num floatValue];
        }
    }];
    
    [self.mRowMaxHeights enumerateObjectsUsingBlock:^(NSNumber* num, NSUInteger idx, BOOL * _Nonnull stop) {
        self.mScrollViewContentHeight += [num floatValue];
    }];
    
    self.fristColumnWidth.constant=[self.mColumeMaxWidths[0] floatValue];

    self.scrollViewTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, _mScrollViewContentWidth, _mScrollViewContentHeight) style:UITableViewStylePlain];
    
    self.scrollViewTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.scrollViewTableView registerNib:[UINib nibWithNibName:@"EMMScrollViewCell" bundle:nil] forCellReuseIdentifier:EMMScrollViewCellIdentifier];
    self.scrollViewTableView.scrollEnabled=NO;
    self.scrollViewTableView.delegate=self;
    self.scrollViewTableView.dataSource=self;
    [self.scrollView addSubview:self.self.scrollViewTableView];

    self.scrollView.bounces=NO;
    self.scrollView.contentSize=CGSizeMake(self.mScrollViewContentWidth, self.mScrollViewContentHeight);
    
    self.lockViewTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.lockViewTableView registerNib:[UINib nibWithNibName:@"EMMLockViewCell" bundle:nil] forCellReuseIdentifier:EMMLockViewCellIdentifier];
    self.lockViewTableView.scrollEnabled=NO;
    self.lockViewTableView.delegate=self;
    self.lockViewTableView.dataSource=self;
}

#pragma mark UITableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.lockViewTableView) {
        EMMLockViewCell *cell=[tableView dequeueReusableCellWithIdentifier:EMMLockViewCellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        cell.label.text = self.mYTableDatas[indexPath.row];
        cell.label.numberOfLines = 0;
        cell.label.font = _textFont;
        cell.label.textAlignment = NSTextAlignmentCenter;
  
        cell.label.textColor= _textColor;
        cell.layer.borderWidth = _borderWidth;
        cell.layer.borderColor = _borderColor.CGColor;
        
        (indexPath.row%2 ==0)?([cell setBackgroundColor:_singleBackground]):([cell setBackgroundColor:_doubleBackground]);
        
        return cell;
    }else if(tableView==self.scrollViewTableView){
        EMMScrollViewCell *cell=[tableView dequeueReusableCellWithIdentifier:EMMScrollViewCellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        NSArray* rowDatas=self.mXTableDatas[indexPath.row];
        //添加视图
        __block CGFloat x=0;
        
        [rowDatas enumerateObjectsUsingBlock:^(NSString* rowData, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, 0, [self.mColumeMaxWidths[idx+1] floatValue], [self.mRowMaxHeights[indexPath.row] floatValue])];
            
            UILabel *dataView = [[UILabel alloc] initWithFrame:view.bounds];
            dataView.numberOfLines=0;
            dataView.text = rowData;
            dataView.font = _textFont;
            dataView.textColor = _textColor;
            dataView.textAlignment=NSTextAlignmentCenter;
            [view addSubview:dataView];
            
            view.layer.borderWidth = _borderWidth;
            view.layer.borderColor = _borderColor.CGColor;
            [cell addSubview:view];
            x += view.frame.size.width;
        }];
        
        (indexPath.row%2 ==0)?([cell setBackgroundColor:_singleBackground]):([cell setBackgroundColor:_doubleBackground]);

        return cell;
    }
    return nil;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mRowMaxHeights.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.mRowMaxHeights[indexPath.row] floatValue];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 属性初始化
-(void) setXTableDatas:(NSArray*)xTableDatas {
    NSParameterAssert(xTableDatas!=nil);
    
    if (self.mXTableDatas!=nil) {
        [self.mXTableDatas removeAllObjects];
    }else{
        self.mXTableDatas =[NSMutableArray new];
    }
    
    [self.mXTableDatas addObjectsFromArray:xTableDatas];
}

-(void) setYTableDatas:(NSArray*)yTableDatas {
    NSParameterAssert(yTableDatas!=nil);

    if (self.mYTableDatas!=nil) {
        [self.mYTableDatas removeAllObjects];
    }else{
        self.mYTableDatas =[NSMutableArray new];
    }
    
    [self.mYTableDatas addObjectsFromArray:yTableDatas];
}

-(void) setColumeMaxWidths:(NSArray*)mColumeMaxWidths {
    NSParameterAssert(mColumeMaxWidths!=nil);

    if (self.mColumeMaxWidths!=nil) {
        [self.mColumeMaxWidths removeAllObjects];
    }else{
        self.mColumeMaxWidths =[NSMutableArray new];
    }
    [self.mColumeMaxWidths addObjectsFromArray:mColumeMaxWidths];
}

-(void) setRowMaxHeights:(NSArray*)mRowMaxHeights {
    NSParameterAssert(mRowMaxHeights!=nil);

    if (self.mRowMaxHeights!=nil) {
        [self.mRowMaxHeights removeAllObjects];
    }else{
        self.mRowMaxHeights =[NSMutableArray arrayWithCapacity:10];
    }
    [self.mRowMaxHeights addObjectsFromArray:mRowMaxHeights];
}

-(void) setCellTextFont:(UIFont*)mTextFont {
    NSParameterAssert(mTextFont!=nil);
    
    self.textFont = mTextFont;
}
-(void) setCellTextColor:(UIColor*)mTextColor {
    NSParameterAssert(mTextColor!=nil);
    
    self.textColor = mTextColor;
}

-(void) setCellBorderWidth:(CGFloat)mBorderWidth {
    NSParameterAssert(mBorderWidth>=0);
    
    self.borderWidth = mBorderWidth;
}
-(void) setCellBorderColor:(UIColor*)mBorderColor {
    NSParameterAssert(mBorderColor!=nil);
    
    self.borderColor = mBorderColor;
}
-(void) setCellSingleBackgroundColor:(UIColor*)mSingleBG {
    NSParameterAssert(mSingleBG!=nil);
    
    self.singleBackground = mSingleBG;
}
-(void) setCellDoubleBackgroundColor:(UIColor*)mDoubleBG {
    NSParameterAssert(mDoubleBG!=nil);
    
    self.doubleBackground = mDoubleBG;
}

@end
