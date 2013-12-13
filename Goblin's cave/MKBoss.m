//
//  MKBoss.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKBoss.h"
#import "MKChaseAI.h"
#import "MKUtilites.h"
#import "MKHeroCharacter.h"
#import "MKCharacterScene.h"

#define kBossCollisionRadius 40
#define kBossChaseRadius (kBossCollisionRadius * 4)

@implementation MKBoss

- (id) initAtPosition:(CGPoint)position
{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"boss_idle_0001.png"]
                        atPosition:position];
    if (self)
    {
        self.movementSpeed = kMovementSpeed * 0.35f;
        self.zPosition = 1.0f / 35.0f;
        self.name = @"Boss";
        
        MKChaseAI *intelligence = [[MKChaseAI alloc] initWithCharacter:self
                                                                target:nil];
        intelligence.chaseRadius = kBossChaseRadius;
        intelligence.maxAlertRadius = kBossChaseRadius * 4.0f;
        self.intelligence = intelligence;
    }
    return self;
}

- (void)configurePhysicsBody
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBossCollisionRadius];
    
    self.physicsBody.categoryBitMask = MKColliderTypeGoblinOrBoss;
    self.physicsBody.collisionBitMask = MKColliderTypeGoblinOrBoss |
    MKColliderTypeHero | MKColliderTypeProjectile | MKColliderTypeWall;
    self.physicsBody.contactTestBitMask = MKColliderTypeProjectile;
}

- (void)collideWith:(SKPhysicsBody *)other
{
    if (other.categoryBitMask & MKColliderTypeProjectile)
    {
        CGFloat damage = 2.0f;
        BOOL killed = [self applyDamage:damage
                         fromProjectile:other.node];
        if (killed)
        {
            [[self characterScene] addToScore:100];
            [self removeFromParent];
        }
    }
}

- (void)performDeath
{
    [self removeAllActions];
    
    [super performDeath];
}

#pragma mark - Shared Assets
+ (void)loadSharedAssets {
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedDamageEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"BossDamage"];
        sSharedDamageAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor whiteColor]
                                                              colorBlendFactor:1.0
                                                                      duration:0.0],
                                                   [SKAction waitForDuration:0.5],
                                                   [SKAction colorizeWithColorBlendFactor:0.0 duration:0.1]
                                                   ]];
    });
}

static SKEmitterNode *sSharedDamageEmitter = nil;
- (SKEmitterNode *)damageEmitter
{
    return sSharedDamageEmitter;
}

static SKAction *sSharedDamageAction = nil;
- (SKAction *)damageAction
{
    return sSharedDamageAction;
}

@end
