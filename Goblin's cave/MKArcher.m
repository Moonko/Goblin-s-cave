//
//  MKArcher.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKArcher.h"
#import "MKUtilites.h"
#import "MKCharacterScene.h"

#define kArcherProjectileSpeed 8.0

@implementation MKArcher

- (id) initAtPosition:(CGPoint)position
{
    SKTexture *texture = [SKTexture textureWithImageNamed:@"archer_idle_0001.png"];
    
    return [super initWithTexture:texture
                       atPosition:position];
}

+ (void) loadSharedAssets
{
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedProjectile = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor]
                                                         size:CGSizeMake(2.0, 24.0)];
        sSharedProjectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kProjectileCollisionRadius];
        sSharedProjectile.name = @"Projectile";
        sSharedProjectile.physicsBody.collisionBitMask = MKColliderTypeProjectile;
        sSharedProjectile.physicsBody.contactTestBitMask = sSharedProjectile.physicsBody.collisionBitMask;
        
        sSharedProjectileEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"ArcherProjectile"];
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
