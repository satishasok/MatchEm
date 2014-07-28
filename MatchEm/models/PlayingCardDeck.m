//
//  PlayingCardDeck.m
//  CardGame
//
//  Created by Satish Asok on 7/12/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@interface PlayingCardDeck ()

@property (nonatomic, strong)  NSMutableArray *cards;

@end

@implementation PlayingCardDeck

- (id)init
{
    self = [super init];
    
    if (self) {
        for (NSString *suit in [PlayingCard validSuits]) {
            for (NSUInteger rank=1; rank < [PlayingCard maxRank]; rank++) {
                PlayingCard *playingCard = [[PlayingCard alloc] initWithRank:rank suit:suit];
                [self addCard:playingCard onTop:YES];
            }
        }
    }
    
    return self;
}

@synthesize cards=_cards;
- (NSMutableArray *)cards
{
    if (_cards == nil) {
        _cards = [[NSMutableArray alloc] init];
    }
    
    return _cards;
}

- (void)addCard:(PlayingCard *)card
{
    [self addCard:card onTop:NO];
}

- (void)addCard:(PlayingCard *)card onTop:(BOOL)onTop
{
    if (onTop) {
        [self.cards insertObject:card atIndex:0];
    } else {
        [self.cards addObject:card];
    }
}

- (PlayingCard *)drawRandomCard
{
    PlayingCard *randomCard = nil;
    if (self.cards.count == 0 ) {
        return randomCard;
    }
    
    NSUInteger randomIndex = arc4random()%self.cards.count;
    
    randomCard = self.cards[randomIndex];
    [self.cards removeObjectAtIndex:randomIndex];
    
    return randomCard;
}

- (PlayingCard *)drawCardWithMatchingRank:(NSUInteger)rank
{
    PlayingCard *cardWithMatchingRank = nil;
    
    if (rank > [PlayingCard maxRank]) {
        return cardWithMatchingRank;
    }
    
    for (PlayingCard *card in self.cards) {
        if (card.rank == rank) {
            cardWithMatchingRank = card;
            break;
        }
    }
    
    [self.cards removeObject:cardWithMatchingRank];
    
    return cardWithMatchingRank;
}


@end
