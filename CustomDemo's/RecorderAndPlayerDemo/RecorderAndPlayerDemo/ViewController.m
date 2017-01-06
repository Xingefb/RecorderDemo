//
//  ViewController.m
//  RecorderAndPlayerDemo
//
//  Created by Dzy on 05/01/2017.
//  Copyright © 2017 Dzy. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AFNetworking.h>
#import "PermissionsTools.h"

@interface ViewController ()<AVAudioRecorderDelegate>
{
    double startPointX;
    double startPointY;
}
@property (nonatomic ) AVAudioSession *session;
@property (nonatomic ) AVAudioRecorder *recorder;
@property (nonatomic ) AVAudioPlayer *player;

@property (nonatomic ) NSTimer *timer;
@property (nonatomic ) NSURL *pathUrl;

@property (weak, nonatomic) IBOutlet UIView *theView;
@property (weak, nonatomic) IBOutlet UILabel *theTitle;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImage;

@end

@implementation ViewController



#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {

    if (flag) {
        [_session setActive:NO error:nil];
    }
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {

}

- (NSDictionary *)recorderSetting {
    
    NSMutableDictionary *recorderSettings = [NSMutableDictionary dictionaryWithCapacity:10];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM  .caf
    [recorderSettings setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量） 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [recorderSettings setValue:@44100 forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recorderSettings setValue:@2 forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recorderSettings setValue:@16 forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recorderSettings setValue:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    
    return recorderSettings;
}

- (void)changeVoice {

    [_recorder updateMeters];
    //0 表示最大分贝 -160 最小
    double lowPassResults = pow(10, (0.5 * [_recorder peakPowerForChannel:0]));
    NSLog(@"start %f   %f",lowPassResults,[_recorder peakPowerForChannel:0]);

    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue=[NSNumber numberWithFloat:1];
    double max = 1.0+lowPassResults;
    if (max >= 1.5) {
        max = 1.5;
    }
    animation.toValue=[NSNumber numberWithFloat:max];
    animation.duration=0.15;
    animation.autoreverses=YES;
    animation.repeatCount=1;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    [self.voiceImage.layer addAnimation:animation forKey:nil];
    
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {

    CGPoint point = [longPress locationInView:self.view];
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            _theTitle.text = @"up cancel";
            NSLog(@"start");
            startPointX = point.x;
            startPointY = point.y;
            if ([PermissionsTools isAudioAllow]) {
                if (![_recorder isRecording]) {
                    
                    [_recorder prepareToRecord];
                    [_recorder peakPowerForChannel:0.0];
                    [_recorder record];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeVoice) userInfo:nil repeats:YES];
                    [self.timer fire];
                    
                }
            }

        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (point.y <= startPointY - 60) {
                if ([_recorder isRecording]) {
                    [_recorder pause];
                    _theTitle.text = @"release";

                }
            }
            if (startPointY - 60 < point.y) {
                
                if (![_recorder isRecording]) {
                    [_recorder record];
                    _theTitle.text = @"up cancel";
                }
            }
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            _theTitle.text = @"start";

            if ([_recorder isRecording]) {
                [_recorder stop];
                NSLog(@"end");
            }else {
                [_recorder deleteRecording];
                [_recorder stop];
                NSLog(@"cancel");
            }
            
            [self.timer invalidate];//取消定时器

        }
            break;
        default:
            
            break;
    }

}

- (IBAction)clickListen:(UIButton *)sender {
    
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:self.pathUrl error:nil];
    //设置声音的大小
    self.player.volume = 0.7;//范围为（0到1）；
    //设置循环次数，如果为负数，就是无限循环 -1
    self.player.numberOfLoops = 0 ;
    //设置播放进度
    self.player.currentTime = 0;
    [self.player prepareToPlay];
    [self.player play];
    
}

- (IBAction)clickUpload:(UIButton *)sender {

    /*
      url      :  本地文件路径
     * name     :  与服务端约定的参数
     * fileName :  自己随便命名的
     * mimeType :  文件格式类型 [mp3 : application/octer-stream application/octet-stream] [mp4 : video/mp4]
     */
    
    [[AFHTTPSessionManager manager] POST:@"" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        BOOL isDate = [formData appendPartWithFileURL:self.pathUrl name:@"serverSetName" fileName:@"sound.mp3" mimeType:@"application/octet-stream" error:nil];
        if (isDate) {
            NSLog(@"file data was successfully appended");
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success - %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.player isPlaying]) {
        [self.player stop];
    }
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
        [self.recorder deleteRecording];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    self.player = nil;
    self.player.delegate = nil;
    self.recorder = nil;
    self.recorder.delegate = nil;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _session = [AVAudioSession sharedInstance];
    
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(!_session)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [_session setActive:YES error:nil];
    
//    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docsDir = [dirPaths objectAtIndex:0];
//    NSString *soundFilePath = [docsDir
//                               stringByAppendingPathComponent:@"recordTest.caf"];
    NSString *fileName = [NSString stringWithFormat:@"%dsound.caf",(int)[NSDate date].timeIntervalSince1970];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.pathUrl = url;
    
    NSLog(@" - %@",url);
    NSDictionary *settings = [self recorderSetting];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:nil];
    //开启音量检测
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.theView addGestureRecognizer:longPress];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
