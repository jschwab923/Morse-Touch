//
//  NAYTorchFlasher.h
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NAYViewController.h"

@interface NAYTorchFlasher : NSObject

- (void)flashMorseSymbol:(NSString *)symbol withViewController:(NAYViewController *)viewController;

@end
