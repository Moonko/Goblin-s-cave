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
#import "MKHeroCharacter.h"

#define kMinimumHeroDistance 2048

@implementation MKSpawnAI

#pragma mark - Loop update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval
{
    MKCave *cave = (id)self.character;
    
    if (cave.health <= 0.0f)
    {
        return;
    }
    
    MKCharacterScene *scene = [cave characterScene];
    
    CGFloat closestHeroDistance = kMinimumHeroDistance;
    CGPoint closestHeroPosition = CGPointZero;
    
    CGPoint cavePosition = cave.position;
    
    CGPoint heroPosition = scene.hero.position;
    CGFloat distance = MKDistanceBetweenPoints(cavePosition, heroPosition);
    if (distance < closestHeroDistance)
    {
        closestHeroDistance = distance;
        closestHeroPosition = heroPosition;
    }
    
    CGFloat distScale = (closestHeroDistance / kMinimumHeroDistance);

    cave.timeUntilNextGenerate -= interval;
    
    NSUInteger goblinCount = [cave.activeGoblins count];
    if (goblinCount < 1 ||
        (goblinCount < 4 && !CGPointEqualToPoint(closestHeroPosition, CGPointZero)))
    {
        if (goblinCount < 1 || (goblinCount < 4 &&
                                !CGPointEqualToPoint(closestHeroPosition, CGPointZero)))
        {
            [cave generate];
        }
        cave.timeUntilNextGenerate = (4.0f * distScale);
    }
}
@end
