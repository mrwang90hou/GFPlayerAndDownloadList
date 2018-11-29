//
//  FGDownloader.m
//  DownloaderDemo
//
//  Created by xgf on 15/9/21.
//  Copyright (c) 2015年 xgf. All rights reserved.
//

#import "FGDownloader.h"
#import "FGTool.h"
#import <UIKit/UIKit.h>

@implementation FGDownloader {
    NSString        *_url_string;
    NSString        *_destination_path;
    NSFileHandle    *_writeHandle;
    NSURLConnection *_con;
    long long       _lastSize;
    long long       _growth;
    NSTimer         *_timer;
}
//计算一次文件大小增加部分的尺寸
-(void)getGrowthSize {
    long long size=(long long)[[[[NSFileManager defaultManager] attributesOfItemAtPath:_destination_path error:nil] objectForKey:NSFileSize] integerValue];
    _growth=size-_lastSize;
    _lastSize=size;
}
-(instancetype)init {
    if(self=[super init]) {
        //每0.5秒计算一次文件大小增加部分的尺寸
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getGrowthSize) userInfo:nil repeats:YES];
    }
    return self;
}
/**
 * 获取对象的类方法
 */
+(instancetype)downloader {
    return [[[self class] alloc]init];
}
/**
 *  断点下载
 *
 *  @param urlString        下载的链接
 *  @param destinationPath  下载的文件的保存路径
 *  @param  process         下载过程中回调，会多次调用
 *  @param  completion      下载完成的回调
 *  @param  failure         下载失败的回调
 */
-(void)downloadUrl:(NSString *)urlString
            toPath:(NSString *)destinationPath
           process:(FGProcessHandle)process
        completion:(FGDownloadCompletionHandle)completion
           failure:(FGFailureHandle)failure {
    if(urlString && destinationPath) {
        _url_string=urlString;
        _destination_path=destinationPath;
        _process=process;
        _completion=completion;
        _failure=failure;
        
        NSURL *url=[NSURL URLWithString:urlString];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        BOOL fileExist=[fileManager fileExistsAtPath:destinationPath];
        if(fileExist) {
            long long length=(long long)[[[fileManager attributesOfItemAtPath:destinationPath error:nil] objectForKey:NSFileSize] integerValue];
            NSString *rangeString=[NSString stringWithFormat:@"bytes=%lld-",length];
            [request setValue:rangeString forHTTPHeaderField:@"Range"];
        }
        
        NSURLSession *session=[NSURLSession sharedSession];
        NSURLSessionTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //相关代码逻辑
        }];
        
