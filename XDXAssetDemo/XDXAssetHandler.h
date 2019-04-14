//
//  XDXAssetHandler.h
//  XDXAssetDemo
//
//  Created by 李承阳 on 2019/4/14.
//  Copyright © 2019 小东邪. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDXAssetHandler : NSObject

- (AVURLAsset *)getAssetWithFilePath:(NSString *)path
                   isPreciseDuration:(BOOL)isPreciseDuration;

- (void)getPhotoAlbumAssetWithIndex:(int)index
                  completionHandler:(void (^)(AVAsset *avAsset)) handler;

- (UIImage *)getStillVideoFromAsset:(AVURLAsset *)urlAsset;
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end

NS_ASSUME_NONNULL_END
