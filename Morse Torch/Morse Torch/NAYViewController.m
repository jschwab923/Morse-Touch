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
#import "CFMagicEvents.h"

@import AVFoundation;

@interface NAYViewController () <NAYTorchFlasherDelegate>
{
    NSOperationQueue *_backGroundQueue;
    CGFloat _sendProgress;
    CGFloat _totalMessageLength;
    
    NSInteger flashOnCount;
    NSInteger flashOffCount;
}

@property (weak, nonatomic) IBOutlet UIButton *translateButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *receiveMessageButton;
@property (nonatomic) M13ProgressViewBar *progressBar;

@property (nonatomic) NAYTorchFlasher *flasher;
@property (nonatomic) CFMagicEvents *flashreceiver;

@property (nonatomic) NSString *currentWord;
@property (nonatomic) NSDictionary *morseDictionary;

@end

@implementation NAYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageTextField.delegate = self;
    
    self.currentWord = [NSString new];
    self.morseDictionary = [NSString dictionaryOfMorseSymbols];
    
    [self disableButton:self.translateButton];
    
    _backGroundQueue = [[NSOperationQueue alloc] init];
    [_backGroundQueue setMaxConcurrentOperationCount:1];
    
    // Set up objects for sending and recieving
    self.flasher = [[NAYTorchFlasher alloc] init];
    self.flasher.delegate = self;
    
    // Set up progress bar
    self.progressBar = [[M13ProgressViewBar alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    self.progressBar.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame)-50);
    [self.progressBar setHidden:YES];
    [self.progressBar setProgressBarThickness:6];
    [self.progressBar setPercentagePosition:M13ProgressViewBarPercentagePositionBottom];
    [self.view addSubview:self.progressBar];
    
    
    // Set up observer for activating and deactiviating button with text field
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    // Set up flash receiver notification obserevers and counters
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flashEventReceived:) name:@"onMagicEventDetected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flashEventNotReceived:) name:@"onMagicEventNotDetected" object:nil];
    flashOffCount = 0;
    flashOnCount = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction Methods
- (IBAction)receiveButtonPushed:(id)sender
{
    // receive message only if not already recieving
    if ([[self.receiveMessageButton titleLabel].text isEqualToString:@"Receive Message"]) {
        // Only receive message if text field is empty
        if ([self.messageTextField.text isEqualToString:@""]) {
            [self disableButton:self.translateButton];
            
            [self.receiveMessageButton.titleLabel setText:@"Cancel Receive"];
            
            self.flashreceiver = [[CFMagicEvents alloc] init];
            [self.flashreceiver startCapture];
        }
    } else { //Cancel message
        [self.receiveMessageButton.titleLabel setText:@"Receive Message"];
    }
}

- (IBAction)translateButtonPressed:(id)sender
{
    [_backGroundQueue cancelAllOperations];
    
    // Only send a message if the text field is not empty
    if (![self.messageTextField.text isEqualToString:@""]) {
        [self disableButton:self.receiveMessageButton];
        
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
        [self disableButton:self.translateButton];
        [self enableButton:self.receiveMessageButton];
        
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
    [self disableButton:self.translateButton];
    [self enableButton:self.receiveMessageButton];
    
    [self.progressBar setProgress:0 animated:YES];
    [self.progressBar setHidden:YES];
    
    self.letterLabel.text = @"";
    self.symbolLabel.text = @"";
    _sendProgress = 0;
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
        [self enableButton:self.translateButton];
    } else {
        [self disableButton:self.translateButton];
        [self disableButton:self.receiveMessageButton];
    }
}

- (void)flashEventReceived:(id)sender
{
    flashOffCount = 0;
    flashOnCount++;
}

- (void)flashEventNotReceived:(id)sender
{
    if (flashOnCount >= 2) {
        self.currentWord = [self.currentWord stringByAppendingString:@"-"];
    } else if (flashOnCount > 0) {
        self.currentWord = [self.currentWord stringByAppendingString:@"."];
    }
    
    if (flashOffCount >= 5) {
        [self.flashreceiver stopCapture];
    } else if (flashOffCount >= 2) {
        NSString *receivedLetter = [[self.morseDictionary allKeysForObject:self.currentWord] firstObject];;
        self.messageTextField.text = [self.messageTextField.text stringByAppendingString:
                                      [NSString stringWithFormat:@" %@", receivedLetter]];
        self.currentWord = @"";
    }
    
    flashOnCount = 0;
    flashOffCount++;
}

- (void)enableButton:(UIButton *)button
{
    [button setAlpha:1];
    [button setEnabled:YES];
}

- (void)disableButton:(UIButton *)button
{
    [button setAlpha:.5];
    [button setEnabled:NO];
}
@end
