//
//  NAYTorchFlasher.m
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

@import AVFoundation;
#import "NAYTorchFlasher.h"
#import "NAYViewController.h"
#import "NSString+MorseCode.h"

@interface NAYTorchFlasher ()

@property (nonatomic) AVCaptureDevice *cameraDevice;

@end

@implementation NAYTorchFlasher

- (instancetype)init
{
    if (self = [super init]) {
        self.cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return self;
}

- (void)flashMorseSymbol:(NSString *)symbol 
{
    if (self.cameraDevice) {
        [self.cameraDevice lockForConfiguration:nil];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate flashingSymbol:symbol];
        }];
        
        
        for (int i = 0; i < symbol.length; i++) {
            [self.cameraDevice setTorchMode:AVCaptureTorchModeOn];
            if ([[symbol substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"."]) {
                usleep(DELAY_DOT);
            } else {
                usleep(DELAY_DASH);
            }
            [self.cameraDevice setTorchMode:AVCaptureTorchModeOff];
            usleep(DELAY_SYMBOL);
            if ([[[[NSOperationQueue currentQueue] operations] lastObject] isCancelled]) {
                return;
            }
        }
        [self.cameraDevice unlockForConfiguration];
        usleep(DELAY_WORD);
        
        if ([[[NSOperationQueue currentQueue] operations] count] <= 1) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.delegate flashingLastSymbol];
            }];
        }
    }
}

@end
