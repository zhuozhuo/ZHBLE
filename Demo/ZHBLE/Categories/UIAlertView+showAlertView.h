//
//  UIAlertView+showAlertView.h
//  leanCloudTest
//
//  Created by aimoke on 15/6/18.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (showAlertView)
+(void)showAlertViewWithTitile:(NSString *)titile withMessage:(NSString *)messageString withDelegate:(id)alertViewDelegate withCancleButtonTitle:(NSString *)canCelButtonTitle withotherBtnTitle:(NSString *)otherBtnTitle;

@end
