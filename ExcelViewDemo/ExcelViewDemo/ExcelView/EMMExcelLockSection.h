//
//  EMMExcelLockSection.h
//
//
//  Created by zcx on 2017/9/11.
//  Copyright © 2017年 keymobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMExcelLockSection : UIView

@property (retain, nonatomic) IBOutlet UIView *lockView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lockViewWidthConstraint;

@end
