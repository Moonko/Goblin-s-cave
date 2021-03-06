//
//  MKHeroCharacter.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKHeroCharacter.h"
#import "MKUtilites.h"
#import "MKCharacterScene.h"

#define kHeroProjectileSpeed 480.0
#define kHeroProjectileLifeTime 1.0
#define kHeroProjectileFadeOutTime 0.6

@implementation MKHeroCharacter

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self)
    {
        if ((arc4random_uniform(2)) == 0)
        {
            _heroClass = NSClassFromString(@"MKWarrior");
        } else
        {
            _heroClass = NSClassFromString(@"MKArcher");
        }
    }
    self.timeSinceLastAttack = 0;
    return self;
}


- (id) initAtPosition:(CGPoint)position
{
    return [self initWithTexture:nil
                      atPosition:position];
}

- (id) initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position
{
    self = [super initWithTexture:texture
                       atPosition:position];
    if (self)
    {
        self.zRotation = M_PI;
        self.zPosition = -0.25;
        self.name = [NSString stringWithFormat:@"Hero"];
    }
    return self;
}

#pragma mark - Overriding

- (void) configurePhysicsBody
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kCharacterCollisionRadius];
    
    self.physicsBody.categoryBitMask = MKColliderTypeHero;
    self.physicsBody.collisionBitMask = MKColliderTypeGoblinOrBoss |
    MKColliderTypeWall | MKColliderTypeCave;
    self.physicsBody.contactTestBitMask = MKColliderTypeGoblinOrBoss;
}

- (void) collideWith:(SKPhysicsBody *)other
{
    if (other.categoryBitMask & MKColliderTypeGoblinOrBoss)
    {
        [self applyDamage:5.0f];
    }
}

- (void) performAttackAction
{
    [self faceTo:_targetLocation];
    if (self.timeSinceLastAttack <= 0.2)
    {
        return;
    }else
    {
        [self fireProjectile];
        self.timeSinceLastAttack = 0.0;
    };
}

#pragma mark - Projectiles

- (void) fireProjectile
{
    SKSpriteNode *projectile = [[self projectile] copy];
    
    projectile.position = self.position;
    projectile.zRotation = self.zRotation;
   
    [self.characterScene addNode:projectile
       atWorlLayer:MKWorldLayerCharacter];
    
     CGFloat rot = self.zRotation;
    
    [projectile runAction:[SKAction moveByX:-sinf(rot) * kHeroProjectileSpeed * kHeroProjectileLifeTime
                                               y:cosf(rot) * kHeroProjectileLifeTime * kHeroProjectileSpeed
                                        duration:kHeroProjectileLifeTime]];
    [projectile runAction:[SKAction sequence:
  @[[SKAction waitForDuration:kHeroProjectileFadeOutTime],
    [SKAction fadeOutWithDuration:kHeroProjectileLifeTime - kHeroProjectileFadeOutTime],
    [SKAction removeFromParent]]]];
}

- (SKSpriteNode *)projectile
{
    return nil;
}

- (SKEmitterNode *)projectileEmitter
{
    return nil;
}

@end
