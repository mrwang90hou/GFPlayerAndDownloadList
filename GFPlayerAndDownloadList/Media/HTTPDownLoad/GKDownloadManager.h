//
//  GKDownloadManager.h
//  Record
//
//  Created by L on 2018/9/6.
//  Copyright © 2018年 L. All rights reserved.
//
#import "GKDownloadManager.h"
#import "SDWebImageDownloader.h"
#import "GFDownLoadView.h"
/**
 *  下载过程中的回调
 *
 *  @param didFinish      本次下载的文件大小
 *  @param didFinishTotal 至此一共下载文件的大小
 *  @param Total          一共需要下载文件的大小
 */
typedef void(^DownManagerProgressBlock)(NSProgress *progress);

@interface GKDownloadManager : NSObject




+ (void)downloadImages0:(NSArray<NSString *> *)imgsArray completion:(void(^)(NSArray *resultArray))completionBlock;
+ (void)downloadImages2:(NSArray<NSString *> *)imgsArray completion:(void(^)(NSArray *resultArray))completionBlock;
+ (void)downloadImages3:(NSArray<NSString *> *)imgsArray completion:(void(^)(NSArray *resultArray))completionBlock;
+ (NSArray *)createDownloadResultArray:(NSDictionary *)dict count:(NSInteger)count;
+ (NSObject *)getSDWebImageDownloader:(NSString *)imgUrl count:(NSInteger)count;



@property (nonatomic, copy)DownManagerProgressBlock progressBlockHandle;    //下载过程中的回调
//设置相关回调
- (void)downManagerProgressBlockHandle:(DownManagerProgressBlock)downManagerProgressBlockHandle;


- (void)downloadImages:(NSArray<NSString *> *)imgsArray withProgressHandle:(DownManagerProgressBlock)progresshandle completion:(void(^)(NSArray *resultArray))completionBlock;

- (void)downloadVideos:(NSArray<NSString *> *)imgsArray withProgressHandle:(DownManagerProgressBlock)progresshandle completion:(void(^)(NSArray *resultArray))completionBlock;
- (void)downloadVideos:(NSArray<NSString *> *)imgsArray withTaskView:(GFDownLoadView *)taskView completion:(void(^)(NSArray *resultArray))completionBlock failure:(void (^)(NSError *))failure;

@end
