//
//  MatchEmViewController.m
//  MatchEm
//
//  Created by Satish Asok on 7/20/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "MatchEmViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "MemoryCardMatchingGame.h"
#import "MatchEmGameResultViewController.h"

@interface MatchEmViewController ()

@property (weak, nonatomic) IBOutlet UILabel *flipCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameTimeLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;

@property (strong, nonatomic) ADBannerView *adBannerView;

@property (strong, nonatomic) PlayingCardDeck *playingCardDeck;
@property (strong, nonatomic) MemoryCardMatchingGame *matchingGame;

@property (strong, nonatomic) NSTimer *timerForGameDuration;
@property (assign, nonatomic) BOOL gameOver;

@property (strong, nonatomic) ADInterstitialAd *interstitialAd;
@property (assign, nonatomic) BOOL currentlyRequestingAd;
@property (strong, nonatomic) UIView *interstitialAdView;

@property (assign, nonatomic) NSInteger newGameCounter;

@property (assign, nonatomic) BOOL gameCenterEnabled;
@property (strong, nonatomic) NSString *leaderboardIdentifier;

// sounds
@property (assign, nonatomic) SystemSoundID cardFlipSoundID;
@property (assign, nonatomic) SystemSoundID cardCloseSoundID;
@property (assign, nonatomic) SystemSoundID cardMatchSoundID;
@property (assign, nonatomic) SystemSoundID cardDealSoundID;
@property (assign, nonatomic) SystemSoundID cardDoneSoundID;

@end

@implementation MatchEmViewController

- (void)dealloc
{
    [self.timerForGameDuration invalidate];
    self.timerForGameDuration = nil;
    
    AudioServicesDisposeSystemSoundID(self.cardFlipSoundID);
    AudioServicesDisposeSystemSoundID(self.cardCloseSoundID);
    AudioServicesDisposeSystemSoundID(self.cardMatchSoundID);
    AudioServicesDisposeSystemSoundID(self.cardDealSoundID);
    AudioServicesDisposeSystemSoundID(self.cardDoneSoundID);
    
}

- (ADBannerView *)adBannerView
{
    if (_adBannerView == nil) {
        _adBannerView = [[ADBannerView alloc] init];
    }
    
    return _adBannerView;
}


- (PlayingCardDeck *)playingCardDeck
{
    if (_playingCardDeck == nil) {
        _playingCardDeck = [[PlayingCardDeck alloc] init];
    }
    
    return _playingCardDeck;
}

- (MemoryCardMatchingGame *)matchingGame
{
    if (!_matchingGame) {
        _matchingGame = [[MemoryCardMatchingGame alloc] initWithCards:self.cardButtons.count usingDeck:[[PlayingCardDeck alloc] init]];
        if (_matchingGame) {
            self.timerForGameDuration = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        }
        self.newGameCounter++;
    }
    
    return _matchingGame;
}

- (void)timerTick:(NSTimer *)timer {
    
    NSDate *now = [NSDate date];
    NSTimeInterval gameDurationInSeconds = [now timeIntervalSinceDate:self.matchingGame.gameStartTime];
    self.gameTimeLabel.text = [NSString stringWithFormat:@"Time: %ld secs", (long)gameDurationInSeconds];
    
    if (self.matchingGame.gameOver) {
        self.gameOver = self.matchingGame.gameOver;
        [timer invalidate];
        [self.timerForGameDuration invalidate];
        self.timerForGameDuration = nil;
        AudioServicesPlaySystemSound(self.cardDoneSoundID);
        [self reportFlipCountAndTimeTaken:gameDurationInSeconds];
        
        MatchEmGameResultViewController *gameResultViewController = [[MatchEmGameResultViewController alloc] init];
        gameResultViewController.flipCount = self.matchingGame.flipCount;
        gameResultViewController.timeTakenInSeconds = gameDurationInSeconds;
        [self.navigationController pushViewController:gameResultViewController animated:YES];
    }
    
}

