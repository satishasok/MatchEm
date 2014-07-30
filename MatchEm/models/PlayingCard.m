//
//  PlayingCard.m
//  CardGame
//
//  Created by Satish Asok on 7/12/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard


+ (NSArray *)rankStrings
{
        return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",
                 @"J", @"Q", @"K"];
}

+ (NSArray *)validSuits
{
    return @[@"♣", @"♥", @"♠", @"♦"];
}

+ (NSUInteger)maxRank;
{
    return [self rankStrings].count-1;
}

- (id)initWithRank:(NSUInteger)rank suit:(NSString *)suit
{
    self = [super init];
    
    if (self) {
        self.rank = rank;
        self.suit = suit;
    }
    
    return self;
}

- (NSString *)contents
{
    return [NSString stringWithFormat:@"%@%@", [self rankString], self.suit];
}

@synthesize suit=_suit;
- (void)setSuit:(NSString *)suit
{
    if ([[[self class] validSuits] containsObject:suit]) {
        _suit = suit;
    }
}

- (NSString *)suit
{
    return _suit ? _suit : @"?";
}

- (void)setRank:(NSUInteger)rank
{
    if (rank < [[self class] rankStrings].count) {
        _rank = rank;
    }
}

- (NSString *)rankString
{
    return ([[self class] rankStrings][self.rank]);
}

- (PlayingCardMatchType)matchWithCards:(NSArray *)otherCards
{
    PlayingCardMatchType matchType = PlayingCardMatchTypeNoMatch;
    for (id item in otherCards)
    {
        if ([item isKindOfClass:[PlayingCard class]])
        {
            PlayingCard *otherCard = (PlayingCard *)item;
            if (self.rank == otherCard.rank) {
                matchType = PlayingCardMatchTypeRankMatch;
            } else if( [self.suit isEqualToString:otherCard.suit]) {
                matchType = PlayingCardMatchTypeSuitMatch;
            }
        }
    }
    
    return matchType;
}

@end
