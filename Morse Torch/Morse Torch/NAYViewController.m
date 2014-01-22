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
#import <M13ProgressSuite/M13ProgressViewBar.h>


@import AVFoundation;

@interface NAYViewController () <NAYTorchFlasherDelegate>
{
    NSOperationQueue *_backGroundQueue;
    CGFloat _sendProgress;
    CGFloat _totalMessageLength;
}
@end

@interface NAYViewController ()

@property (nonatomic) M13ProgressViewBar *progressBar;

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
    self.flasher.delegate = self;

// TODO: TESTING PROGRESS BAR
    self.progressBar = [[M13ProgressViewBar alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    self.progressBar.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame)-50);
    [self.progressBar setHidden:YES];
    [self.progressBar setProgressBarThickness:6];
    [self.progressBar setPercentagePosition:M13ProgressViewBarPercentagePositionBottom];
    [self.view addSubview:self.progressBar];
    
    
    // Set up observer for activating and deactiviating button with text field
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            _totalMessageLength = [morseSymbols count];
        }
        if (morseSymbols) {
            self.messageTextField.text = @"";
            [self.messageTextField endEditing:YES];
            
            [self.translateButton setTitle:@"Cancel Message" forState:UIControlStateNormal];
            
            [self startFlashesWithSymbols:morseSymbols];
        }
    } else {
        [self.translateButton setTitle:@"Send Message" forState:UIControlStateNormal];
        [self.translateButton setAlpha:.5];
        [self.translateButton setEnabled:NO];
        self.letterLabel.text = @"";
        self.symbolLabel.text = @"";
        [self.progressBar setProgress:0 animated:YES];
        [self.progressBar setHidden:YES];
        _sendProgress = 0;
    }
}

- (void)startFlashesWithSymbols:(NSArray *)symbols
{
    // Display progress HUD to show how much time left for message sending.
    [self.progressBar setHidden:NO];
    
    __block NAYViewController *weakSelf = self;
    for (NSString *currentString in symbols) {
        [_backGroundQueue addOperationWithBlock:^{
            [weakSelf.flasher flashMorseSymbol:currentString];
        }];
    }
}

#pragma mark NAYTorchFlasherDelegate Methods
- (void)flashingSymbol:(NSString *)symbol
{
    _sendProgress += 1;
    [self.progressBar setProgress:_sendProgress/_totalMessageLength animated:YES];
    NSDictionary *morseSymbolsDictionary = [NSString dictionaryOfMorseSymbols];
    NSString *currentLetter = [[morseSymbolsDictionary allKeysForObject:symbol] firstObject];
    [self.letterLabel setText:currentLetter];
    [self.symbolLabel setText:symbol];
}

- (void)flashingLastSymbol
{
    [self.translateButton setTitle:@"Send Message" forState:UIControlStateNormal];
    [self.translateButton setEnabled:NO];
    self.letterLabel.text = @"";
    self.symbolLabel.text = @"";
    _sendProgress = 0;
    [self.progressBar setProgress:0 animated:YES];
    [self.progressBar setHidden:YES];
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
