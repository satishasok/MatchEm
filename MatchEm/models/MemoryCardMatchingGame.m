//
//  CardGame2CardMatchingGame.m
//  CardGame
//
//  Created by Satish Asok on 7/14/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "MemoryCardMatchingGame.h"
#import "PlayingCard.h"
#import "PlayingCardDeck.h"
#import "NSMutableArray+Additions.h"

@interface MemoryCardMatchingGame ()

@property (nonatomic, readwrite) NSInteger flipCount;

@property (nonatomic, strong) NSMutableArray *cards; // array of Card

@end


@implementation MemoryCardMatchingGame

- (id)initWithCards:(NSInteger)cardCount usingDeck:(PlayingCardDeck *)cardDeck
{
    self = [super init];
    
    if (self) {
        _flipCount = 0;
        _gameStartTime = [NSDate date];
        
        for (int i = 0; i < cardCount/2; i++) {
            PlayingCard *card = [cardDeck drawRandomCard];
            
            if (card) {
                PlayingCard *cardPair = [cardDeck drawCardWithMatchingRank:card.rank];
                if (cardPair) {
                    [self.cards addObject:card];
                    [self.cards addObject:cardPair];
                } else {
                    self = nil;
                    break;
                }
                
            } else {
                self = nil;
                break;
            }
        }
        
        [self.cards shuffle];
    }
    
    return self;
}

- (NSMutableArray *)cards
{
    if (!_cards) {
        _cards = [[NSMutableArray alloc] init];
    }
    
    return _cards;
}

- (PlayingCard *)cardAtIndex:(NSInteger)index
{
    return ((index >= 0 && index < self.cards.count) ? self.cards[index] : nil);
}

- (NSInteger)numberOfChoosenUnMatchedCards
{
    NSInteger numberOfChoosenCards = 0;
    
    for (PlayingCard *card in self.cards) {
        if (card.isChosen && !card.isMatched) {
            numberOfChoosenCards++;
        }
    }
    
    return numberOfChoosenCards;
}

- (NSInteger)numberOfUnMatchedCards
{
    NSInteger numberOfUnMatchedCards = 0;
    
    for (PlayingCard *card in self.cards) {
        if (!card.isMatched) {
            numberOfUnMatchedCards++;
        }
    }
    
    return numberOfUnMatchedCards;
}

- (BOOL)selectCardAtIndex:(NSInteger)index
{
    PlayingCard *card = [self cardAtIndex:index];
    
    if (!card.isChosen) {
        card.chosen = YES;
        return YES;
    }
    
    return NO;
}

- (BOOL)deSelectCardAtIndex:(NSInteger)index
{
    PlayingCard *card = [self cardAtIndex:index];
    
    if (card.isChosen) {
        card.chosen = NO;
        return YES;
    }
    return NO;
}

- (BOOL)chooseCardAtIndex:(NSInteger)index
{
    BOOL cardsMatched = NO;
    PlayingCard *card = [self cardAtIndex:index];
    
    if (card && !card.isMatched) {
        if (!card.isChosen) {
            
            // match with other card
            for (PlayingCard *otherCard in self.cards) {
                if (otherCard.isChosen && !otherCard.isMatched) {
                    self.flipCount++;
                    
                    PlayingCardMatchType matchType = [card matchWithCards:@[otherCard]];
                    
                    if (matchType == PlayingCardMatchTypeRankMatch) {
                        otherCard.matched = YES;
                        card.matched = YES;
                        card.chosen = YES;
                        cardsMatched = YES;
                    } else {
                        otherCard.chosen = NO;
                        card.chosen = NO;
                    }
                    if ([self numberOfUnMatchedCards] == 0) {
                        self.gameOver = YES;
                    }
                    return cardsMatched;
                }
            }
            card.chosen = YES;
        }
    }
    
    if ([self numberOfUnMatchedCards] == 0) {
        self.gameOver = YES;
    }
    return cardsMatched;
}

@end
