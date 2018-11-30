//
//  GKDownloadManager.m
//  Record
//
//  Created by L on 2018/9/6.
//  Copyright © 2018年 L. All rights reserved.
//

#import "GKDownloadManager.h"
#import "SDWebImageDownloader.h"
#import <AFNetworking/AFNetworking.h>
#import "FGTool.h"
#import "GFAlertView.h"
@interface GKDownloadManager()

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, strong) NSMutableArray *imageList;

@property (nonatomic, strong) GFDownLoadView *cancelTaskView;

@end

@implementation GKDownloadManager

#pragma mark - 设置回调的方法

-(void)downManagerProgressBlockHandle:(DownManagerProgressBlock)downManagerProgressBlockHandle
{
    self.progressBlockHandle = downManagerProgressBlockHandle;
}

/**
 批量下载图片
 保持顺序;
 全部下载完成后才进行回调;
 回调结果中,下载正确和失败的状态保持与原先一致的顺序;
 
 @return resultArray 中包含两类对象:UIImage , NSError
 */
+ (void)downloadImages0:(NSArray<NSString *> *)imgsArray completion:(void(^)(NSArray *resultArray))completionBlock {
    SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
    manager.downloadTimeout = 20;
    __block NSMutableDictionary *resultDict = [NSMutableDictionary new];
    for(int i=0;i<imgsArray.count;i++) {
        NSString *imgUrl = [imgsArray objectAtIndex:i];
//        [manager downloadImageWithURL:[NSURL URLWithString:imgUrl]
//                              options:SDWebImageDownloaderUseNSURLCache|SDWebImageDownloaderScaleDownLargeImages
//                             progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//        [manager downloadImageWithURL:[NSURL URLWithString:imgUrl] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            <#code#>
//        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//            <#code#>
//        }]
        [manager downloadImageWithURL:[NSURL URLWithString:imgUrl]
                             options:SDWebImageDownloaderUseNSURLCache
                             progress:^(NSInteger receivedSize, NSInteger expectedSize , NSURL * _Nullable targetURL) {
                                 NSLog(@"当前【第%d个】进度：%ld/%ld",i+1,(long)receivedSize,expectedSize);
                             } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                 if(finished){
                                     if(error){
                                         //在对应的位置放一个error对象
                                         [resultDict setObject:error forKey:@(i)];
                                     }else{
                                         [resultDict setObject:image forKey:@(i)];
                                     }
                                     if(resultDict.count == imgsArray.count) {
                                         //全部下载完成
                                         NSArray *resultArray = [GKDownloadManager createDownloadResultArray:resultDict count:imgsArray.count];
                                         if(completionBlock){
                                             completionBlock(resultArray);
                                         }
                                     }
                                 }
                             }];
    }
}

+ (void)downloadImages2:(NSArray<NSString *> *)imgsArray completion:(void(^)(NSArray *resultArray))completionBlock {
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    for(int i=0;i<imgsArray.count;i++) {
        NSString *imgUrl = [imgsArray objectAtIndex:i];
        NSObject *resultObject = [GKDownloadManager getSDWebImageDownloader:imgUrl count:i];
        if (resultObject != nil) {
            [resultDict setObject:resultObject forKey:@(i)];
        }else{
//            sleep(<#unsigned int#>);
        }
    }
    if(resultDict.count == imgsArray.count) {
        //全部下载完成
        NSArray *resultArray = [GKDownloadManager createDownloadResultArray:resultDict count:imgsArray.count];
        if(completionBlock){
            completionBlock(resultArray);
        }
    }
}

+ (NSArray *)createDownloadResultArray:(NSDictionary *)dict count:(NSInteger)count {
    NSMutableArray *resultArray = [NSMutableArray new];
    for(int i=0;i<count;i++) {
        NSObject *obj = [dict objectForKey:@(i)];
        [resultArray addObject:obj];
    }
    return resultArray;
}

+ (NSObject *)getSDWebImageDownloader:(NSString *)imgUrl count:(NSInteger)count{
    __block NSObject *ob;
    SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
    manager.downloadTimeout = 20;
    [manager downloadImageWithURL:[NSURL URLWithString:imgUrl]
                          options:SDWebImageDownloaderUseNSURLCache
                         progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                             NSLog(@"当前【第%ld个】进度：%ld/%ld",count+1,(long)receivedSize,expectedSize);
                             NSLog(@"%f",(1.0 * receivedSize / expectedSize));
                         } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                             if(finished){
                                 if(error){
                                     //在对应的位置放一个error对象
                                     ob = error;
//                                     return error;
                                 }else{
                                     ob = image;
//                                     return image;
                                 }
                             }
                         }];
    return ob;
}

