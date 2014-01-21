//
//  NAYViewController.m
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "NAYViewController.h"
#import "NSString+MorseCode.h"
#import "NAYTorchFlasher.h"

@import AVFoundation;

@interface NAYViewController ()
{
    NSOperationQueue *_backGroundQueue;
}
@end

@interface NAYViewController ()

@property (weak, nonatomic) IBOutlet UIButton *translateButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@property (nonatomic) NAYTorchFlasher *flasher;

@end

@implementation NAYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageTextField.delegate = self;
    
    [self.translateButton setEnabled:NO];
    [self.translateButton setAlpha:.5];
    [self.translateButton.titleLabel sizeToFit];
    
    _backGroundQueue = [[NSOperationQueue alloc] init];
    [_backGroundQueue setMaxConcurrentOperationCount:1];
    self.flasher = [[NAYTorchFlasher alloc] init];
    
    // Set up observer for activating and deactiviating button with text field
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


- (IBAction)translateButtonPressed:(id)sender
{
    [_backGroundQueue cancelAllOperations];
    
    if (![self.messageTextField.text isEqualToString:@""]) {
        NSString *messageToTranslate = self.messageTextField.text;
        
        NSArray *morseSymbols;
        if (messageToTranslate) {
            morseSymbols = [NSString arrayOfMorseSymbolsFromString:messageToTranslate];
        }
        
        self.messageTextField.text = @"";
        [self.messageTextField endEditing:YES];
        
        [self.translateButton setTitle:@"Cancel Message" forState:UIControlStateNormal];

        [self startFlashesWithSymbols:morseSymbols];
    } else {
        [self.translateButton setTitle:@"Send Message" forState:UIControlStateNormal];
        [self.translateButton setAlpha:.5];
        [self.translateButton setEnabled:NO];
        self.translationLabel.text = @"";
    }
}

- (void)startFlashesWithSymbols:(NSArray *)symbols
{
    __block NAYViewController *weakSelf = self;
    for (NSString *currentString in symbols) {
        [_backGroundQueue addOperationWithBlock:^{
            [weakSelf.flasher flashMorseSymbol:currentString withViewController:weakSelf];
        }];
    }
}
#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Notification Center Methods

- (void)textFieldChanged:(NSNotification *)note
{
    if (![self.messageTextField.text isEqualToString:@""]) {
        [self.translateButton setAlpha:1.0];
        [self.translateButton setEnabled:YES];
    } else {
        [self.translateButton setAlpha:.6];
        [self.translateButton setEnabled:NO];
    }
}

@end
