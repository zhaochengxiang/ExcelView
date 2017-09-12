//
//  ViewController.m
//
//
//  Created by zcx on 2017/9/11.
//  Copyright © 2017年 keymobile. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,retain) NSMutableArray *allTableDataArray;//表格所有数据
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.allTableDataArray=[NSMutableArray arrayWithCapacity:10];
    NSMutableArray *fristDatas=[NSMutableArray arrayWithCapacity:10];
    [fristDatas addObject:@"标题"];
    for (int i=0; i<22; i++) {
        if (i == 1) {

            [fristDatas addObject:@[@{
                                        @"layer":@(3),
                                        @"key0.0":@"第一级标题",
                                        @"key1.0":@"第二季标题0",
                                        @"key1.1":@"第二级标题1",
                                        @"key2.0":@"第三级标题0",
                                        @"key2.1":@"第三级标题1",
                                        @"key2.2":@"第三级标题2",
                                        @"key2.3":@"第三级标题3"
                                    },
                                    @{
                                        @"key0.0":NSStringFromCGRect(CGRectMake(0, 0, 400.0, 30.0)),
                                        @"key1.0":NSStringFromCGRect(CGRectMake(0, 30.0, 200.0, 30.0)),
                                        @"key1.1":NSStringFromCGRect(CGRectMake(200.0, 30.0, 200.0, 30.0)),
                                        @"key2.0":NSStringFromCGRect(CGRectMake(0, 60.0, 100.0, 30.0)),
                                        @"key2.1":NSStringFromCGRect(CGRectMake(100.0, 60.0, 100.0, 30.0)),
                                        @"key2.2":NSStringFromCGRect(CGRectMake(200.0, 60.0, 100.0, 30.0)),
                                        @"key2.3":NSStringFromCGRect(CGRectMake(300.0, 60.0, 100.0, 30.0))
                                    },
                                    @{
                                        @"key0.0":@[@(4),@(0),@(1)],
                                        @"key1.0":@[@(2),@(0),@(2)],
                                        @"key1.1":@[@(2),@(2),@(2)],
                                        @"key2.0":@[@(1),@(0),@(3)],
                                        @"key2.1":@[@(1),@(1),@(3)],
                                        @"key2.2":@[@(1),@(2),@(3)],
                                        @"key2.3":@[@(1),@(3),@(3)]
                                    }]];
        } else {
            [fristDatas addObject:[NSString stringWithFormat:@"标题%d",i]];
        }
    }
    [self.allTableDataArray addObject:fristDatas];
    for (int i=0; i<25; i++) {
        NSMutableArray *rowDatas=[NSMutableArray arrayWithCapacity:10];
        [rowDatas addObject:[NSString stringWithFormat:@"标题%d",i]];
        for (int j=0; j<25;j++) {
            [rowDatas addObject:[NSString stringWithFormat:@"数据%d",j]];
        }
        [self.allTableDataArray addObject:rowDatas];
    }
    
    //xib布局添加方式
    self.mExcelView.allTableDatas=self.allTableDataArray;
    [self.mExcelView show];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
