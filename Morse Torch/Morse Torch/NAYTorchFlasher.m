//
//  NAYTorchFlasher.m
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "NAYTorchFlasher.h"
#import "NAYViewController.h"
#import "NSString+MorseCode.h"

@import AVFoundation;

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

- (void)flashMorseSymbol:(NSString *)symbol withViewController:(NAYViewController *)viewController
{
    if (self.cameraDevice) {
        [self.cameraDevice lockForConfiguration:nil];
        
        // Update main ui
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSDictionary *morseSymbolsDictionary = [NSString dictionaryOfMorseSymbols];
            NSString *currentLetter = [[morseSymbolsDictionary allKeysForObject:symbol] firstObject];
            [viewController.translationLabel setText:currentLetter];
            [viewController.symbolLabel setText:symbol];
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
    }
    
}

@end
