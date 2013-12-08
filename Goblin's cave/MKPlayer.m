//
//  MKPlayer.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKPlayer.h"

@implementation MKPlayer

#pragma mark - Initialization

- (id) init
{
    self = [super init];
    if (self)
    {
        _livesLeft = kStartLives;
        
        if ((arc4random_uniform(2)) == 0)
        {
            _heroClass = NSClassFromString(@"MKWarrior");
        } else
        {
            _heroClass = NSClassFromString(@"MKArcher");
        }
    }
    return self;
}

@end
