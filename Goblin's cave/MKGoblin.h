//
//  MKGoblin.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKEnemyCharacter.h"

@class MKCave;

@interface MKGoblin : MKEnemyCharacter

- (id) initAtPosition:(CGPoint)position;

@property (nonatomic, weak) MKCave *cave;

@end
