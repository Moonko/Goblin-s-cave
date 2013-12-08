//
//  MKChaseAI.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKChaseAI.h"
#import "MKCharacter.h"
#import "MKUtilites.h"
#import "MKPlayer.h"
#import "MKCharacterScene.h"
#import "MKHeroCharacter.h"

@implementation MKChaseAI

#pragma mark - Initialization

- (id) initWithCharacter:(MKCharacter *)character target:(MKCharacter *)target
{
    self = [super initWithCharacter:character
                             target:target];
    if (self)
    {
        _maxAlertRadius = (kEnemyAlertRadius * 2.0f);
        _chaseRadius = (kCharacterCollisionRadius * 2.0f);
    }
    return self;
}

#pragma mark - Loop update

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval
{
    if (self.character.dying)
    {
        self.target = nil;
        return;
    }
    
    CGPoint position = self.character.position;
    
    MKCharacterScene *scene = [self.character characterScene];
    
    CGFloat closestHeroDistance = MAXFLOAT;
    
    CGFloat distance = MKDistanceBetweenPoints(position, scene.player.hero.position);
    if (distance < kEnemyAlertRadius && distance < closestHeroDistance && !scene.player.hero.dying)
    {
        closestHeroDistance = distance;
        self.target = scene.player.hero;
    }
    
    MKCharacter *target = self.target;
    if (!target)
    {
        return;
    }
    
    CGPoint heroPosition = target.position;
    CGFloat chaseRadius = self.chaseRadius;
    
    if (closestHeroDistance > self.maxAlertRadius)
    {
        self.target = nil;
    } else if (closestHeroDistance > chaseRadius)
    {
        [self.character moveTowards:heroPosition withTimeInterval:interval];
    } else if (closestHeroDistance < chaseRadius)
    {
        [self.character faceTo:heroPosition];
        [self.character performAttackAction];
    }
}

@end
