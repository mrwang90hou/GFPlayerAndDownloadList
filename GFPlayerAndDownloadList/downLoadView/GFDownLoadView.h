//
//  GFDownLoadView.h
//
//  Created by 卿伟 on 2018/1/2.
//  Copyright © 2018年 jonh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ClickQueRenBlock)(NSArray *whyArry);

@interface GFDownLoadView : UIView

- (IBAction)action_Cancel:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *byteLabel;
@property (weak, nonatomic) IBOutlet UILabel *centLabel;
@property (weak, nonatomic) IBOutlet UIView *endView;

@property (nonatomic ,strong) ClickQueRenBlock queenBlock;

@end
