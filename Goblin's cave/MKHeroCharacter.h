//
//  MKHeroCharacter.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKEnemyCharacter.h"

@interface MKHeroCharacter : MKCharacter

@property (nonatomic) Class heroClass;

@property (nonatomic) BOOL fireAction;

@property (nonatomic) CGPoint heroMoveDirection;

@property (nonatomic) uint8_t livesLeft;
@property (nonatomic) uint32_t score;

@property (nonatomic) UITouch *movementTouch;
@property (nonatomic) CGPoint targetLocation;
@property (nonatomic) BOOL moveRequested;

- (id) initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;

- (id) initAtPosition:(CGPoint)position;

- (void) fireProjectile;

- (SKSpriteNode *) projectile;
- (SKEmitterNode *) projectileEmitter;

extern NSString *const kPlayer;

@end
