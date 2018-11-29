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
//  MediaDetailVC.m
//  DookayProject
//
//  Created by dookay_73 on 2018/9/27.
//  Copyright © 2018年 Dookay. All rights reserved.
//

#import "MediaDetailVC.h"

#import "DKAVPlayer.h"
#import "DKFullScreenVC.h"

#import "MediaReportVC.h"

#import "MediaDownloadVC.h"
#import "DKDownloadTask.h"
#import "MediaEditView.h"

#import "FGDownloadManager.h"
#import <AFNetworking/AFNetworking.h>
#import "FGTool.h"
#import "GFAlertView.h"
#import "GFDownLoadView.h"
#define kCachePath (NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0])
@interface MediaDetailVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DKAVPlayer *avPlayer;
@property (nonatomic, strong) DKFullScreenVC *fullPlayer;


@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) MediaModel *model;

@property (nonatomic, strong) GFDownLoadView *cancelTaskView;

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, strong) NSMutableArray *imageList;

@end

@implementation MediaDetailVC
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
    // Do any additional setup after loading the view.
    self.title = @"视频详情";
//0x1D1C1F
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];

    _UrlStr = @"http://v.dansewudao.com/444fccb3590845a799459f6154d2833f/fe86a70dc4b8497f828eaa19058639ba-6e51c667edc099f5b9871e93d0370245-sd.mp4";
