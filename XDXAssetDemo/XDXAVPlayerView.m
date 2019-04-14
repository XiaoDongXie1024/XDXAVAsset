//
//  XDXAVPlayerView.m
//  XDXAssetDemo
//
//  Created by 李承阳 on 2019/4/5.
//  Copyright © 2019 小东邪. All rights reserved.
//

#import "XDXAVPlayerView.h"

@interface XDXAVPlayerView ()

@end

@implementation XDXAVPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
