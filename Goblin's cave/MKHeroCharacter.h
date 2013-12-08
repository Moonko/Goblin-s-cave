//
//  MKHeroCharacter.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKEnemyCharacter.h"

@class MKPlayer;

@interface MKHeroCharacter : MKCharacter

@property (nonatomic, weak) MKPlayer *player;

- (id) initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;

- (id) initAtPosition:(CGPoint)position;

- (void) fireProjectile;

- (SKSpriteNode *) projectile;
- (SKEmitterNode *) projectileEmitter;

extern NSString *const kPlayer;

@end