//    _UrlStr = @"rtsp://192.72.1.1/liveRTSP/av1";
//    _UrlStr = @"http://192.72.1.1/SD/Normal/NK_D20181123_105701_1440.MP4";
    self.avPlayer.mediaUrlStr = [NSString stringWithFormat:@"%@",_UrlStr];

}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"videoCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        [cell addSubview:self.avPlayer];
    }else{
        UIButton *downLoadBtn = [MyTool buttonWithTitle:@"下载"
                                             titleColor:[UIColor blackColor]
                                              titleFont:[MyTool mediumFontWithSize:16*ScaleX]];
        [cell addSubview:downLoadBtn];

        [downLoadBtn addTarget:self
                        action:@selector(clickedDownloadPicAction)
              forControlEvents:UIControlEventTouchDown];
        
        UIButton *shareBtn = [MyTool buttonWithTitle:@"分享"
                                          titleColor:[UIColor blackColor]
                                           titleFont:[MyTool mediumFontWithSize:16*ScaleX]];
        [cell addSubview:shareBtn];
        
        [downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).offset(-mainWidth/4);
            make.top.equalTo(cell).offset(20*ScaleX);
            make.width.mas_equalTo(100*ScaleX);
            make.height.mas_equalTo(40*ScaleX);
        }];
        [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell).offset(mainWidth/4);
            make.centerY.equalTo(downLoadBtn);
            make.width.mas_equalTo(100*ScaleX);
            make.height.mas_equalTo(40*ScaleX);
        }];
    }
    
    return cell;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return mainWidth*9/16;
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - action
- (void)clickedDownloadAction
{
//    WS(weakSelf);
    MediaEditView *editView = [[MediaEditView alloc] init];
    [editView showEditView];
    [editView setGetVideoNameBlock:^(NSString *name) {
        
        [[GFAlertView sharedMask] show:self.cancelTaskView withType:0];
        [self.cancelTaskView.endView setHidden:true];
        if (name.length > 0) {
//            MediaModel *model = [[MediaModel alloc] init];
//            model.title = name;
//            model.downloadUrl = weakSelf.UrlStr;
            NSArray *nameArr = @[@"1",@"2",@"3",@"4",@"5"];
            NSString *music1 = @"http://192.72.1.1/SD/Normal/NK_D20181127_172224_1440.MP4";
            NSString *music2 = @"http://192.72.1.1/SD/Normal/NK_D20181127_172513_1440.MP4";
            NSString *music3 = @"http://192.72.1.1/SD/Normal/NK_D20181128_155308_1440.MP4";
            NSString *music4 = @"http://192.72.1.1/SD/Normal/NK_D20181128_155342_1440.MP4";
            NSString *music5 = @"http://192.72.1.1/SD/Normal/NK_D20181128_155353_1440.MP4";
            NSArray *UrlStr = @[music1,music2,music3,music4,music5];
//            NSArray *UrlStr = @[weakSelf.UrlStr,weakSelf.UrlStr,weakSelf.UrlStr,weakSelf.UrlStr,weakSelf.UrlStr];
//            NSArray *UrlStr = @[music1,music1,music1,music1,music1];
            // 创建队列
            dispatch_queue_t queue = dispatch_queue_create("com.download.task", DISPATCH_QUEUE_SERIAL);
            //设置信号总量为1，保证只有一个进程执行
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            for(int i=0;i<5;i++) {
                MediaModel *model = [[MediaModel alloc] init];
                model.title = [nameArr objectAtIndex:i];
                model.downloadUrl = [UrlStr objectAtIndex:i];
                dispatch_async(queue, ^(){
                    //等待信号量
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    /*
//                    [[DKDownloadTask taskShared] startDownloadVideoWithModel:model];
                    //添加下载任务
//                    NSLog(@"[FGDownloadManager shredManager]");
//                    NSString *destinationPath=[kCachePath stringByAppendingPathComponent:model.title];
//                    [[FGDownloadManager shredManager] downloadUrl:model.downloadUrl toPath:destinationPath process:^(float progress, NSString *sizeString, NSString *speedString) {
//                        //更新进度条的进度值
//                        NSLog(@"progress = %lf,sizeString = %@,speedString = %@",progress,sizeString,speedString);
////                        weakCell.progressView.progress=progress;
//                        //更新进度值文字
////                        weakCell.progressLabel.text=[NSString stringWithFormat:@"%.2f%%",progress*100];
//                        //更新文件已下载的大小
////                        weakCell.sizeLabel.text=sizeString;
//                        //显示网速
////                        weakCell.speedLabel.text=speedString;
////                        if(speedString)
////                            weakCell.speedLabel.hidden=NO;
//
//                    } completion:^{
//
//                        NSLog(@"🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁");
//                        if(i+1 == 5){
//                            //所有方法执行完
////                            MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
////                            [weakSelf.navigationController pushViewController:downloadVC animated:YES];
//                        }
//                        dispatch_semaphore_signal(semaphore);  //发送一个信号
////                        [sender setTitle:@"完成" forState:UIControlStateNormal];
////                        sender.enabled=NO;
////                        weakCell.speedLabel.hidden=YES;
////                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@下载完成✅",model.name] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
////                        [alert show];
//                    } failure:^(NSError *error) {
//                    dispatch_semaphore_signal(semaphore);  //发送一个信号
////                        [[FGDownloadManager shredManager] cancelDownloadTask:model.url];
////                        [sender setTitle:@"恢复" forState:UIControlStateNormal];
////                        weakCell.speedLabel.hidden=YES;
////                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
////                        [alert show];
//
//                    }];
                    */
                    
                    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadVideoList]];
                    BOOL isAllowLoad = YES;
                    for (NSDictionary *videoDic in array) {
//                        NSLog(@"videoDic = %@",videoDic);
                        if ([model.downloadUrl isEqualToString:videoDic[@"url"]]) {
                            isAllowLoad = NO;
                            break;
                        }
                    }
                    //如果视频已经存在，则返回不允许下载【留至版本更新】
#pragma mark -//如果视频已经存在，则返回不允许下载【留至版本更新】
                    NSDictionary *dic = @{
                                          @"isDownload":@(NO),
                                          @"bytes":@(0),
                                          @"fileName":@"",
                                          @"url":model.downloadUrl,
                                          @"time":@"",
                                          @"format":@{},
                                          };
                    if (!isAllowLoad) {
//                        continue;
//                        dispatch_semaphore_signal(semaphore);  //发送一个信号
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                        });
//                        return;
                    }else{
                        [array insertObject:dic atIndex:0];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:array] forKey:kDownloadVideoList];
                    }
                    self.videoList = array;
                    NSString *urlstr = model.downloadUrl;
                    urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSURL *url = [NSURL URLWithString:urlstr];
                    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//                    NSString *dateStr = [[ZYPHelper  shareHelper] dateToString:[NSDate date] withDateFormat:@"YYYYMMDDHHmmSS"];
                    NSString *savePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",nameArr]];
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"video/mpeg",@"video/mp4",@"audio/mp3",nil];//可下载@"text/json", @"text/javascript",@"text/html",@"video/mpeg",@"video/mp4",@"audio/mp3"等
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    NSString  *fullPath = savePath;//要保存的沙盒路径
                    NSURLRequest *request1 = [NSURLRequest requestWithURL:url];//在线路径
                    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request1 progress:^(NSProgress *downloadProgress) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //下载过程中由多个线程返回downloadProgress，无法给progress赋值进度，所以要选出主线程
                            if (downloadProgress) {
                                NSString *currentSize=[FGTool convertSize:downloadProgress.completedUnitCount];
                                NSString *totalSize=[FGTool convertSize:downloadProgress.totalUnitCount];
                                NSLog(@"当前第【%d】个视频下载进度：%@",i+1,[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]);
//                                _progressView.progress=[[FGDownloadManager shredManager] lastProgress:model.url];
                                [self.cancelTaskView.centLabel setText:[NSString stringWithFormat:@"%d/%d",i+1,5]];
                                self.cancelTaskView.progress.progress = downloadProgress.fractionCompleted;
//                                [self.cancelTaskView.percentLabel setText:[downloadProgresslocalizedDescription substringToIndex:4]];//百分比
                                [self.cancelTaskView.percentLabel setText:downloadProgress.localizedDescription];//百分比
                                [self.cancelTaskView.byteLabel setText:[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]];
                            }
                        }];
                    } destination:^NSURL *(NSURL *targetPath,NSURLResponse *response) {
                        NSString *path_sandox =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES)[0];
                        NSLog(@"path_sandox:%@",path_sandox);
                        NSString *path = [path_sandox stringByAppendingPathComponent:response.suggestedFilename];
                        NSLog(@"path:%@",path);
                        return [NSURL fileURLWithPath:fullPath];
                    } completionHandler:^(NSURLResponse *_Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                        if(error){
//                            self.HUD.hidden = YES;
//                            [RemindView showHUDWithText:@"下载失败" delay:1 onView:kYBKeyWindow];
                            
                        }else{
                            //下载完成 保存到本地相册
                            //创建文件夹
                            [self createDirVideos];
                            //1.拿到cache文件夹的路径
                            NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
                            //2,拿到cache文件夹和文件名
                            NSString *fileCachePath=[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"videos/%@",response.suggestedFilename]];
                            NSString *fileName = response.suggestedFilename;
                            NSLog(@"location = %@\ncache = %@\nfilePath =%@\nfileName = %@\n",filePath,cachePath,fileCachePath,fileName);
                            //保存至缓存地址：cache
                            [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:fileCachePath] error:nil];
                            //    //3，保存视频到相册
                            //    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)) {
                            //        //保存相册核心代码
                            //        UISaveVideoAtPathToSavedPhotosAlbum(file, self, nil, nil);
                            //    }
                            NSString *videoUrl = response.URL.description;
