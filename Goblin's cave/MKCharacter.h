//
//  MKCharacter.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

// Bitmask for the different entities with physics bodies.
typedef enum : uint8_t
{
    MKColliderTypeHero             = 1,
    MKColliderTypeGoblinOrBoss     = 2,
    MKColliderTypeProjectile       = 4,
    MKColliderTypeWall             = 8,
    MKColliderTypeCave             = 16
} MKColliderType;


#define kMovementSpeed 200.0
#define kRotationSpeed 0.06

#define kCharacterCollisionRadius   40
#define kProjectileCollisionRadius  15

#import <SpriteKit/SpriteKit.h>

@class MKCharacterScene;

@interface MKCharacter : SKSpriteNode

@property (nonatomic, getter = isDying) BOOL dying;
@property (nonatomic, getter = isAttacking) BOOL attacking;
@property (nonatomic) CGFloat health;
@property (nonatomic) CGFloat movementSpeed;

+ (void) loadSharedAssets;

- (id) initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;

- (id) initWithSprites:(NSArray *)sprites atPosition:(CGPoint)position;

- (void) reset;

- (void) collideWith:(SKPhysicsBody *)other;
- (void) performDeath;
- (void) configurePhysicsBody;

- (BOOL) applyDamage:(CGFloat)damage;
- (BOOL) applyDamage:(CGFloat)damage fromProjectile:(SKNode *)projectile;

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;

- (CGFloat) faceTo:(CGPoint)position;
- (void) moveTowards:(CGPoint)position withTimeInterval:(NSTimeInterval)timeInterval;
- (void) performAttackAction;

- (void) addToScene:(MKCharacterScene *)scene;
- (MKCharacterScene *) characterScene;

- (void)fadeIn: (CGFloat)duration;

@end
