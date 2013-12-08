//
//  MKWarrior.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKWarrior.h"
#import "MKUtilites.h"
#import "MKCharacterScene.h"

@implementation MKWarrior

#pragma mark - Initialization

- (id) initAtPosition:(CGPoint)position
{
    SKTexture *texture = [SKTexture textureWithImageNamed:@"warrior_idle_0001.png"];
    
    return [super initWithTexture:texture
                       atPosition:position];
}

#pragma mark - Assets

+ (void) loadSharedAssets
{
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedProjectile = [SKSpriteNode spriteNodeWithImageNamed:@"warrior_throw_hammer.png"];
        sSharedProjectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kProjectileCollisionRadius];
        sSharedProjectile.name = @"Projectile";
        sSharedProjectile.physicsBody.collisionBitMask = MKColliderTypeProjectile;
        sSharedProjectile.physicsBody.contactTestBitMask = sSharedProjectile.physicsBody.collisionBitMask;
        
        sSharedProjectileEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"WarriorProjectile"];
        sSharedDamageAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor whiteColor]
                                                              colorBlendFactor:10.0
                                                                      duration:0.0],
                                                   [SKAction waitForDuration:0.75],
                                                   [SKAction colorizeWithColorBlendFactor:0.0
                                                                                 duration:0.25]
                                                   ]];
    });
}

static SKSpriteNode *sSharedProjectile = nil;
- (SKSpriteNode *)projectile
{
    return sSharedProjectile;
}

static SKEmitterNode *sSharedProjectileEmitter = nil;
- (SKEmitterNode *)projectileEmitter
{
    return sSharedProjectileEmitter;
}

static SKAction *sSharedDamageAction = nil;
- (SKAction *)damageAction
{
    return sSharedDamageAction;
}

@end
