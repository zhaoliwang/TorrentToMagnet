//
//  ViewController.m
//  Torrent2Magnet
//
//  Created by zBosi on 2017/2/9.
//  Copyright © 2017年 LandOfMystery. All rights reserved.
//

#import "ViewController.h"
#import "BTUrl2Magnet.h"

@interface ViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *logView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.logView];

    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor orangeColor]];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(parseTorrent) forControlEvents:UIControlEventTouchUpInside];
    
    [button setFrame:CGRectMake(44, [UIScreen mainScreen].applicationFrame.size.height - 88, [UIScreen mainScreen].applicationFrame.size.width - 88, 44)];
    
    [self.view addSubview:button];
}


- (void)parseTorrent{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    NSString *str = board.string;
    [self addLog:[NSString stringWithFormat:@"\n剪切板上的内容为：%@",str]];
    if (str) {
        [self addLog:@"开始解析剪切板上的url地址..."];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

            NSString *magnet = [BTUrl2Magnet btUrlToMagnet:str];
            if (magnet.length > 0) {
                [self addLog:[NSString stringWithFormat:@"解析结果为：%@",magnet]];
                [board setString:magnet];
                [self addLog:@"已经将解析结果复制到剪切板上，您可以使用其它离线下载应用（比如115网盘）下载了"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:magnet message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            } else {
                [self addLog:@"url解析失败了，您复制的地址可能不是一个种子地址"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"解析失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
        });
    } else {
        [self addLog:@"剪切板上的内容为空，工作无法开始"];
    }
}

- (void)addLog:(NSString *)log{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = self.logView.text;
        NSString *newLog = [NSString stringWithFormat:@"%@\n%@",str,log];
        [self.logView setText:newLog];
        [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length - 1 , 1)];
    });
}

- (UITextView *)logView{
    if (!_logView) {
        _logView = [[UITextView alloc] init];
        [_logView setFrame:CGRectMake(44, 44, [UIScreen mainScreen].applicationFrame.size.width - 88, [UIScreen mainScreen].applicationFrame.size.height - 88 - 44 - 22)];
        [_logView setText:@"准备就绪"];
        [_logView setBackgroundColor:[[UIColor alloc] initWithRed:77/255.0 green:73/255.0 blue:72/255.0 alpha:1]];
        [_logView setTextColor:[[UIColor alloc] initWithRed:36/255.0 green:254/255.0 blue:63/255.0 alpha:1]];
        _logView.delegate = self;
    }
    
    return _logView;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView isFirstResponder]){
        return YES;
    }
    return NO;
}

@end
