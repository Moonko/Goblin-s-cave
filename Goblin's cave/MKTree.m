//
//  MKTree.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKTree.h"
#import "MKUtilites.h"
#import "MKCharacterScene.h"
#import "MKHeroCharacter.h"

@implementation MKTree

#pragma mark - Initialization

- (id)initWithSprites:(NSArray *)sprites
{
    self  = [super init];
    if (self)
    {
        CGFloat zPosition = self.zPosition;
        NSUInteger childNumber = 0;
        for (SKNode *node in sprites)
        {
            node.zPosition = zPosition + childNumber;
            [self addChild:node];
            childNumber++;
        }
    }
    return self;
}

#pragma mark - Copying

- (id) copyWithZone:(NSZone *)zone
{
    MKTree *tree = [super copyWithZone:zone];
    if (tree)
    {
        tree->_fadeAlpha = self.fadeAlpha;
    }
    return tree;
}

#pragma mark - Offsets

- (void)updateAlphaWithScene:(MKCharacterScene *)scene
{
    if (!self.fadeAlpha)
    {
        return;
    }
    
    CGFloat closestHeroDistance = MAXFLOAT;
    
    CGFloat distance = MKDistanceBetweenPoints(self.position, scene.hero.position);
    if (distance < closestHeroDistance)
    {
        closestHeroDistance = distance;
    }
    
    if (closestHeroDistance > kOpaqueDistance)
    {
        self.alpha = 1.0;
    } else
    {
        self.alpha = 0.1 + (closestHeroDistance / kOpaqueDistance) *
        (closestHeroDistance / kOpaqueDistance) * 0.9;
    }
}

@end
