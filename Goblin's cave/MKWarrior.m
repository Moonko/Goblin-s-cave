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
    
    _projectile = [SKSpriteNode spriteNodeWithColor:[SKColor redColor]
                                               size:CGSizeMake(2.0, 24.0)];
    _projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kProjectileCollisionRadius];
    _projectile.name = @"Projectile";
    _projectile.physicsBody.categoryBitMask = MKColliderTypeProjectile;
    _projectile.physicsBody.collisionBitMask = MKColliderTypeWall;
    _projectile.physicsBody.contactTestBitMask = _projectile.physicsBody.collisionBitMask;
    
    return [super initWithTexture:texture
                       atPosition:position];
}

@end
