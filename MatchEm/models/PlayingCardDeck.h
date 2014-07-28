//
//  PlayingCardDeck.h
//  CardGame
//
//  Created by Satish Asok on 7/12/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

@class PlayingCard;

@interface PlayingCardDeck : NSObject

- (void)addCard:(PlayingCard *)card;
- (void)addCard:(PlayingCard *)card onTop:(BOOL)onTop;

- (PlayingCard *)drawRandomCard;
- (PlayingCard *)drawCardWithMatchingRank:(NSUInteger)rank;

@end
