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
    CGPoint position = self.character.position;
    
    MKCharacterScene *scene = [self.character characterScene];
    
    CGFloat closestHeroDistance = MAXFLOAT;
    
    CGFloat distance = MKDistanceBetweenPoints(position, scene.hero.position);
    if (distance < kEnemyAlertRadius && distance < closestHeroDistance)
    {
        closestHeroDistance = distance;
        self.target = scene.hero;
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
        self.character.timeSinceLastAttack += interval;
        
        if (self.character.timeSinceLastAttack >= 1.0)
        {
            [target collideWith:self.character.physicsBody];
            MKCharacterScene *scene = [self.character characterScene];
            SKSpriteNode *explosion = [SKSpriteNode
                                       spriteNodeWithTexture:[self.explosionTextures
                                                              objectAtIndex:0]];
            explosion.scale = 0.2;
            CGFloat rot = MK_POLAR_ADJUST(self.character.zRotation);
            explosion.position = MKPointByAddingCGPoints(self.character.position,
                                                      CGPointMake(cosf(rot) * 50,
                                                                  sinf(rot) * 50));
            [scene addNode:explosion
               atWorlLayer:MKWorldLayerAboveCharacter];
            SKAction *explosionAction = [SKAction animateWithTextures:self.explosionTextures
                                                         timePerFrame:0.07];
            SKAction *remove = [SKAction removeFromParent];
            [explosion runAction:[SKAction sequence:@[explosionAction, remove]]];
            self.character.timeSinceLastAttack = 0.0;
        }
    }
}

@end
