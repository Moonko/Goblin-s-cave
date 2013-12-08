//
//  MKArtificialIntelligence.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKArtificialIntelligence.h"

@implementation MKArtificialIntelligence

#pragma mark - Initialization

- (id) initWithCharacter:(MKCharacter *)character target:(MKCharacter *)target
{
    self = [super init];
    if (self)
    {
        _character = character;
        _target = target;
    }
    return self;
}

#pragma mark - Loop update

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)timeInterval
{
    // Overriden by subclasses;
}

#pragma mark - Targets

- (void) clearTarget:(MKCharacter *)target
{
    if (self.target == target)
    {
        self.target = nil;
    }
}

@end
