//
//  GFDownLoadView.m
//
//  Created by 卿伟 on 2018/1/2.
//  Copyright © 2018年 jonh. All rights reserved.
//

#import "GFDownLoadView.h"
#import "GFAlertView.h"
@interface GFDownLoadView ()<UITextViewDelegate>{
    
    
}
@property (weak, nonatomic) IBOutlet        UIView *whyTwoView;
@property (weak, nonatomic) IBOutlet       UIView *whyFourView;
@property (weak, nonatomic) IBOutlet      UIView *otherWhyView;
@property (weak, nonatomic) IBOutlet UITextView *otherTextView;
@property (weak, nonatomic) IBOutlet        UIView *whyOneView;
@property (weak, nonatomic) IBOutlet      UIView *whyThreeView;
@property (nonatomic ,strong)         NSMutableArray *whrArray;
@end
@implementation GFDownLoadView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.otherTextView.delegate = self;
}
- (NSMutableArray *)whrArray{
    if(!_whrArray){
        _whrArray = [NSMutableArray array];
    }
    return _whrArray;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -150);
    }];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
    
}
- (IBAction)action_QueDing:(UIButton *)sender {
  
}
- (IBAction)touch_selectWhy:(UITapGestureRecognizer *)sender {
   
}

- (IBAction)action_Cancel:(UIButton *)sender {
    [[GFAlertView sharedMask] dismiss];
}
@end
