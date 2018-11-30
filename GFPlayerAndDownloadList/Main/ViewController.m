//
/*****************************************
 *                                       *
 *  @dookay.com Internet make it happen  *
 *  ----------- -----------------------  *
 *  dddd  ddddd Internet make it happen  *
 *  o   o     o Internet make it happen  *
 *  k    k    k Internet make it happen  *
 *  a   a     a Internet make it happen  *
 *  yyyy  yyyyy Internet make it happen  *
 *  ----------- -----------------------  *
 *  Say hello to the future.		     *
 *  hello，未来。                   	     *
 *  未来をその手に。                        *
 *                                       *
 *****************************************/
//
//  ViewController.m
//  LURecordProject
//
//  Created by dookay_73 on 2018/10/30.
//  Copyright © 2018 LU. All rights reserved.
//

#import "ViewController.h"
#import "MediaDetailVC.h"
#import "Base/BaseNavViewController.h"
#import "MediaDownloadVC.h"
#import "DKAVPlayer.h"
#import "DKFullScreenVC.h"
#import "GFAlertView.h"
#import "GFDownLoadView.h"
#import "GKDownloadManager.h"
#import "FGTool.h"
@interface ViewController ()

@property (nonatomic, strong) GFDownLoadView *cancelTaskView;

@end

@implementation ViewController

- (GFDownLoadView *)cancelTaskView{
    if(!_cancelTaskView){
        _cancelTaskView = [[[NSBundle mainBundle] loadNibNamed:@"GFDownLoadView" owner:nil options:nil] firstObject];
        _cancelTaskView.frame = CGRectMake(0, 0, self.view.frame.size.width/5*4, 180);
//        [_cancelTaskView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(self.view.frame.size.width/4*3);
//            make.height.mas_equalTo(180);
//            make.center.equalTo(self.view);
//        }];
    }
    return _cancelTaskView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [MyTool buttonWithTitle:@"观看视频"];
    [btn addTarget:self
            action:@selector(enterVideoVC)
  forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
    }];
    
    UIButton *listBtn = [MyTool buttonWithTitle:@"本地视频"];
    [listBtn addTarget:self
            action:@selector(enterVideoListVC)
  forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:listBtn];
    
    [listBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(btn.mas_bottom).offset(30);
    }];
    
    UIButton *fullBtn = [MyTool buttonWithTitle:@"全屏视频"];
    [fullBtn addTarget:self
                action:@selector(enterFullScreenVideoVC)
      forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:fullBtn];
    
    [fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(listBtn.mas_bottom).offset(30);
    }];
    
    UIButton *downLoadViewBtn = [MyTool buttonWithTitle:@"下载视图"];
    [downLoadViewBtn addTarget:self
                action:@selector(downLoadViewBtnAction)
      forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:downLoadViewBtn];
    
    [downLoadViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(fullBtn.mas_bottom).offset(30);
    }];
    
    UIButton *downLoadTestBtn = [MyTool buttonWithTitle:@"下载测试"];
    [downLoadTestBtn addTarget:self
                        action:@selector(downLoadTestBtnBtnAction)
              forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:downLoadTestBtn];
    
    [downLoadTestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(downLoadViewBtn.mas_bottom).offset(30);
    }];
}

