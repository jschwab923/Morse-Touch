//
//  NAYViewController.m
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "NAYViewController.h"
#import "NSString+MorseCode.h"

@interface NAYViewController ()

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *translationTextView;

@end

@implementation NAYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageTextField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)translateButtonPressed:(id)sender
{
    NSString *messageToTranslate = self.messageTextField.text;
    NSArray *morseSymbols;
    if (messageToTranslate) {
        morseSymbols = [NSString arrayOfMorseSymbolsFromString:messageToTranslate];
    }
    if (morseSymbols) {
        self.translationTextView.text = morseSymbols.description;
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
