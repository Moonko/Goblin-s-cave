//
//  MKEnemyCharacter.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKEnemyCharacter.h"
#import "MKArtificialIntelligence.h"

@implementation MKEnemyCharacter

#pragma mark - Loop update

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval
{
    [super updateWithTimeSinceLastUpdate:interval];
    
    [self.intelligence updateWithTimeSinceLastUpdate:interval];
}

@end
