//
//  TestPlaybackVC.m
//  XDXAssetDemo
//
//  Created by 李承阳 on 2019/4/5.
//  Copyright © 2019 小东邪. All rights reserved.
//

#import "TestPlaybackVC.h"
#import <AVFoundation/AVFoundation.h>
#import "XDXAVPlayerView.h"
#import "XDXAssetHandler.h"

static const NSString *ItemStatusContext;

@interface TestPlaybackVC ()

@property (nonatomic, strong) AVPlayer          *player;
@property (nonatomic, strong) AVPlayerItem      *playerItem;
@property (nonatomic, strong) XDXAssetHandler   *assetHandler;
@property (nonatomic, strong) AVURLAsset        *avAsset;

@property (nonatomic, strong) XDXAVPlayerView   *playerView;
@property (nonatomic, strong) UIButton          *playButton;
@property (nonatomic, strong) UIButton          *screenShotBtn;
@property (nonatomic, strong) UIImageView       *screenShotIV;

@end

@implementation TestPlaybackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.playerView = [[XDXAVPlayerView alloc] init];
    self.playerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 200);
    [self.view addSubview:self.playerView];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    self.playButton.backgroundColor = [UIColor blackColor];
    self.playButton.frame = CGRectMake(0, self.view.frame.size.height - 50, 50, 50);
    [self.playButton addTarget:self action:@selector(testBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    self.screenShotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.screenShotBtn setTitle:@"Shot" forState:UIControlStateNormal];
    self.screenShotBtn.backgroundColor = [UIColor blackColor];
    self.screenShotBtn.frame = CGRectMake(70, self.view.frame.size.height - 50, 100, 50);
    [self.screenShotBtn addTarget:self action:@selector(screenShotBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.screenShotBtn];
    
    self.screenShotIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 100, 100, 100)];
    [self.view addSubview:self.screenShotIV];
    
    
}

- (void)loadAssetFromFile {
    NSString        *path       = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"MOV"];
    XDXAssetHandler *handler    = [[XDXAssetHandler alloc] init];
    AVURLAsset      *anAsset    = [handler getAssetWithFilePath:path isPreciseDuration:NO];
    self.assetHandler           = handler;
    self.avAsset                = anAsset;
    
    [anAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
                           NSError *error;
                           AVKeyValueStatus status = [anAsset statusOfValueForKey:@"tracks" error:&error];
                           
                           if (status == AVKeyValueStatusLoaded) {
                               self.playerItem = [AVPlayerItem playerItemWithAsset:anAsset];

                               // ensure that this is done before the playerItem is associated with the player
                               [self.playerItem addObserver:self forKeyPath:@"status"
                                                    options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                               
                               
                               [[NSNotificationCenter defaultCenter] addObserver:self
                                                                        selector:@selector(playerItemDidReachEnd:)
                                                                            name:AVPlayerItemDidPlayToEndTimeNotification
                                                                          object:self.playerItem];
                               
                               
                               self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                               [self.playerView setPlayer:self.player];
                           } else {
                               // You should deal with the error appropriately.
                               NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                           }
                       });
    }];
}
                        
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
}
     
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayer *thePlayer = (AVPlayer *)object;
    NSLog(@"%s -  status:%ld",__func__, (long)[thePlayer status]);
    
    if (context == &ItemStatusContext) {
        NSLog(@"ready play");
        if ([thePlayer status] == AVPlayerStatusFailed) {
            NSError *error = [self.player error];
            NSLog(@"play error: %@",error.localizedDescription);
            // Respond to error: for example, display an alert sheet.
            return;
        }
        [self.player play];
        // Deal with other status change if appropriate.
        //                                          }
        // Deal with other change notifications if appropriate.
        //                                          [super observeValueForKeyPath:keyPath ofObject:object
        //                                                                 change:change context:context];
        return;
    }else {
        NSLog(@"not instance, %p, %p",context,&ItemStatusContext);
    }
    
}

- (void)testBtn {
    [self loadAssetFromFile];
}

- (void)screenShotBtnDidClicked {
    self.screenShotIV.image = [self.assetHandler getStillVideoFromAsset:self.avAsset];
}

@end