- (void)startNewGame
{
    [self.timerForGameDuration invalidate];
    self.timerForGameDuration = nil;
    self.matchingGame = nil;
    self.gameOver = NO;
    
    AudioServicesPlaySystemSound(self.cardDealSoundID);
    [self resetUI]; // this will create a new game, and update the UI.
}

- (IBAction)touchSettingsButton:(UIButton *)sender
{
}

- (IBAction)touchRankingsButton:(UIButton *)sender
{
    [self showGameCenterLeaderboard];
}


- (IBAction)touchDealButton:(UIButton *)sender
{
    if ((self.newGameCounter%3) == 0) {
        [self showFullScreenAd];
    } else {
        [self startNewGame];
    }
}

- (IBAction)touchCardButton:(id)sender
{
    __block NSInteger choosenButtonIndex = [self.cardButtons indexOfObject:sender];
    
    if (choosenButtonIndex >= 0) {
        AudioServicesPlaySystemSound(self.cardFlipSoundID);
        NSInteger numberOfChoosenCards = [self.matchingGame numberOfChoosenUnMatchedCards];
        if ( numberOfChoosenCards == 0) {
            [self.matchingGame chooseCardAtIndex:choosenButtonIndex];
            [self updateUI];
        } else if (numberOfChoosenCards == 1) {
            if ([self.matchingGame selectCardAtIndex:choosenButtonIndex]) {
                [self updateUI];
                __weak typeof (self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    sleep(1.0f);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (choosenButtonIndex >= 0) {
                            [weakSelf.matchingGame deSelectCardAtIndex:choosenButtonIndex];
                            BOOL isCardsMatched = [weakSelf.matchingGame chooseCardAtIndex:choosenButtonIndex];
                            if (isCardsMatched) {
                                AudioServicesPlaySystemSound(self.cardMatchSoundID);
                            } else {
                                AudioServicesPlaySystemSound(self.cardCloseSoundID);
                            }
                            [weakSelf updateUI];
                        }
                    });
                });
                
            }
        }
    }
}

- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons) {
        NSInteger cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
        PlayingCard *card = [self.matchingGame cardAtIndex:cardButtonIndex];
        
        [cardButton setTitle:card.isChosen ? card.contents : @"" forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"] forState:UIControlStateNormal];
        cardButton.enabled = !card.isMatched;
        cardButton.hidden = card.isMatched;
    }
    
    [self.flipCountLabel setText:[NSString stringWithFormat:@"Flips: %ld", (long)self.matchingGame.flipCount]];
    
}

- (void)resetUI
{
    for (UIButton *cardButton in self.cardButtons) {
        
        [cardButton setTitle:@"" forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[UIImage imageNamed:@"cardback"] forState:UIControlStateNormal];
        cardButton.enabled = YES;
        cardButton.hidden = NO;
    }
    
    [self.flipCountLabel setText:[NSString stringWithFormat:@"Flips: %ld", (long)0]];
    [self.gameTimeLabel setText:[NSString stringWithFormat:@"Time: %ld secs", (long)0]];
    
}

//Interstitial iAd
-(void)showFullScreenAd {
    if (self.currentlyRequestingAd == NO) {
        self.interstitialAd = [[ADInterstitialAd alloc] init];
        self.interstitialAd.delegate = self;
        NSLog(@"Ad Request");
        self.currentlyRequestingAd = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupSubViews];
    if (self.gameOver) {
        [self startNewGame];
    }
}

- (void)viewDidLayoutSubviews
{
    
}

