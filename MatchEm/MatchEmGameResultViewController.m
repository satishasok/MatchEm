//
//  MatchEmGameResultViewController.m
//  MatchEm
//
//  Created by Satish Asok on 7/29/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "MatchEmGameResultViewController.h"

@interface MatchEmGameResultViewController ()

@property (strong, nonatomic) UILabel *wellDoneLabel;
@property (strong, nonatomic) UILabel *gameTimeLabel;
@property (strong, nonatomic) UILabel *flipCountLabel;

@end

@implementation MatchEmGameResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UILabel *)wellDoneLabel
{
    if (_wellDoneLabel == nil) {
        _wellDoneLabel = [[UILabel alloc] init];
    }
    
    return _wellDoneLabel;
}

- (UILabel *)gameTimeLabel
{
    if (_gameTimeLabel == nil) {
        _gameTimeLabel = [[UILabel alloc] init];
    }
    
    return _gameTimeLabel;
}

- (UILabel *)flipCountLabel
{
    if (_flipCountLabel == nil) {
        _flipCountLabel = [[UILabel alloc] init];
    }
    
    return _flipCountLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Game Result"];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    [self setupSubviews];
    
    [self.view addSubview:self.wellDoneLabel];
    [self.view addSubview:self.gameTimeLabel];
    [self.view addSubview:self.flipCountLabel];
     
     
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupSubviews];
}

- (void)setupSubviews
{
    [self.view setBackgroundColor:[UIColor grayColor]];
    CGRect viewFrameRect = self.view.frame;
    CGFloat viewFrameWidth = CGRectGetWidth(viewFrameRect);
    CGFloat viewFrameHeight = CGRectGetHeight(viewFrameRect) - 60; // offset for the navigation bar.
    
    CGRect wellDoneLabelRect = CGRectMake(viewFrameWidth/2 - 100, viewFrameHeight/2-100, 200, 40);
    CGRect gameTimeLabelRect = CGRectMake(wellDoneLabelRect.origin.x, CGRectGetMaxY(wellDoneLabelRect)+20, 200, 30);
    CGRect flipCountLabelRect = CGRectMake(wellDoneLabelRect.origin.x, CGRectGetMaxY(gameTimeLabelRect)+20, 200, 30);
    
    self.wellDoneLabel.frame = wellDoneLabelRect;
    self.gameTimeLabel.frame = gameTimeLabelRect;
    self.flipCountLabel.frame = flipCountLabelRect;
    
    self.wellDoneLabel.textAlignment = NSTextAlignmentCenter;
    self.gameTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.flipCountLabel.textAlignment = NSTextAlignmentCenter;
    
    self.wellDoneLabel.text = @"Well Done!";
    self.wellDoneLabel.attributedText = [[NSAttributedString alloc] initWithString:self.wellDoneLabel.text attributes:@{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] }];
    
    [self updateUIContents];
    
}

- (void)updateUIContents
{
    self.gameTimeLabel.text = [NSString stringWithFormat:@"Game Time: %ld seconds", (long)self.timeTakenInSeconds];
    self.flipCountLabel.text = [NSString stringWithFormat:@"Flip Count: %ld seconds", (long)self.flipCount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