//                            NSLog(@"videoUrl = %@",videoUrl);
                            for (int i = 0; i < self.videoList.count; i++) {
                                NSDictionary *dic = self.videoList[i];
                                if ([videoUrl rangeOfString:dic[@"url"]].location != NSNotFound) {
                                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dic];
                                    [dict setValue:@(YES) forKey:@"isDownload"];
                                    [dict setValue:@"2048MB" forKey:@"bytes"];
                                    [dict setValue:fileName forKey:@"fileName"];
                                    [dict setValue:videoUrl forKey:@"url"];
                                    [dict setValue:@"time" forKey:@"time"];
                                    NSDictionary *dic = @{
                                                          @"size":@"2560x1440",
                                                          @"fps":@"25",
                                                          @"time":@"6s",
                                        };
                                    [dict setValue:dic forKey:@"format"];
                                    [self.videoList replaceObjectAtIndex:i withObject:dict];
                                    break;
                                }
                            }
                            NSLog(@"self.videoList.count = %lu",(unsigned long)self.videoList.count);
                            for (NSDictionary *dict in self.videoList) {
                                NSLog(@"dict = %@",dict);
                            }
                            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:self.videoList] forKey:kDownloadVideoList];
                            
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                self.refreshDownloadSuccessCellBlock(videoUrl);
//                            });
//                            [ZLPhotoManager saveVideoToAblum:[NSURL fileURLWithPath:fullPath] completion:^(BOOL suc, PHAsset *asset) {
//                                if (suc==YES) {
//                                    dispatch_sync(dispatch_get_main_queue(), ^{
//                                        self.HUD.hidden = YES;
//                                        [RemindView showHUDWithText:@"存入相册成功!" delay:1 onView:kYBKeyWindow];
//                                    });
//                                }else if (suc == NO){
//                                    dispatch_sync(dispatch_get_main_queue(), ^{
//                                        self.HUD.hidden = YES;
//                                        [RemindView showHUDWithText:@"存入相册失败!" delay:1 onView:kYBKeyWindow];
//                                    });
//                                }
//                            }];
                            NSLog(@"🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁");
                            if(i+1 == 5){
                                //所有方法执行完
    //                            MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
    //                            [weakSelf.navigationController pushViewController:downloadVC animated:YES];
//                                [self.cancelTaskView action_Cancel:<#(UIButton *)#>];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self.cancelTaskView.endView setHidden:false];
                                });
