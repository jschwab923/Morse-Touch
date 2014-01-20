//
//  NSString+MorseCode.m
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "NSString+MorseCode.h"

@implementation NSString (MorseCode)

+ (NSArray *)arrayOfMorseSymbolsFromString:(NSString *)string
{
    NSMutableArray *arrayOfSymbols = [NSMutableArray new];
    
    for (NSInteger i = 0; i < string.length; i++) {
        NSString *currentCharacter = [string substringWithRange:NSMakeRange(i, 1)];
        currentCharacter = [currentCharacter uppercaseString];
        if (![[NSString dictionaryOfMorseSymbols] objectForKey:currentCharacter]) {
            UIAlertView *invalidStringAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Characters"
                                                                         message:@"Message contains invalid characters. Only A-Z and 0-9 allowed"
                                                                        delegate:nil
                                                               cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [invalidStringAlert show];
            return nil;
        }
        NSString *morseSymbol = [NSString morseSymbolFromCharacter:currentCharacter];
        [arrayOfSymbols addObject:morseSymbol];
    }
    return arrayOfSymbols;
}

+ (NSString *)morseSymbolFromCharacter:(NSString *)character
{
    NSString *morseSymbol;
    
    NSDictionary *morseDictionary = [NSString dictionaryOfMorseSymbols];
    character = [character uppercaseString];
    
    if ([morseDictionary objectForKey:character]) {
        morseSymbol = [morseDictionary objectForKey:character];
    } else {
        
    }
    return morseSymbol;
}

+ (NSDictionary *)dictionaryOfMorseSymbols
{
    NSDictionary *morseDictionary = @{@"A":@".-",
                                      @"B":@"-...",
                                      @"C":@"-.-.",
                                      @"D":@"-..",
                                      @"E":@".",
                                      @"F":@"..-.",
                                      @"G":@"--.",
                                      @"H":@"....",
                                      @"I":@"..",
                                      @"J":@".---",
                                      @"K":@"-.-",
                                      @"L":@".-..",
                                      @"M":@"--",
                                      @"N":@"-.",
                                      @"O":@"---",
                                      @"P":@".--.",
                                      @"Q":@"--.-",
                                      @"R":@".-.",
                                      @"S":@"...",
                                      @"T":@"-",
                                      @"U":@"..-",
                                      @"V":@"...-",
                                      @"W":@".--",
                                      @"X":@"-..-",
                                      @"Y":@"-.--",
                                      @"Z":@"--..",
                                      @"0":@"-----",
                                      @"1":@".----",
                                      @"2":@"..---",
                                      @"3":@"...--",
                                      @"4":@"....-",
                                      @"5":@".....",
                                      @"6":@"-....",
                                      @"7":@"--...",
                                      @"8":@"---..",
                                      @"9":@"----."};
    
    return morseDictionary;
}


@end
