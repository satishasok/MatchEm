//
//  PlayingCard.h
//  CardGame
//
//  Created by Satish Asok on 7/12/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

typedef enum {
    PlayingCardMatchTypeNoMatch = 0,
    PlayingCardMatchTypeRankMatch = 1,
    PlayingCardMatchTypeSuitMatch = 2
} PlayingCardMatchType;

@interface PlayingCard : NSObject

@property (nonatomic, strong) NSString *contents;

@property (nonatomic, assign, getter=isChosen) BOOL chosen;
@property (nonatomic, assign, getter=isMatched) BOOL matched;

@property (nonatomic, strong) NSString *suit;
@property (nonatomic, assign) NSUInteger rank;

- (id)initWithRank:(NSUInteger)rank suit:(NSString *)suit;

- (PlayingCardMatchType)matchWithCards:(NSArray *)otherCards;

- (NSString *)rankString;

+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;

@end