//                                 5秒后自动隐藏
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    
                                    [[GFAlertView sharedMask] dismiss];
                                });
//                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                    [self.cancelTaskView.endView setHidden:true];
//                                });
                            }
                            dispatch_semaphore_signal(semaphore);  //发送一个信号
                        }
                    }];
                    [task resume];
                });
            }
//            MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
//            [weakSelf.navigationController pushViewController:downloadVC animated:YES];
//            [[DKDownloadTask taskShared] startDownloadVideoWithModel:model];
//            MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
//            [weakSelf.navigationController pushViewController:downloadVC animated:YES];
        }
    }];
}

- (void)clickedDownloadPicAction
{
    //    WS(weakSelf);
    MediaEditView *editView = [[MediaEditView alloc] init];
    [editView showEditView];
    [editView setGetVideoNameBlock:^(NSString *name) {
        [[GFAlertView sharedMask] show:self.cancelTaskView withType:0];
        [self.cancelTaskView.endView setHidden:true];
        if (name.length > 0) {
            //            MediaModel *model = [[MediaModel alloc] init];
            //            model.title = name;
            //            model.downloadUrl = weakSelf.UrlStr;
            NSArray *nameArr = @[@"1",@"2",@"3",@"4",@"5"];
            NSString *pic1 = @"http://192.72.1.1/SD/Photo/NK_P20181123_105721_0_4.JPG";
            NSString *pic2 = @"http://192.72.1.1/SD/Photo/NK_P20181123_105727_0_4.JPG";
            NSString *pic3 = @"http://192.72.1.1/SD/Photo/NK_P20181123_105749_0_4.JPG";
            NSString *pic4 = @"http://192.72.1.1/SD/Photo/NK_P20181123_105729_0_4.JPG";
            NSString *pic5 = @"http://192.72.1.1/SD/Photo/NK_P20181123_105746_0_4.JPG";
            NSArray *UrlStr = @[pic1,pic2,pic3,pic4,pic5];
            // 创建队列
            dispatch_queue_t queue = dispatch_queue_create("com.download.task2", DISPATCH_QUEUE_SERIAL);
            //设置信号总量为1，保证只有一个进程执行
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            for(int i=0;i<5;i++) {
                MediaModel *model = [[MediaModel alloc] init];
                model.title = [nameArr objectAtIndex:i];
                model.downloadUrl = [UrlStr objectAtIndex:i];
                dispatch_async(queue, ^(){
                    //等待信号量
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadImageList]];
                    BOOL isAllowLoad = YES;
                    for (NSDictionary *picDic in array) {
                        //                        NSLog(@"videoDic = %@",picDic);
                        if ([model.downloadUrl isEqualToString:picDic[@"url"]]) {
                            isAllowLoad = NO;
                            break;
                        }
                    }
                    //如果视频已经存在，则返回不允许下载【留至版本更新】
#pragma mark -//如果视频已经存在，则返回不允许下载【留至版本更新】
                    NSDictionary *dic = @{
                                          @"isDownload":@(NO),
                                          @"bytes":@(0),
                                          @"fileName":@"",
                                          @"url":model.downloadUrl,
                                          @"time":@"",
                                          @"format":@{},
                                          };
                    if (!isAllowLoad) {
                        //                        continue;
                        //                        dispatch_semaphore_signal(semaphore);  //发送一个信号
                        //                        dispatch_async(dispatch_get_main_queue(), ^{
                        //                        });
                        //                        return;
                    }else{
                        [array insertObject:dic atIndex:0];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:array] forKey:kDownloadImageList];
                    }
                    self.imageList = array;
                    NSString *urlstr = model.downloadUrl;
                    urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSURL *url = [NSURL URLWithString:urlstr];
                    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                    //                    NSString *dateStr = [[ZYPHelper  shareHelper] dateToString:[NSDate date] withDateFormat:@"YYYYMMDDHHmmSS"];
//                    NSString *savePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",nameArr]];
                    //2,拿到cache文件夹和文件名
                    NSString *savePath=[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@.jpg",nameArr]];
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//                    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                    /* 创建网络下载对象 */
                    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/html", nil ];
//                    mgr.responseSerializer.acceptableContentTypes =  [NSSetsetWithObject:@"text/plain"];
//                    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//                    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/JPG",@"image/png",@"image/jepg",nil];//可下载@"text/json", @"text/javascript",@"text/html",@"video/mpeg",@"video/mp4",@"audio/mp3"等
//                    manager.requestSerializer= [AFHTTPRequestSerializer serializer];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    NSString  *fullPath = savePath;//要保存的沙盒路径
                    NSURLRequest *request1 = [NSURLRequest requestWithURL:url];//在线路径
                    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request1 progress:^(NSProgress *downloadProgress) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //下载过程中由多个线程返回downloadProgress，无法给progress赋值进度，所以要选出主线程
                            if (downloadProgress) {
                                NSString *currentSize=[FGTool convertSize:downloadProgress.completedUnitCount];
                                NSString *totalSize=[FGTool convertSize:downloadProgress.totalUnitCount];
                                NSLog(@"当前第【%d】个视频下载进度：%@",i+1,[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]);
                                //                                _progressView.progress=[[FGDownloadManager shredManager] lastProgress:model.url];
                                [self.cancelTaskView.centLabel setText:[NSString stringWithFormat:@"%d/%d",i+1,5]];
                                self.cancelTaskView.progress.progress = downloadProgress.fractionCompleted;
                                //                                [self.cancelTaskView.percentLabel setText:[downloadProgresslocalizedDescription substringToIndex:4]];//百分比
                                [self.cancelTaskView.percentLabel setText:downloadProgress.localizedDescription];//百分比
                                [self.cancelTaskView.byteLabel setText:[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]];
                            }
                        }];
                    } destination:^NSURL *(NSURL *targetPath,NSURLResponse *response) {
                        NSString *path_sandox =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES)[0];
                        NSLog(@"path_sandox:%@",path_sandox);
                        NSString *path = [path_sandox stringByAppendingPathComponent:response.suggestedFilename];
                        NSLog(@"path:%@",path);
                        return [NSURL fileURLWithPath:fullPath];
                        //好像没用上
//                        return [weakSelf createDirectoryForDownloadItemFromURL:targetPath];
                    } completionHandler:^(NSURLResponse *_Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                        if(error){
                            //                            self.HUD.hidden = YES;
                            //                            [RemindView showHUDWithText:@"下载失败" delay:1 onView:kYBKeyWindow];
                            NSLog(@"error.domain = %@!",error.domain);
                            NSLog(@"error.code = %ld!",error.code);
                            NSLog(@"error.userInfo = %@!",error.userInfo);
                        }else{
                            //下载完成 保存到本地相册
                            //创建文件夹
                            [self createDirVideos];
                            //1.拿到cache文件夹的路径
                            NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
                            //2,拿到cache文件夹和文件名
                            NSString *fileCachePath=[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@",response.suggestedFilename]];
                            NSString *fileName = response.suggestedFilename;
                            NSLog(@"location = %@\ncache = %@\nfilePath =%@\nfileName = %@\n",filePath,cachePath,fileCachePath,fileName);
                            //保存至缓存地址：cache
                            [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:fileCachePath] error:nil];
                            //    //3，保存视频到相册
                            //    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)) {
                            //        //保存相册核心代码
                            //        UISaveVideoAtPathToSavedPhotosAlbum(file, self, nil, nil);
                            //    }
                            NSString *videoUrl = response.URL.description;
                            //                            NSLog(@"videoUrl = %@",videoUrl);
                            for (int i = 0; i < self.imageList.count; i++) {
                                NSDictionary *dic = self.imageList[i];
                                if ([videoUrl rangeOfString:dic[@"url"]].location != NSNotFound) {
                                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dic];
                                    [dict setValue:@(YES) forKey:@"isDownload"];
                                    [dict setValue:@"2048MB" forKey:@"bytes"];
                                    [dict setValue:fileName forKey:@"fileName"];
                                    [dict setValue:videoUrl forKey:@"url"];
                                    [dict setValue:@"time" forKey:@"time"];
                                    NSDictionary *dic = @{
                                                          @"size":@"2560x1440",
                                                          @"fps":@"25",
                                                          @"time":@"6s",
                                                          };
                                    [dict setValue:dic forKey:@"format"];
                                    [self.imageList replaceObjectAtIndex:i withObject:dict];
                                    break;
                                }
                            }
                            NSLog(@"self.imageList.count = %lu",(unsigned long)self.imageList.count);
                            for (NSDictionary *dict in self.imageList) {
                                NSLog(@"dict = %@",dict);
                            }
                            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:self.imageList] forKey:kDownloadImageList];
                            NSLog(@"🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁");
                            if(i+1 == 5){
                                //所有方法执行完
                                //                            MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
                                //                            [weakSelf.navigationController pushViewController:downloadVC animated:YES];
                                //                                [self.cancelTaskView action_Cancel:<#(UIButton *)#>];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self.cancelTaskView.endView setHidden:false];
                                });
                                //                                 5秒后自动隐藏
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    
                                    [[GFAlertView sharedMask] dismiss];
                                });
                                //                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                //                                    [self.cancelTaskView.endView setHidden:true];
                                //                                });
                            }
                            dispatch_semaphore_signal(semaphore);  //发送一个信号
                        }
                    }];
                    [task resume];
                });
            }
            //            MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
            //            [weakSelf.navigationController pushViewController:downloadVC animated:YES];
            //            [[DKDownloadTask taskShared] startDownloadVideoWithModel:model];
            //            MediaDownloadVC *downloadVC = [[MediaDownloadVC alloc] init];
            //            [weakSelf.navigationController pushViewController:downloadVC animated:YES];
        }
    }];
}

