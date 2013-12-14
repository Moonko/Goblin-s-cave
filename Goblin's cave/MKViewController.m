//
//  MKViewController.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKViewController.h"
#import "MKGameScene.h"

@interface MKViewController ()

@property (nonatomic) IBOutlet SKView *skView;
@property (nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;
@property (nonatomic) IBOutlet UIButton *warriorButton;
@property (nonatomic) IBOutlet UIButton *archerButton;
@property (nonatomic) MKGameScene *scene;

@end

@implementation MKViewController

#pragma mark - Application's lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [self.progressIndicator startAnimating];
    [MKGameScene loadSceneAssetsWithCompletionHandler:^
     {
         CGSize viewSize = self.view.bounds.size;
         
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
         {
             viewSize.height *= 2;
             viewSize.width *= 2;
         }
         
         MKGameScene *scene = [[MKGameScene alloc] initWithSize:viewSize];
         scene.scaleMode = SKSceneScaleModeAspectFill;
         self.scene = scene;
         
         [self.progressIndicator stopAnimating];
         [self.progressIndicator setHidden:YES];
         
         [self.skView presentScene:scene];
         
         //self.skView.showsFPS = YES;
         //self.skView.showsNodeCount = YES;
         [UIView animateWithDuration:2.0
                               delay:0.0
                             options:UIViewAnimationOptionCurveEaseInOut
                          animations:^{
             self.archerButton.alpha = 1.0f;
             self.warriorButton.alpha = 1.0f;
         } completion:NULL];
     }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - UI Display And Actions

- (void) hideUIElements:(BOOL)shouldHide animated:(BOOL)shouldAnimate
{
    CGFloat alpha = shouldHide ? 0.0f : 1.0f;
    
    if (shouldAnimate)
    {
        [UIView animateWithDuration:2.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.archerButton.alpha = alpha;
                             self.warriorButton.alpha = alpha;
                         }completion:NULL];
    } else
    {
        [self.warriorButton setAlpha:alpha];
        [self.archerButton setAlpha:alpha];
    }
}

- (IBAction)chooseWarrior:(id)sender
{
    [self startGameWithHeroType:MKHeroTypeWarrior];
}

- (IBAction)chooseArcher:(id)sender
{
    [self startGameWithHeroType:MKHeroTypeArcher];
}

#pragma mark - Starting the game

-(void)startGameWithHeroType:(MKHeroType)type
{
    [self hideUIElements:YES
                animated:YES];
    [self.scene setDefaultPlayerHeroType:type];
    [self.scene startLevel];
}

@end
