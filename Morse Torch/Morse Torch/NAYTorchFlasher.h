//
//  NAYTorchFlasher.h
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NAYViewController.h"

@protocol NAYTorchFlasherDelegate <NSObject>

@required
- (void)flashingSymbol:(NSString *)symbol;
- (void)flashingLastSymbol;

@end


@interface NAYTorchFlasher : NSObject

@property (nonatomic, assign) id <NAYTorchFlasherDelegate> delegate;

- (void)flashMorseSymbol:(NSString *)symbol withViewController:(NAYViewController *)viewController;

@end