- (void)enterVideoVC
{
    MediaDetailVC *detailVC = [[MediaDetailVC alloc] init];
    BaseNavViewController *navVC = [[BaseNavViewController alloc] initWithRootViewController:detailVC];
//    [self presentViewController:navVC animated:YES completion:nil];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)enterVideoListVC
{
    MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
    BaseNavViewController *navVC = [[BaseNavViewController alloc] initWithRootViewController:downloadVC];
//    [self presentViewController:navVC animated:YES completion:nil];
    [self.navigationController pushViewController:downloadVC animated:YES];
}

- (void)enterFullScreenVideoVC
{
    DKAVPlayer *avPlayer = [[DKAVPlayer alloc] initWithFrame:CGRectMake(0, 0, mainHeight, mainWidth)
                                      andMediaURL:@"http://v.dansewudao.com/444fccb3590845a799459f6154d2833f/fe86a70dc4b8497f828eaa19058639ba-6e51c667edc099f5b9871e93d0370245-sd.mp4"];
    avPlayer.backgroundColor = UIColorFromRGB(0x1D1C1F);
    avPlayer.isFullScreen = YES;
    avPlayer.isFullVC = YES;
    DKFullScreenVC *fullPlayer = [[DKFullScreenVC alloc] init];
    [fullPlayer.view addSubview:avPlayer];
    WS(weakSelf);
    [avPlayer setClickedFullScreenBlock:^(BOOL isFullScreen) {
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    }];
    [self presentViewController:fullPlayer animated:NO completion:nil];
}
- (void)downLoadViewBtnAction{
    [[GFAlertView sharedMask] show:self.cancelTaskView withType:0];
}
//下载测试 btnAction
- (void)downLoadTestBtnBtnAction{
    GKDownloadManager *manager = [[GKDownloadManager alloc]init];
//    NSArray *nameArr = @[@"1",@"2",@"3",@"4",@"5"];
    NSString *music1 = @"http://192.72.1.1/SD/Normal/NK_D20181127_172224_1440.MP4";
    NSString *music2 = @"http://192.72.1.1/SD/Normal/NK_D20181127_172513_1440.MP4";
    NSString *music3 = @"http://192.72.1.1/SD/Normal/NK_D20181128_155308_1440.MP4";
    NSString *music4 = @"http://192.72.1.1/SD/Normal/NK_D20181128_155342_1440.MP4";
    NSString *music5 = @"http://192.72.1.1/SD/Normal/NK_D20181128_155353_1440.MP4";
    NSArray *videoArr = @[music1,music2,music3,music4,music5];
    
    [[GFAlertView sharedMask] show:self.cancelTaskView withType:0];
    [self.cancelTaskView.endView setHidden:true];
    [manager downloadVideos:videoArr withProgressHandle:^(NSProgress *progress,NSString *index){
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //下载过程中由多个线程返回downloadProgress，无法给progress赋值进度，所以要选出主线程
            if (progress) {
                NSString *currentSize=[FGTool convertSize:progress.completedUnitCount];
                NSString *totalSize=[FGTool convertSize:progress.totalUnitCount];
                //            NSLog(@"当前第【%d】个视频下载进度：%@",i+1,[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]);
                //                                _progressView.progress=[[FGDownloadManager shredManager] lastProgress:model.url];
//                for (int i = 1; i<=videoArr.count;) {
//                    if ((int)progress == 1.0) {
//                        i++;
//                    }
                    [self.cancelTaskView.centLabel setText:[NSString stringWithFormat:@"%@/%lu",index,(unsigned long)videoArr.count]];
//                }
                
                self.cancelTaskView.progress.progress = progress.fractionCompleted;
//                [self.cancelTaskView.percentLabel setText:[downloadProgresslocalizedDescription substringToIndex:4]];//百分比
                [self.cancelTaskView.percentLabel setText:progress.localizedDescription];//百分比
                [self.cancelTaskView.byteLabel setText:[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]];
            }
        }];
    } completion:^(NSArray *resultArray) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.cancelTaskView.endView setHidden:false];
        });
        //                                 5秒后自动隐藏
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[GFAlertView sharedMask] dismiss];
        });
        NSLog(@"下载完成");
    }];
    
//    [manager downloadVideos:videoArr withTaskView:self.cancelTaskView completion:^(NSArray *resultArray) {
//
//        NSLog(@"下载完成");
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.cancelTaskView.endView setHidden:false];
//        });
//        //                                 5秒后自动隐藏
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            [[GFAlertView sharedMask] dismiss];
//        });
//    } failure:^(NSError *err) {
//        NSLog(@"err = %@",err);
//    }];
    
    
    
    
}


@end