//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:config
//                                                              delegate:self
//                                                         delegateQueue:[NSOperationQueue mainQueue]];
//        self.downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.downloadUrl]]];
//        [self.downloadTask resume];
        
        _con=[NSURLConnection connectionWithRequest:request delegate:self];

    }
}
- (void)downloadHost:(NSString *)host
               param:(NSString *)p
              toPath:(NSString *)destinationPath
             process:(FGProcessHandle)process
          completion:(FGDownloadCompletionHandle)completion
             failure:(FGFailureHandle)failure {
    if(host && destinationPath) {
        if(p != nil){
            _url_string=[NSString stringWithFormat:@"%@?%@",host,p];
        }else{
            _url_string = host;
        }
        _destination_path=destinationPath;
        _process=process;
        _completion=completion;
        _failure=failure;
        
        NSURL *url=[NSURL URLWithString:host];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        if(p != nil){
            request.HTTPBody = [p dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSFileManager *fileManager=[NSFileManager defaultManager];
        BOOL fileExist=[fileManager fileExistsAtPath:destinationPath];
        if(fileExist) {
            long long length=(long long)[[[fileManager attributesOfItemAtPath:destinationPath error:nil] objectForKey:NSFileSize] integerValue];
            NSString *rangeString=[NSString stringWithFormat:@"bytes=%lld-",length];
            [request setValue:rangeString forHTTPHeaderField:@"Range"];
        }
        _con=[NSURLConnection connectionWithRequest:request delegate:self];
    }
}
/**
 *  取消下载
 */
-(void)cancel {
    [self.con cancel];
    self.con=nil;
    if(_timer){
        [_timer invalidate];
    }
}
/**
 * 获取上一次的下载进度
 */
+(float)lastProgress:(NSString *)url {
    if(url){
        return [[NSUserDefaults standardUserDefaults]floatForKey:[NSString stringWithFormat:@"%@progress",url]];
    }
    return 0.0;
}
/**获取文件已下载的大小和总大小,格式为:已经下载的大小/文件总大小,如：12.00M/100.00M
 */
+(NSString *)filesSize:(NSString *)url {
    NSString *totalLebgthKey=[NSString stringWithFormat:@"%@totalLength",url];
    NSUserDefaults *usd=[NSUserDefaults standardUserDefaults];
    long long totalLength=(long long)[usd integerForKey:totalLebgthKey];
    if(totalLength==0){
        return @"0.00K/0.00K";
    }
    NSString *progressKey=[NSString stringWithFormat:@"%@progress",url];
    float progress=[[NSUserDefaults standardUserDefaults] floatForKey:progressKey];
    long long currentLength=progress*totalLength;
    
    NSString *currentSize=[FGTool convertSize:currentLength];
    NSString *totalSize=[FGTool convertSize:totalLength];
    return [NSString stringWithFormat:@"%@/%@",currentSize,totalSize];
}
/**
 *  获取系统可用存储空间
 *
 *  @return 系统空用存储空间，单位：字节
 */
-(long long)systemFreeSpace {
    
    NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDictionary *dict=[[NSFileManager defaultManager] attributesOfFileSystemForPath:docPath error:nil];
    return (long long)[[dict objectForKey:NSFileSystemFreeSize] integerValue];
}
#pragma mark - NSURLConnection
/**
 * 下载失败
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(_failure){
        _failure(error);
    }
}
/**
 * 接收到响应请求
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSString *key=[NSString stringWithFormat:@"%@totalLength",_url_string];
    NSUserDefaults *usd=[NSUserDefaults standardUserDefaults];
    long long totalLength=(long long)[usd integerForKey:key];
    if(totalLength==0) {
        [usd setInteger:response.expectedContentLength forKey:key];
        [usd synchronize];
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL fileExist=[fileManager fileExistsAtPath:_destination_path];
    if(!fileExist){
        [fileManager createFileAtPath:_destination_path contents:nil attributes:nil];
    }
    _writeHandle=[NSFileHandle fileHandleForWritingAtPath:_destination_path];
}
/**
 * 下载过程，会多次调用
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_writeHandle seekToEndOfFile];
    long long freeSpace=[self systemFreeSpace];
    if(freeSpace<1024*1024*20) {
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:@"系统可用存储空间不足20M" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirm];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        //发送系统存储空间不足的通知,用户可自行注册该通知，收到通知时，暂停下载，并更新界面
        [[NSNotificationCenter defaultCenter] postNotificationName:FGInsufficientSystemSpaceNotification object:nil userInfo:@{@"urlString":_url_string}];
        return;
    }
    [_writeHandle writeData:data];
    long long length=(long long)[[[[NSFileManager defaultManager] attributesOfItemAtPath:_destination_path error:nil] objectForKey:NSFileSize] integerValue];
    NSString *key=[NSString stringWithFormat:@"%@totalLength",_url_string];
    long long totalLength=(long long)[[NSUserDefaults standardUserDefaults] integerForKey:key];
    //计算下载进度
    float progress=(float)length/totalLength;
    [[NSUserDefaults standardUserDefaults]setFloat:progress forKey:[NSString stringWithFormat:@"%@progress",_url_string]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //获取文件大小，格式为：格式为:已经下载的大小/文件总大小,如：12.00M/100.00M
    NSString *sizeString=[FGDownloader filesSize:_url_string];
    
    //发送进度改变的通知(一般情况下不需要用到，只有在触发下载与显示下载进度在不同界面的时候才会用到)
    NSDictionary *userInfo=@{@"url":_url_string,@"progress":@(progress),@"sizeString":sizeString};
    [[NSNotificationCenter defaultCenter] postNotificationName:FGProgressDidChangeNotificaiton object:nil userInfo:userInfo];
    
    //计算网速
    NSString *speedString=@"0.00Kb/s";
    NSString *growString=[FGTool convertSize:_growth*(1.0/0.1)];
    speedString=[NSString stringWithFormat:@"%@/s",growString];
    
    //回调下载过程中的代码块
    if(_process){
        _process(progress,sizeString,speedString);
    }
}
/**
 * 下载完成
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[NSNotificationCenter defaultCenter] postNotificationName:FGDownloadTaskDidFinishNotification object:nil userInfo:@{@"urlString":_url_string}];
    if(_completion){
        _completion();
    }
}

@end
