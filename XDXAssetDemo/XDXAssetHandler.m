//
//  XDXAssetHandler.m
//  XDXAssetDemo
//
//  Created by 李承阳 on 2019/4/14.
//  Copyright © 2019 小东邪. All rights reserved.
//

#import "XDXAssetHandler.h"

@implementation XDXAssetHandler
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_8744" ofType:@"MOV"];
- (AVURLAsset *)getAssetWithFilePath:(NSString *)path isPreciseDuration:(BOOL)isPreciseDuration {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSLog(@"%s - url: %@", __func__, url);
    
    NSDictionary    *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @(isPreciseDuration) };
    AVURLAsset      *anAsset = [[AVURLAsset alloc] initWithURL:url options:options];
    return anAsset;
}

- (void)getPhotoAlbumAssetWithIndex:(int)index completionHandler:(void (^)(AVAsset *avAsset)) handler {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // Within the group enumeration block, filter to enumerate just videos.
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        // For this example, we're only interested in the first item.
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:index]
                                options:0
                             usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                 
                                 // The end of the enumeration is signaled by asset == nil.
                                 if (alAsset) {
                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                     NSURL *url = [representation url];
                                     AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                                     // Do something interesting with the AV asset.
                                     handler(avAsset);
                                     NSLog(@"demon: %@",avAsset);
                                 }
                             }];
        
        
    } failureBlock:^(NSError *error) {
        NSLog(@"No groups");
    }];
}

- (UIImage *)getStillVideoFromAsset:(AVURLAsset *)urlAsset {
    if ([[urlAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        Float64 durationSeconds = CMTimeGetSeconds([urlAsset duration]);
        CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
        
        NSError *error;
        CMTime actualTime;
        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
        
        if (halfWayImage != NULL) {
            NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
            NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, midpoint));
            NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);
            UIImage *img = [UIImage imageWithCGImage:halfWayImage];
            CGImageRelease(halfWayImage);
            return img;
        }
    }
    
    return NULL;
}

- (void)getASeriesOfPictureFromAsset:(AVURLAsset *)urlAsset {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    
    Float64 durationSeconds     = CMTimeGetSeconds([urlAsset duration]);
    CMTime firstThird           = CMTimeMakeWithSeconds(durationSeconds/3.0, 600);
    CMTime secondThird          = CMTimeMakeWithSeconds(durationSeconds*2.0/3.0, 600);
    CMTime end                  = CMTimeMakeWithSeconds(durationSeconds, 600);
    NSArray *times              = @[[NSValue valueWithCMTime:kCMTimeZero],
                                    [NSValue valueWithCMTime:firstThird], [NSValue valueWithCMTime:secondThird],
                                    [NSValue valueWithCMTime:end]];
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                         completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                             AVAssetImageGeneratorResult result, NSError *error) {
                                             
                                             NSString *requestedTimeString = (NSString *)
                                             CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
                                             NSString *actualTimeString = (NSString *)
                                             CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
                                             NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
                                             
                                             if (result == AVAssetImageGeneratorSucceeded) {
                                                 // Do something interesting with the image.
                                             }
                                             
                                             if (result == AVAssetImageGeneratorFailed) {
                                                 NSLog(@"Failed with error: %@", [error localizedDescription]);
                                             }
                                             if (result == AVAssetImageGeneratorCancelled) {
                                                 NSLog(@"Canceled");
                                             }
                                         }];
}

- (void)editFromAsset:(AVURLAsset *)urlAsset {
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:urlAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:urlAsset presetName:AVAssetExportPresetLowQuality];
        // Implementation continues.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
        NSString *test = [[paths firstObject] stringByAppendingString:@"/test"];
        exportSession.outputURL = [NSURL URLWithString:test];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(1.0, 600);
        CMTime duration = CMTimeMakeWithSeconds(3.0, 600);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    break;
            }
        }];
    }
    
    
    
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end
