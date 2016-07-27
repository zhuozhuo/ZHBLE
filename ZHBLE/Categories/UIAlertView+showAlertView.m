//
//  UIAlertView+showAlertView.m
//  leanCloudTest
//
//  Created by aimoke on 15/6/18.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import "UIAlertView+showAlertView.h"

@implementation UIAlertView (showAlertView)
+(void)showAlertViewWithTitile:(NSString *)titile withMessage:(NSString *)messageString withDelegate:(id)alertViewDelegate withCancleButtonTitle:(NSString *)canCelButtonTitle withotherBtnTitle:(NSString *)otherBtnTitle
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:titile message:messageString delegate:alertViewDelegate cancelButtonTitle:canCelButtonTitle otherButtonTitles:otherBtnTitle, nil];
    [alertView show];
    
}


@end
