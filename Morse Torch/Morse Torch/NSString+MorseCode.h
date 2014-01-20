//
//  NSString+MorseCode.h
//  Morse Torch
//
//  Created by Jeff Schwab on 1/20/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MorseCode)

+ (NSString *)morseSymbolFromCharacter:(NSString *)character;
+ (NSArray *)arrayOfMorseSymbolsFromString:(NSString *)string;
+ (NSDictionary *)dictionaryOfMorseSymbols;

@end