+ (void)downloadImages3:(NSArray<NSString *> *)imgsArray completion:(void(^)(NSArray *resultArray))completionBlock {
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("com.download.task", DISPATCH_QUEUE_SERIAL);
    //设置信号总量为1，保证只有一个进程执行
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for(int i=0;i<imgsArray.count;i++) {
        dispatch_async(queue, ^(){
        //等待信号量
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *imgUrl = [imgsArray objectAtIndex:i];
        NSLog(@"imgUrl = %@",imgUrl);
        SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
        manager.downloadTimeout = 20;
        [manager downloadImageWithURL:[NSURL URLWithString:imgUrl]
                              options:SDWebImageDownloaderUseNSURLCache
                             progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                 NSLog(@"当前【第%d个】进度：%ld/%ld",i+1,(long)receivedSize,expectedSize);
                                 NSLog(@"%3.2lf\%%",100*(1.0 * receivedSize / expectedSize));
                             } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                 if(finished){
                                     if(error){
                                         //在对应的位置放一个error对象
                                         [resultDict setObject:error forKey:@(i)];
                                     }else{
                                         [resultDict setObject:image forKey:@(i)];
                                     }
                                     if(resultDict.count == imgsArray.count) {
                                         //全部下载完成
                                         NSArray *resultArray = [GKDownloadManager createDownloadResultArray:resultDict count:imgsArray.count];
                                         if(completionBlock){
                                             completionBlock(resultArray);
                                         }
                                     }
                                     NSLog(@"🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁");
                                     if(i+1 == imgsArray.count){
                                         //所有方法执行完
                                     }
                                     dispatch_semaphore_signal(semaphore);  //发送一个信号
                                 }
                             }];
        });
    }
//    for (int i = 0; i<10; i++) {
//        dispatch_async(queue, ^(){
//            //等待信号量
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//            NSURL *URL = [NSURL URLWithString:str];
//            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//            NSString *downLocalPath = [self unzipDestinationPathForKey:@"downLoad.zip"];//下载到本地的zip地址
//            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//                NSLog(@"%f",(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount));
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    //执行进度条的页面刷新
//                });
//            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                return [NSURL fileURLWithPath:downLocalPath isDirectory:NO];
//            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//                NSLog(@"%d---%d",i,i);
//                if(i == 9){
//                    //所有方法执行完
//                }
//                dispatch_semaphore_signal(semaphore);  //发送一个信号
//            }];
//            [downloadTask resume];
//        });
//    }
}

- (void)downloadImages:(NSArray<NSString *> *)imgsArray withProgressHandle:(DownManagerProgressBlock)progresshandle completion:(void(^)(NSArray *resultArray))completionBlock{

}

- (void)downloadVideos:(NSArray<NSString *> *)imgsArray withProgressHandle:(DownManagerProgressBlock)progresshandle completion:(void(^)(NSArray *resultArray))completionBlock{
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("com.download.task.vidoes", DISPATCH_QUEUE_SERIAL);
    //设置信号总量为1，保证只有一个进程执行
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    //创建文件夹
    [GKDownloadManager createDirVideos];
    for(int i=0;i<imgsArray.count;i++) {
        NSString *downloadUrl = [imgsArray objectAtIndex:i];
        dispatch_async(queue, ^(){
            //等待信号量
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadVideoList]];
            BOOL isAllowLoad = YES;
            for (NSDictionary *videoDic in array) {
                if ([downloadUrl isEqualToString:videoDic[@"url"]]) {
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
                                  @"url":downloadUrl,
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
            NSString *urlstr = downloadUrl;
            urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:urlstr];
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            //                    NSString *dateStr = [[ZYPHelper  shareHelper] dateToString:[NSDate date] withDateFormat:@"YYYYMMDDHHmmSS"];
            NSString *savePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[imgsArray objectAtIndex:i]]];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"video/mpeg",@"video/mp4",@"audio/mp3",nil];//可下载@"text/json", @"text/javascript",@"text/html",@"video/mpeg",@"video/mp4",@"audio/mp3"等
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSString  *fullPath = savePath;//要保存的沙盒路径
            NSURLRequest *request1 = [NSURLRequest requestWithURL:url];//在线路径
            NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request1 progress:^(NSProgress *downloadProgress) {
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    //下载过程中由多个线程返回downloadProgress，无法给progress赋值进度，所以要选出主线程
////                    NSLog(@"downloadProgress");
                    if (downloadProgress) {
                        //执行过程的回调
//                        if (self.progressBlockHandle) {
//                            NSLog(@"self.progressBlockHandle");
//                            self.progressBlockHandle(downloadProgress);
//                        }
                        progresshandle(downloadProgress);
                    }
//                }];
//                progresshandle = downloadProgress;
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
                    NSLog(@"🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁");
                    if(i+1 == imgsArray.count){
                        if(completionBlock){
                            completionBlock(@[]);
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.cancelTaskView.endView setHidden:false];
                        });
                        //                                 5秒后自动隐藏
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [[GFAlertView sharedMask] dismiss];
                        });
                    }
                    dispatch_semaphore_signal(semaphore);  //发送一个信号
                }
            }];
            [task resume];
        });
    }
}