- (void)setupSubViews
{
    CGRect viewFrame = self.view.frame;
    
    CGRect newBannerViewFrame = CGRectMake(0, viewFrame.size.height-50, viewFrame.size.width, 50);
    [self.adBannerView setFrame:newBannerViewFrame];
    self.adBannerView.delegate = self;
    [self.view addSubview:self.adBannerView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.currentlyRequestingAd = NO;
    [self authenticateGameCenterLocalPlayer];
    
    // load sound files
    self.cardFlipSoundID = [self loadSoundEffect:@"CardFlip" ofType:@"wav"];
    self.cardCloseSoundID = [self loadSoundEffect:@"CardsClose" ofType:@"wav"];
    self.cardMatchSoundID = [self loadSoundEffect:@"CardMatch" ofType:@"wav"];
    self.cardDealSoundID = [self loadSoundEffect:@"CardsDeal" ofType:@"wav"];
    self.cardDoneSoundID = [self loadSoundEffect:@"CardsGameDone" ofType:@"wav"];
    
    [self setNavigationItems];
    
}

- (void)setNavigationItems
{
    [self setTitle:@"Match'em"];

    UIBarButtonItem *dealCardsBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Deal"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(touchDealButton:)];
    [self.navigationItem setRightBarButtonItem:dealCardsBarButtonItem];
    
    
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Rankings"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(touchRankingsButton:)];
    [self.navigationItem setLeftBarButtonItem:settingsBarButtonItem];
    
    
    
}

- (SystemSoundID)loadSoundEffect:(NSString *)pathForResource ofType:(NSString *)soundType
{
    NSString *path  = [[NSBundle mainBundle] pathForResource:pathForResource ofType:soundType];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    
    SystemSoundID soundEffectID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &soundEffectID);
    
    return soundEffectID;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AdBannerViewDelegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:1.0];
    
    [banner setAlpha:1.0];
    
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:1.0];
    
    [banner setAlpha:0.0];
    
    [UIView commitAnimations];
}

#pragma mark - ADInterstitialAdDelegate

-(void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    self.currentlyRequestingAd = NO;
    NSLog(@"Ad didFailWithERROR");
    NSLog(@"%@", error);
    interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    [self startNewGame];
}

-(void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"Ad DidLOAD");
    if (interstitialAd.loaded) {
        CGRect interstitialFrame = self.view.bounds;
        interstitialFrame.origin = CGPointMake(0, 60);
        self.interstitialAdView = [[UIView alloc] initWithFrame:interstitialFrame];
        [self.view addSubview:self.interstitialAdView];
        
        [self.interstitialAd presentInView:self.interstitialAdView];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(closeAd:) forControlEvents:UIControlEventTouchDown];
        button.backgroundColor = [UIColor clearColor];
        [button setBackgroundImage:[UIImage imageNamed:@"close-button.png"] forState:UIControlStateNormal];
        button.frame = CGRectMake(10, 30, 30, 30);
        [self.interstitialAdView addSubview:button];
        
        [UIView beginAnimations:@"animateAdBannerOn" context:nil];
        [UIView setAnimationDuration:1];
        [self.interstitialAdView setAlpha:1];
        [UIView commitAnimations];
        
    }
}

-(void)closeAd:(id)sender
{
    [UIView beginAnimations:@"animateAdBannerOff" context:nil];
    [UIView setAnimationDuration:1];
    [self.interstitialAdView setAlpha:0];
    [UIView commitAnimations];
    
    self.interstitialAdView=nil;
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.currentlyRequestingAd = NO;
    
    [self startNewGame];
}

-(void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    self.currentlyRequestingAd = NO;
    NSLog(@"Ad DidUNLOAD");
}

-(void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    self.currentlyRequestingAd = NO;
    NSLog(@"Ad DidFINISH");
}

#pragma mark - GameCenter integration

-(void)authenticateGameCenterLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    __weak GKLocalPlayer *weakLocalPlayer = localPlayer;
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        __strong GKLocalPlayer *strongLocalPlayer = weakLocalPlayer;
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if (strongLocalPlayer.authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [strongLocalPlayer loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

-(void)reportFlipCountAndTimeTaken:(NSInteger)timeTaken
{
    GKScore *flipCountScore = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderboardIdentifier];
    flipCountScore.value = self.matchingGame.flipCount;
    
    [GKScore reportScores:@[flipCountScore] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    GKScore *timeTakenScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"Time.Taken.Leaderboard"];
    timeTakenScore.value = timeTaken;
    [GKScore reportScores:@[timeTakenScore] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
}

-(void)showGameCenterLeaderboard
{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = self.leaderboardIdentifier;
    
    
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