#pragma mark 使用 NSHomeDirectory() 创建文件目录videos And images
- (void) createDirVideos {
    
    // NSHomeDirectory()：应用程序目录， @"Library/Caches/videos"：在tmp文件夹下创建videos 文件夹
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/videos"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) ) {
        
        // 在 tmp 目录下创建一个 temp 目录
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"+++++++++++++++++++%@",filePath);
}
- (void) createDirImages {
    // NSHomeDirectory()：应用程序目录， @"Library/Caches/images"：在tmp文件夹下创建images 文件夹
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/images"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) ) {
        
        // 在 tmp 目录下创建一个 temp 目录
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"+++++++++++++++++++%@",filePath);
}



#pragma mark - getter
- (DKAVPlayer *)avPlayer
{
    if (!_avPlayer) {
        _avPlayer = [[DKAVPlayer alloc] initWithFrame:CGRectMake(0, 0, mainWidth, mainWidth*9/16) andMediaURL:nil];
        _avPlayer.backgroundColor = UIColorFromRGB(0x1D1C1F);
        WS(weakSelf);
        [_avPlayer setClickedFullScreenBlock:^(BOOL isFullScreen) {
            if (isFullScreen) {
                weakSelf.avPlayer.isFullScreen = YES;
                weakSelf.fullPlayer = [[DKFullScreenVC alloc] init];
                [weakSelf.fullPlayer.view addSubview:weakSelf.avPlayer];
                weakSelf.avPlayer.frame = CGRectMake(0, 0, mainHeight, mainWidth);
                [weakSelf.tempbtn removeFromSuperview];
                [weakSelf presentViewController:weakSelf.fullPlayer animated:NO completion:nil];
            }else{
                weakSelf.avPlayer.isFullScreen = NO;
                [weakSelf.fullPlayer dismissViewControllerAnimated:NO completion:^{
                    weakSelf.avPlayer.frame = CGRectMake(0, 0, mainWidth, 200*ScaleX);
                    [weakSelf.tableView reloadData];
                }];

            }
        }];
        
    }
    return _avPlayer;
}


-(void)dealloc{
    [self.avPlayer pausePlay];
    self.avPlayer =nil;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat topY = 64;
        CGFloat height = mainHeight - topY;
        if (IS_IPHONE_X) {
            topY = 44 + X_head;
            height = mainHeight - topY - X_foot;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topY, mainWidth, height)
                                                  style:UITableViewStyleGrouped];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
