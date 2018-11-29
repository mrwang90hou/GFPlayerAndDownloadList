//
//  GFDownLoadView.m
//
//  Created by 卿伟 on 2018/1/2.
//  Copyright © 2018年 jonh. All rights reserved.
//

#import "GFDownLoadView.h"
#import "GFAlertView.h"
@interface GFDownLoadView (){
 
}
@property (weak, nonatomic) IBOutlet        UIView *whyOneView;

@property (nonatomic ,strong)         NSMutableArray *whrArray;
@end
@implementation GFDownLoadView
- (void)awakeFromNib{
    [super awakeFromNib];
}
- (NSMutableArray *)whrArray{
    if(!_whrArray){
        _whrArray = [NSMutableArray array];
    }
    return _whrArray;
}
- (IBAction)action_QueDing:(UIButton *)sender {
  
}
- (IBAction)touch_selectWhy:(UITapGestureRecognizer *)sender {
   
}

- (IBAction)action_Cancel:(UIButton *)sender {
    [[GFAlertView sharedMask] dismiss];
}
@end
