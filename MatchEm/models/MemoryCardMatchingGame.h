//
//  MemoryCardMatchingGame.h
//  CardGame
//
//  Created by Satish Asok on 7/14/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PlayingCardDeck;
@class PlayingCard;

@interface MemoryCardMatchingGame : NSObject

- (id)initWithCards:(NSInteger)cardCount usingDeck:(PlayingCardDeck *)cardDeck;

- (NSInteger)numberOfChoosenCardsUnMatchedCards;
- (NSInteger)numberOfUnMatchedCards;

- (BOOL)selectCardAtIndex:(NSInteger)index;
- (BOOL)deSelectCardAtIndex:(NSInteger)index;

- (PlayingCard *)cardAtIndex:(NSInteger)index;
- (BOOL)chooseCardAtIndex:(NSInteger)index;

@property (nonatomic, readonly) NSInteger flipCount;
@property (nonatomic, strong) NSDate *gameStartTime;

@end