- (void)downloadVideos:(NSArray<NSString *> *)imgsArray withTaskView:(GFDownLoadView *)taskView completion:(void(^)(NSArray *resultArray))completionBlock failure:(void (^)(NSError *))failure
{
    [[GFAlertView sharedMask] show:self.cancelTaskView withType:0];
    [self.cancelTaskView.endView setHidden:true];
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("com.download.task.vidoes1", DISPATCH_QUEUE_SERIAL);
    //设置信号总量为1，保证只有一个进程执行
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    //创建文件夹
    [GKDownloadManager createDirVideos];
    for(int i=0;i<imgsArray.count;i++) {
        NSString *downloadUrl = [imgsArray objectAtIndex:i];
        dispatch_async(queue, ^(){
            //等待信号量
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadVideoList]];
            BOOL isAllowLoad = YES;
            for (NSDictionary *videoDic in array) {
                if ([downloadUrl isEqualToString:videoDic[@"url"]]) {
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
                                  @"url":downloadUrl,
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
            NSString *urlstr = downloadUrl;
            urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:urlstr];
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            //                    NSString *dateStr = [[ZYPHelper  shareHelper] dateToString:[NSDate date] withDateFormat:@"YYYYMMDDHHmmSS"];
            NSString *savePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[imgsArray objectAtIndex:i]]];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"video/mpeg",@"video/mp4",@"audio/mp3",nil];//可下载@"text/json", @"text/javascript",@"text/html",@"video/mpeg",@"video/mp4",@"audio/mp3"等
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSString  *fullPath = savePath;//要保存的沙盒路径
            NSURLRequest *request1 = [NSURLRequest requestWithURL:url];//在线路径
            NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request1 progress:^(NSProgress *downloadProgress) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    //                    //下载过程中由多个线程返回downloadProgress，无法给progress赋值进度，所以要选出主线程
                    if (downloadProgress) {
                        NSString *currentSize=[FGTool convertSize:downloadProgress.completedUnitCount];
                        NSString *totalSize=[FGTool convertSize:downloadProgress.totalUnitCount];
                        NSLog(@"当前第【%d】个视频下载进度：%@",i+1,[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]);
                        [taskView.centLabel setText:[NSString stringWithFormat:@"%d/%d",i+1,5]];
                        taskView.progress.progress = downloadProgress.fractionCompleted;
                        //                                [self.cancelTaskView.percentLabel setText:[downloadProgresslocalizedDescription substringToIndex:4]];//百分比
                        [taskView.percentLabel setText:downloadProgress.localizedDescription];//百分比
                        [taskView.byteLabel setText:[NSString stringWithFormat:@"%@/%@",currentSize,totalSize]];
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
                    failure(error);
                }else{
                    //下载完成 保存到本地相册
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
                    NSLog(@"🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁🍁");
                    if(i+1 == imgsArray.count){
                        if(completionBlock){
                            completionBlock(@[]);
                        }
                    }
                    
                    dispatch_semaphore_signal(semaphore);  //发送一个信号
                }
            }];
            [task resume];
        });
    }
}

#pragma mark 使用 NSHomeDirectory() 创建文件目录videos And images
+ (void) createDirVideos {
    
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

+ (void) createDirImages {
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


@end
