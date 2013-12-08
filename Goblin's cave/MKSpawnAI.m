//
//  MKSpawnAI.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKSpawnAI.h"
#import "MKCave.h"
#import "MKCharacterScene.h"
#import "MKUtilites.h"

#define kMinimumHeroDistance 2048

@implementation MKSpawnAI

#pragma mark - Loop update

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeInterval
{
  /*  MKCave *cave = (id)self.character;
    
    if (cave.health <= 0.0f)
    {
        return;
    }
    
    MKCharacterScene *scene = [cave characterScene];
    
    CGFloat closestHeroDistance = kMinimumHeroDistance;
    CGPoint closestHeroPosition = CGPointZero;
    
    CGPoint cavePosition = cave.position;
    CGFloat distance = MKDistanceBetweenPoints(cavePosition,
                                               scene.hero.position);
    if (distance < closestHeroDistance)
    {
        closestHeroDistance = distance;
        closestHeroPosition = scene.hero.position;
    }
    
    CGFloat distScale = (closestHeroDistance / kMinimumHeroDistance);
    
    cave.timeUntilNextGenerate -= timeInterval;
    
    NSUInteger goblinCount = [cave.activeGoblins count];
    if (goblinCount < 1 || cave.timeUntilNextGenerate <= 0.0f || (distScale < 0.35f && cave.timeUntilNextGenerate > 5.0f))
    {
        if (goblinCount < 1 || (goblinCount < 4 &&
                                !CGPointEqualToPoint(closestHeroPosition, CGPointZero) &&
                                [scene canSee:closestHeroPosition
                                         from:cavePosition]))
            {
                [cave generate];
            }
            cave.timeUntilNextGenerate = (4.0f * distScale);
    } */
}

@end
