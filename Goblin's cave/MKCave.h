//
//  MKCave.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKEnemyCharacter.h"

@class MKGoblin;

@interface MKCave : MKEnemyCharacter

@property (nonatomic, readonly) NSArray *activeGoblins;
@property (nonatomic, readonly) NSArray *inactiveGoblins;
@property (nonatomic) CGFloat timeUntilNextGenerate;

- (id) initAtPosition:(CGPoint)position;

+ (int) globalGoblinCap;
+ (void) setGlobalGoblinCap:(int)amount;

- (void) generate;
- (void) recycle: (MKGoblin *)object;

- (void) stopGoblinsFromTargettingHero:(MKCharacter *)hero;

@end
