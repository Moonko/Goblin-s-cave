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
    
    _projectile = [SKSpriteNode spriteNodeWithImageNamed:@"arrow.png"];
    _projectile.scale = 0.3;
    _projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kProjectileCollisionRadius];
    _projectile.name = @"Projectile";
    _projectile.physicsBody.categoryBitMask = MKColliderTypeProjectile;
    _projectile.physicsBody.collisionBitMask = MKColliderTypeWall;
    _projectile.physicsBody.contactTestBitMask =
    _projectile.physicsBody.collisionBitMask;

    return [super initWithTexture:texture
                       atPosition:position];
}

@end
