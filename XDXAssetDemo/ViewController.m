//
//  ViewController.m
//  XDXAssetDemo
//
//  Created by 李承阳 on 2019/4/2.
//  Copyright © 2019 小东邪. All rights reserved.
//

#import "ViewController.h"
#import "TestPlaybackVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)testPlayerDidClicked:(id)sender {
    TestPlaybackVC *vc = [[TestPlaybackVC alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
