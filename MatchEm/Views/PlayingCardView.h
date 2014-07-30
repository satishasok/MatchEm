//
//  PlayingCardView.h
//  SuperCard
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingCard.h"

@interface PlayingCardView : UIView

@property (strong, nonatomic) PlayingCard *playingCard;
@property (nonatomic) BOOL faceUp;

@end
