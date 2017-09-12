//
//  EMMExcelView.m
//
//
//  Created by zcx on 2017/9/11.
//  Copyright © 2017年 keymobile. All rights reserved.
//

#import "EMMExcelView.h"
#import "EMMExcelLockCell.h"
#import "EMMExcelLockSection.h"

static NSString* EMMExcelLockCellIdentifier = @"EMMExcelLockCellIdentifier";

@interface EMMExcelView () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic,strong) UITableView* mTableView;

//头部滚动视图
@property (nonatomic,strong) UIScrollView *mHeadScrollView;

//滚动视图数组
@property(nonatomic,strong) NSMutableArray *mScrollViewArray;

//报表头数据
@property(nonatomic,retain) NSMutableArray* headerDatas;

//报表最左边一列的数据
@property(nonatomic,retain) NSMutableArray* lockLeftDatas;

//报表数据(不包含最左边一列的数据)
@property(nonatomic,retain) NSMutableArray* lockRightDatas;

//每列最大宽度
@property(nonatomic,strong) NSMutableArray *mColumeMaxWidths;

//每行最大高度
@property(nonatomic,strong) NSMutableArray *mRowMaxHeights;

@end

@implementation EMMExcelView

-(instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        [self initView];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self initView];
}

-(void)initView{
    self.mTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.mTableView.tableFooterView=[UIView new];
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mTableView.showsVerticalScrollIndicator=NO;
    self.mTableView.delegate=self;
    self.mTableView.dataSource=self;
    [self.mTableView registerNib:[UINib nibWithNibName:@"EMMExcelLockCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:EMMExcelLockCellIdentifier];

    [self addSubview:self.mTableView];
    
    self.mTableView.translatesAutoresizingMaskIntoConstraints=NO;
    NSLayoutConstraint *mConstraintTop=[NSLayoutConstraint constraintWithItem:self.mTableView attribute:NSLayoutAttributeTop relatedBy:0 toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *mConstraintLeft=[NSLayoutConstraint constraintWithItem:self.mTableView attribute:NSLayoutAttributeLeft relatedBy:0 toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *mConstraintRight=[NSLayoutConstraint constraintWithItem:self.mTableView attribute:NSLayoutAttributeRight relatedBy:0 toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *mConstraintBottom=[NSLayoutConstraint constraintWithItem:self.mTableView attribute:NSLayoutAttributeBottom relatedBy:0 toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraint:mConstraintTop];
    [self addConstraint:mConstraintLeft];
    [self addConstraint:mConstraintRight];
    [self addConstraint:mConstraintBottom];
    
    self.headerTextFont = self.textFont = [UIFont systemFontOfSize:14.0];
    self.headerTextColor = self.textColor = [UIColor colorWithRed:(79)/255.0 green:(79)/255.0 blue:(79)/255.0 alpha:1.0];
    self.headerBackground = [UIColor colorWithRed:(247)/255.0 green:(247)/255.0 blue:(247)/255.0 alpha:1.0];
    self.singleBackground = [UIColor whiteColor];
    self.doubleBackground = [UIColor colorWithRed:(239)/255.0 green:(249)/255.0 blue:(255)/255.0 alpha:1.0];

    self.headerBorderWidth = 0.5;
    self.headerBorderColor = [UIColor colorWithRed:(170)/255.0 green:(170)/255.0 blue:(170)/255.0 alpha:1.0];
    self.borderWidth = 0.0;
    self.borderColor = [UIColor clearColor];
    self.columnMaxWidth=200.0;
    self.columnMinWidth=100.0;
    self.columnMinHeight = 45.0;
}

-(void)show{
    NSParameterAssert(self.allTableDatas!=nil&&self.allTableDatas.count>0);
    
    [self.headerDatas removeAllObjects];
    [self.lockLeftDatas removeAllObjects];
    [self.lockRightDatas removeAllObjects];
    [self.mScrollViewArray removeAllObjects];
    [self.mRowMaxHeights removeAllObjects];
    [self.mColumeMaxWidths removeAllObjects];
    
    //设置报表头数据
    self.headerDatas = [NSMutableArray arrayWithArray:self.allTableDatas[0]];
    
    //获取列数
    NSInteger colNums = 0;
    for (id obj in self.headerDatas) {
        if ([obj isKindOfClass:[NSString class]]) {
            //该列为一级表头
            colNums++;
        } else if ([obj isKindOfClass:[NSArray class]]) {
            //该列为多级表头
            NSDictionary* contentsDic = [(NSArray*)obj objectAtIndex:0];
            NSInteger layers = [contentsDic[@"layer"] integerValue];
            for (NSString* key in contentsDic.allKeys) {
                if ([key containsString:[NSString stringWithFormat:@"key%@.",@(layers-1)]]) {
                    colNums++;
                }
            }
        }
    }
    
    //设置报表数据
    for (int i=1;i<self.allTableDatas.count;i++) {
        NSArray *array=self.allTableDatas[i];
        [self.lockLeftDatas addObject:array[0]];
        NSMutableArray *rowData=[NSMutableArray new];
        for (int j=1; j<array.count; j++) {
            [rowData addObject:array[j]];
        }
        [self.lockRightDatas addObject:rowData];
    }
    
    NSParameterAssert(self.lockLeftDatas.count==self.lockRightDatas.count);
    
    //先塞值,把每列数据放入临时数组(不包含报表头数据)
    NSMutableArray* columnDatasExclusiveHead = [NSMutableArray new];
    [columnDatasExclusiveHead addObject:self.lockLeftDatas];
    for(int i=0;i<colNums-1;i++){
        NSMutableArray *columnData=[NSMutableArray new];
        for (int j=0;j<_lockRightDatas.count; j++) {
            [columnData addObject:_lockRightDatas[j][i]];
        }
        [columnDatasExclusiveHead addObject:columnData];
    }

    //计算表头每列所需最大的宽度
    NSArray* tableHeaderCellsValidWidths = [self getTableHeaderCellsValidWidths];
    //获取报表每列所需最大的宽度
    for(int i=0;i<columnDatasExclusiveHead.count;i++){
        NSArray *columnData = columnDatasExclusiveHead[i];
        float maxWidth = [tableHeaderCellsValidWidths[i] floatValue];
        for(int j=0;j<columnData.count;j++){
            float value=[self getCellValidWidthWithTitle:columnData[j] isHeader:NO];
            if (value>maxWidth) {
                self.mColumeMaxWidths[i]=[NSNumber numberWithDouble:value];

                maxWidth=[self.mColumeMaxWidths[i] floatValue];
            }else{
                self.mColumeMaxWidths[i]=[NSNumber numberWithDouble:maxWidth];
            }
        }
    }
    
    //计算多级表头所属列的最大的宽度，并将所有列的最大宽度设置为该最大宽度(这里进行特殊处理，设定表头所属列的宽度一样)
    {
        int i = 0;
        for (id obj in self.headerDatas) {
            if ([obj isKindOfClass:[NSString class]]) {
                //一级表头下
                i++;
            } else if ([obj isKindOfClass:[NSArray class]]) {
                //多级表头下
                NSDictionary* contentsDic = [(NSArray*)obj objectAtIndex:0];
                NSInteger layers = [contentsDic[@"layer"] integerValue];
                NSInteger totalCol = 0;
                for (NSString*key in contentsDic.allKeys) {
                    if ([key containsString:[NSString stringWithFormat:@"key%@.",@(layers-1)]]) {
                        totalCol++;
                    }
                }
                
                float maxWidth = 0;
                for(NSInteger j=0;j<totalCol;j++) {
                    if ([self.mColumeMaxWidths[i+j] floatValue]>maxWidth)
                        maxWidth = [self.mColumeMaxWidths[i+j] floatValue];
                }
                
                for(NSInteger j=0;j<totalCol;j++) {
                    self.mColumeMaxWidths[i+j] = [NSNumber numberWithFloat:maxWidth];
                }
                
                i+=totalCol;
            }
        }
    }
    
    //获取报表每行所需最大高度
    {
        NSMutableArray *rowDatas=[NSMutableArray arrayWithArray:self.allTableDatas];
        [rowDatas removeObjectAtIndex:0];
        
        for(int i=0;i<rowDatas.count;i++) {
            CGFloat maxheight=0;
            NSArray *rowData=rowDatas[i];
            for (int j=0; j<rowData.count; j++) {
                CGFloat value = [self getCellValidHeightWithTitle:rowData[j] maxWidth:[self.mColumeMaxWidths[j] floatValue] isHeader:NO];
                
                if (value>maxheight) {
                    self.mRowMaxHeights[i]=[NSNumber numberWithDouble:value];
                    maxheight=[self.mRowMaxHeights[i] floatValue];
                }else{
                    self.mRowMaxHeights[i]=[NSNumber numberWithDouble:maxheight];
                }
            }
        }
        
        //添加表头最大高度
        [self.mRowMaxHeights insertObject:[NSNumber numberWithFloat:[self getTableHeaderCellsValidHeight]] atIndex:0];
    }

    [self.mTableView reloadData];
}

- (CGFloat)getCellValidWidthWithTitle:(NSString*)title isHeader:(BOOL)isHeader {
    CGFloat width = [title boundingRectWithSize:CGSizeMake(self.columnMaxWidth, CGFLOAT_MAX)
                                        options: NSStringDrawingUsesLineFragmentOrigin
                                     attributes:[NSDictionary dictionaryWithObject:isHeader?self.headerTextFont:self.textFont forKey: NSFontAttributeName]
                                        context:nil].size.width+10.0;
    if (width<_columnMinWidth)
        width = _columnMinWidth;
    else if (width>_columnMaxWidth)
        width = _columnMaxWidth;
    
    return width;
}

- (CGFloat)getCellValidHeightWithTitle:(NSString*)title isHeader:(BOOL)isHeader {
    return [self getCellValidHeightWithTitle:title maxWidth:self.columnMaxWidth isHeader:isHeader];
}

- (CGFloat)getCellValidHeightWithTitle:(NSString*)title maxWidth:(CGFloat)width isHeader:(BOOL)isHeader {
    CGFloat height = [title boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                         options: NSStringDrawingUsesLineFragmentOrigin
                                      attributes:[NSDictionary dictionaryWithObject:isHeader?self.headerTextFont:self.textFont forKey: NSFontAttributeName]
                                         context:nil].size.height+10.0;
    if (height<_columnMinHeight)
        height = _columnMinHeight;
    
    return height;
}

//计算报表头中的cell宽度
- (NSArray*)getTableHeaderCellsValidWidths {
    NSMutableArray* validWidths = [NSMutableArray new];
    for (id obj in self.headerDatas) {
        if ([obj isKindOfClass:[NSString class]]) {
            [validWidths addObject:@([self getCellValidWidthWithTitle:(NSString*)obj isHeader:YES])];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSDictionary* contentsDic = [(NSArray*)obj objectAtIndex:0];
            NSDictionary* framesDic = [(NSArray*)obj objectAtIndex:1];
            
            NSInteger layers = [contentsDic[@"layer"] integerValue];
            for (NSString* key in framesDic.allKeys) {
                if ([key containsString:[NSString stringWithFormat:@"key%@.",@(layers-1)]]) {
                    CGRect rect = CGRectFromString(framesDic[key]);
                    [validWidths addObject:[NSNumber numberWithFloat:rect.size.width]];
                }
            }
        }
    }
    
    return validWidths;
}

//计算报表头的高度
- (CGFloat)getTableHeaderCellsValidHeight {
    CGFloat validHeight = 0;
    
    for (id obj in self.headerDatas) {
        if ([obj isKindOfClass:[NSString class]]) {
            CGFloat height = [self getCellValidHeightWithTitle:(NSString*)obj isHeader:YES];
            if (height>validHeight)
                validHeight = height;
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSDictionary* contentsDic = [(NSArray*)obj objectAtIndex:0];
            NSDictionary* framesDic = [(NSArray*)obj objectAtIndex:1];
            
            NSInteger layers = [contentsDic[@"layer"] integerValue];
            
            CGFloat layersHeight = 0;
            for (NSInteger i=0;i<layers;i++) {
                CGFloat layerHeight = 0;
                for (NSString*key in contentsDic.allKeys) {
                    if ([key containsString:[NSString stringWithFormat:@"key%@.",@(i)]]) {
                        CGRect rect = CGRectFromString(framesDic[key]);
                        float height = rect.size.height;
                        if (height>layerHeight) layerHeight = height;
                    }
                }
                layersHeight+=layerHeight;
            }
            
            if (layersHeight>validHeight)
                validHeight = layersHeight;
        }
    }
    
    return validHeight;
}

#pragma mark UITableViewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMMExcelLockCell* cell = [self.mTableView dequeueReusableCellWithIdentifier:EMMExcelLockCellIdentifier];
    
    [cell setXTableDatas:_lockRightDatas];
    [cell setYTableDatas:_lockLeftDatas];
    
    NSMutableArray* tmpHeights = [NSMutableArray arrayWithArray:_mRowMaxHeights];
    [tmpHeights removeObjectAtIndex:0];
    
    [cell setRowMaxHeights:tmpHeights];
    
    [cell setColumeMaxWidths:_mColumeMaxWidths];
    [cell setCellTextFont:_textFont];
    [cell setCellTextColor:_textColor];
    [cell setCellBorderWidth:_borderWidth];
    [cell setCellBorderColor:_borderColor];
    [cell setCellSingleBackgroundColor:_singleBackground];
    [cell setCellDoubleBackgroundColor:_doubleBackground];
    cell.scrollView.delegate = self;
    
    [cell initView];
    [self.mScrollViewArray addObject:cell.scrollView];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    __block CGFloat cellHeight=0;
    
    [_mRowMaxHeights enumerateObjectsUsingBlock:^(NSNumber* num, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx>0) {
            cellHeight += [num floatValue];
        }
    }];

    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    EMMExcelLockSection *cell=[[[NSBundle mainBundle] loadNibNamed:@"EMMExcelLockSection" owner:nil options:nil] lastObject];
    
    UILabel *lockView=[[UILabel alloc] initWithFrame:CGRectMake(cell.lockView.frame.origin.x, cell.lockView.frame.origin.y,[self.mColumeMaxWidths[0] floatValue], [self.mRowMaxHeights[0] floatValue])];
        
    lockView.text = _headerDatas[0];
    lockView.textColor = _headerTextColor;
    lockView.font = _headerTextFont;
    lockView.textAlignment = NSTextAlignmentCenter;
    lockView.numberOfLines = 0;

    cell.lockViewWidthConstraint.constant = [self.mColumeMaxWidths[0] floatValue];
    [cell.lockView addSubview:lockView];
    cell.lockView.layer.borderWidth = self.headerBorderWidth;
    cell.lockView.layer.borderColor = self.headerBorderColor.CGColor;
    cell.lockView.backgroundColor = self.headerBackground;
    
    //构造滚动视图
    CGFloat x=0;
    int i=0;
    for (id data in self.headerDatas) {
        if (i == 0) {
            i++;
            continue;
        }
        
        UIView* view = [[UIView alloc] init];
        
        if ([data isKindOfClass:[NSString class]]) {
            view.frame = CGRectMake(x, 0, [self.mColumeMaxWidths[i] floatValue], [self.mRowMaxHeights[0] floatValue]);
            
            UILabel *dataView = [[UILabel alloc]initWithFrame:view.bounds];
            dataView.text = data;
            dataView.textColor = self.headerTextColor;
            dataView.font = self.headerTextFont;
            dataView.textAlignment = NSTextAlignmentCenter;
            dataView.numberOfLines = 0;
            [view addSubview:dataView];
            
            view.layer.borderWidth = self.headerBorderWidth;
            view.layer.borderColor = self.headerBorderColor.CGColor;
            view.backgroundColor = self.headerBackground;
            [cell.scrollView addSubview:view];
            x+=view.frame.size.width;
            i++;
        } else if ([data isKindOfClass:[NSArray class]]) {
            NSDictionary* contentsDic = [(NSArray*)data objectAtIndex:0];
            NSDictionary* framesDic = [(NSArray*)data objectAtIndex:1];
            NSDictionary* colDic = [(NSArray*)data objectAtIndex:2];
            NSInteger layers = [contentsDic[@"layer"] integerValue];
            
            float colWidth = [self.mColumeMaxWidths[i] floatValue];
            
            NSInteger number = 0;
            for (NSString* key in contentsDic.allKeys) {
                if ([key containsString:[NSString stringWithFormat:@"key%@.",@(layers-1)]]) {
                    number++;
                }
            }
            
            float widths = [self.mColumeMaxWidths[i] floatValue]*number;
            
            for (NSString* key in framesDic) {
                UILabel *dataView=[[UILabel alloc] init];
                
                NSArray*colArray = colDic[key];
                
                dataView.frame = CGRectMake((CGFloat)[colArray[1] integerValue]*colWidth, [self.mRowMaxHeights[0] floatValue]/layers*([colArray[2] integerValue]-1), [colArray[0] integerValue]*colWidth, [self.mRowMaxHeights[0] floatValue]/layers);
                dataView.text = contentsDic[key];
                
                dataView.textColor = self.headerTextColor;
                dataView.font=self.headerTextFont;
                dataView.textAlignment=NSTextAlignmentCenter;
                dataView.numberOfLines = 0;
                dataView.layer.borderWidth = self.headerBorderWidth;
                dataView.layer.borderColor = self.headerBorderColor.CGColor;
                dataView.backgroundColor = self.headerBackground;
                [view addSubview:dataView];
            }
            
            view.frame = CGRectMake(x, 0, widths, [self.mRowMaxHeights[0] floatValue]);
            [cell.scrollView addSubview:view];
            x+=view.frame.size.width;
            i += number;
        }
    }
    cell.scrollView.contentSize=CGSizeMake(x, cell.scrollView.frame.size.height);
    
    cell.scrollView.delegate=self;
    cell.scrollView.bounces=NO;
    self.mHeadScrollView=cell.scrollView;
    [self.mScrollViewArray addObject:cell.scrollView];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [_mRowMaxHeights[0] floatValue];
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView!=self.mTableView) {
        for (UIScrollView *view in _mScrollViewArray) {
            view.contentOffset=scrollView.contentOffset;
        }
    }
}

#pragma mark getter

- (NSMutableArray*)headerDatas {
    if (!_headerDatas) {
        _headerDatas = [NSMutableArray new];
    }
    
    return _headerDatas;
}

- (NSMutableArray*)lockLeftDatas {
    if (!_lockLeftDatas) {
        _lockLeftDatas = [NSMutableArray new];
    }
    
    return _lockLeftDatas;
}

- (NSMutableArray*)lockRightDatas {
    if (!_lockRightDatas) {
        _lockRightDatas = [NSMutableArray new];
    }
    
    return _lockRightDatas;
}

- (NSMutableArray*)mScrollViewArray {
    if (!_mScrollViewArray) {
        _mScrollViewArray = [NSMutableArray new];
    }
    
    return _mScrollViewArray;
}

- (NSMutableArray*)mColumeMaxWidths {
    if (!_mColumeMaxWidths) {
        _mColumeMaxWidths = [NSMutableArray new];
    }
    
    return _mColumeMaxWidths;
}

- (NSMutableArray*)mRowMaxHeights {
    if (!_mRowMaxHeights) {
        _mRowMaxHeights = [NSMutableArray new];
    }
    
    return _mRowMaxHeights;
}

@end
